// lib/pages/persistence_test_page.dart
import 'package:flutter/material.dart';
import '../utils/persistence_test_helper.dart';

class PersistenceTestPage extends StatefulWidget {
  const PersistenceTestPage({super.key});
  @override
  State<PersistenceTestPage> createState() => _PersistenceTestPageState();
}

class _PersistenceTestPageState extends State<PersistenceTestPage> {
  String _log = '';
  bool _busy = false;

  void _appendLog(String s) {
    setState(() {
      _log = '${DateTime.now().toIso8601String()} - $s\n\n$_log';
    });
    // juga print ke console
    // ignore: avoid_print
    print(s);
  }

  Future<void> _actionInitAndCheck() async {
    setState(() => _busy = true);
    try {
      final path = await PersistenceTestHelper.instance.debugPath();
      _appendLog('DB path: $path');

      final existsBefore =
          await PersistenceTestHelper.instance.dbExistsOnDisk();
      _appendLog('DB exists on disk before init? $existsBefore');

      final count = await PersistenceTestHelper.instance.ensureTestRow();
      _appendLog('ensureTestRow -> rows count: $count');

      final existsAfter = await PersistenceTestHelper.instance.dbExistsOnDisk();
      _appendLog('DB exists on disk after init? $existsAfter');
    } catch (e) {
      _appendLog('ERROR init/check: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _actionCountRows() async {
    setState(() => _busy = true);
    try {
      final count = await PersistenceTestHelper.instance.countTestRows();
      _appendLog('countTestRows -> $count');
    } catch (e) {
      _appendLog('ERROR count: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _actionDeleteDb() async {
    setState(() => _busy = true);
    try {
      await PersistenceTestHelper.instance.deleteDatabaseFile();
      _appendLog('deleteDatabaseFile -> done');
    } catch (e) {
      _appendLog('ERROR delete db: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _actionWriteToken() async {
    setState(() => _busy = true);
    try {
      await PersistenceTestHelper.instance
          .writeToken('tokentest-${DateTime.now().millisecondsSinceEpoch}');
      _appendLog('writeToken -> done');
    } catch (e) {
      _appendLog('ERROR write token: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _actionReadToken() async {
    setState(() => _busy = true);
    try {
      final t = await PersistenceTestHelper.instance.readToken();
      _appendLog('readToken -> ${t ?? "<null>"}');
    } catch (e) {
      _appendLog('ERROR read token: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _actionDeleteToken() async {
    setState(() => _busy = true);
    try {
      await PersistenceTestHelper.instance.deleteToken();
      _appendLog('deleteToken -> done');
    } catch (e) {
      _appendLog('ERROR delete token: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    PersistenceTestHelper.instance.closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persistence Test'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _busy ? null : _actionInitAndCheck,
                  child: const Text('Init & Ensure Row'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : _actionCountRows,
                  child: const Text('Count Rows'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : _actionDeleteDb,
                  child: const Text('Delete DB File'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : _actionWriteToken,
                  child: const Text('Write Token'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : _actionReadToken,
                  child: const Text('Read Token'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : _actionDeleteToken,
                  child: const Text('Delete Token'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _log.isEmpty ? 'Log kosong. Tekan tombol untuk test.' : _log,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
