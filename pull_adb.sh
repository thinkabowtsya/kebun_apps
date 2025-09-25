#!/usr/bin/env bash
# pull_sqlite_adb.sh
# Pure adb-based script (bash). Untuk Windows gunakan Git Bash atau WSL.
# Usage:
#   chmod +x pull_sqlite_adb.sh
#   ./pull_sqlite_adb.sh <deviceId> <package> <dbname>
# Example:
#   ./pull_sqlite_adb.sh 34420290270011E com.example.flutter_application_3 alammobile.db

set -euo pipefail

DEVICE="${1:-}"
PKG="${2:-}"
DBNAME="${3:-}"

if [ -z "$DEVICE" ] || [ -z "$PKG" ] || [ -z "$DBNAME" ]; then
  echo "Usage: $0 <deviceId> <package> <dbname>"
  echo "Example: $0 34420290270011E com.example.flutter_application_3 alammobile.db"
  exit 1
fi

REMOTE_DB="/data/data/${PKG}/databases/${DBNAME}"
LOCAL_DB="${DBNAME}"
LOCAL_WAL="${DBNAME}-wal"
LOCAL_SHM="${DBNAME}-shm"
TMP_REMOTE="/sdcard/${DBNAME}"
TMP_REMOTE_WAL="/sdcard/${DBNAME}-wal"
TMP_REMOTE_SHM="/sdcard/${DBNAME}-shm"

echoc() { printf '%s\n' "$*"; }

echoc "== Mulai: tarik ${DBNAME} dari device ${DEVICE} (package: ${PKG})"

# 1) Force-stop app agar file konsisten
echoc "-> Menghentikan aplikasi agar file DB stabil..."
adb -s "${DEVICE}" shell "am force-stop ${PKG}" || echoc "   (warning: force-stop gagal — lanjutkan)"

# 2) Coba langsung dengan exec-out run-as cat -> stdout -> file lokal
echoc "-> Mencoba exec-out run-as cat (langsung tarik .db)..."
if adb -s "${DEVICE}" exec-out run-as "${PKG}" cat "${REMOTE_DB}" > "${LOCAL_DB}.tmp" 2>/dev/null; then
  mv -f "${LOCAL_DB}.tmp" "${LOCAL_DB}"
  echoc "   Berhasil: ${LOCAL_DB}"
  # tarikk -wal & -shm juga (jika ada)
  if adb -s "${DEVICE}" exec-out run-as "${PKG}" cat "${REMOTE_DB}-wal" > "${LOCAL_WAL}" 2>/dev/null; then
    echoc "   -wal ditarik: ${LOCAL_WAL}"
  else
    echoc "   -wal tidak ditemukan (atau gagal)."
    rm -f "${LOCAL_WAL}" 2>/dev/null || true
  fi
  if adb -s "${DEVICE}" exec-out run-as "${PKG}" cat "${REMOTE_DB}-shm" > "${LOCAL_SHM}" 2>/dev/null; then
    echoc "   -shm ditarik: ${LOCAL_SHM}"
  else
    echoc "   -shm tidak ditemukan (atau gagal)."
    rm -f "${LOCAL_SHM}" 2>/dev/null || true
  fi
else
  echoc "   exec-out run-as cat GAGAL (mungkin package tidak debuggable atau run-as dibatasi)."
  echoc "-> Fallback: copy ke /sdcard lalu adb pull"

  # copy to sdcard (run-as cp). Jika gagal, kita tangani.
  if adb -s "${DEVICE}" shell "run-as ${PKG} cp ${REMOTE_DB} ${TMP_REMOTE}" 2>/dev/null; then
    echoc "   Berhasil copy DB ke /sdcard"
    adb -s "${DEVICE}" pull "${TMP_REMOTE}" "${LOCAL_DB}" || echoc "   Pull .db gagal setelah copy"
  else
    echoc "   run-as cp gagal. Coba jalankan debug build / tambahkan fitur export di app."
  fi

  # wal & shm fallback
  adb -s "${DEVICE}" shell "run-as ${PKG} cp ${REMOTE_DB}-wal ${TMP_REMOTE_WAL} 2>/dev/null" || true
  adb -s "${DEVICE}" pull "${TMP_REMOTE_WAL}" "${LOCAL_WAL}" 2>/dev/null || echoc "   -wal tidak ada di sdcard"
  adb -s "${DEVICE}" shell "run-as ${PKG} cp ${REMOTE_DB}-shm ${TMP_REMOTE_SHM} 2>/dev/null" || true
  adb -s "${DEVICE}" pull "${TMP_REMOTE_SHM}" "${LOCAL_SHM}" 2>/dev/null || echoc "   -shm tidak ada di sdcard"

  # cleanup tmp files di device (opsional)
  adb -s "${DEVICE}" shell "rm -f ${TMP_REMOTE} ${TMP_REMOTE_WAL} ${TMP_REMOTE_SHM}" 2>/dev/null || true
fi

# 3) Validasi file lokal & optional wal_checkpoint
echoc ""
echoc "== Hasil di folder lokal:"
ls -la "${DBNAME}"* 2>/dev/null || echoc "   (tidak ada file DB di direktori ini)"

# Jika sqlite3 ada, jalankan wal_checkpoint agar isi WAL digabung ke DB utama
if command -v sqlite3 >/dev/null 2>&1; then
  echoc ""
  echoc "-> sqlite3 ditemukan di PATH. Menjalankan PRAGMA wal_checkpoint(FULL)..."
  sqlite3 "${LOCAL_DB}" "PRAGMA wal_checkpoint(FULL);" >/dev/null 2>&1 || echoc "   checkpoint mungkin gagal (periksa file)."
  echoc "   checkpoint selesai (atau gagal tanpa fatal)."
else
  echoc ""
  echoc "-> sqlite3 tidak ditemukan di PATH. Jika ada file -wal, buka DB dengan DB Browser for SQLite (pastikan wal & shm di folder sama)."
fi

echoc ""
echoc "Selesai. Periksa file ${LOCAL_DB} dan ${LOCAL_WAL} (jika ada)."
echoc "Catatan penting:"
echoc " - run-as hanya bekerja pada debug builds (app 'debuggable')."
echoc " - Jika run-as tetap gagal: buat fitur export DB di app (File.copy ke external storage) sementara."
echoc " - Hentikan app sebelum tarik agar perubahan di WAL ditulis konsisten."

exit 0
