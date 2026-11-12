import 'package:flutter/material.dart';
import 'register_view.dart';
import '../home/main_view.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool obscurePassword = true;
  bool isLoading = false;

  // Aquí recibimos la información del usuario autenticado.
  Map<String, dynamic>? loginResponse;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Ingresa tu correo y contraseña.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('Ingresa un correo electrónico válido.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      ApiService.accessToken = response['accessToken'];
      if (!mounted) return;
      setState(() {
        loginResponse = response;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainView(userData: response)),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF075E59);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4ED),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Bienvenido a Localy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Descubre experiencias auténticas y conecta con guías locales.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 38),

                const Text(
                  'Correo electrónico',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Contraseña',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) {
                    if (!isLoading) _login();
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          primaryColor.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 23,
                            width: 23,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes una cuenta?',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterView(),
                                ),
                              );
                            },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
