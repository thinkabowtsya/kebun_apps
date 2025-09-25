import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_3/providers/user_provider.dart';
import 'package:flutter_application_3/providers/sinkron_provider.dart';
import 'package:flutter_application_3/halaman_utama.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final userProv = context.read<UserProvider>();
    final sinkronProv = context.read<SinkronProvider>();

    final ok = await userProv.login(username, password);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Login Gagal: Username/Password tidak valid")),
      );
      return;
    }

    // showDialog akan menjalankan sinkronisasi, dan hanya kembali saat dialog dipop.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Mulai sinkron pada next frame supaya dialog muncul dulu
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await sinkronProv.sinkronisasi(
                username: username, password: password);
          } catch (e) {
            debugPrint('Error sinkron di dialog: $e');
          } finally {
            if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
              Navigator.of(dialogContext, rootNavigator: true).pop();
            }
          }
        });

        return ChangeNotifierProvider.value(
          value: sinkronProv,
          child: WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: SizedBox(
                height: 130,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Consumer<SinkronProvider>(
                      builder: (_, prov, __) => Column(
                        children: [
                          Text(prov.message ?? 'Menghubungkan...'),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: prov.progress),
                          const SizedBox(height: 8),
                          Text('${(prov.progress * 100).toStringAsFixed(0)}%'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Setelah sampai sini, dialog sudah tertutup
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync sudah selesai!')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pakai Consumer utk akses state dari provider (loading button, dsb)
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Consumer<UserProvider>(
              builder: (context, userProv, _) {
                final isLoading = userProv
                    .isLoading; // pastikan ada getter ini di UserProvider

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'PT. Anugerah Langkat Makmur',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 49,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : () => _handleLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B62FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSyncDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: SizedBox(
              height: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Consumer<SinkronProvider>(
                    builder: (_, prov, __) {
                      final pct = (prov.progress * 100).toStringAsFixed(0);
                      return Column(
                        children: [
                          Text(prov.message ?? 'Menunggu...'),
                          const SizedBox(height: 8),
                          Text('$pct%'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
