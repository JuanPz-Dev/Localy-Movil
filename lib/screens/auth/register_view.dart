import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showMessage('Completa todos los campos.');
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
      final response = await _authService.register(
        name: name,
        lastName: lastName,
        email: email,
        password: password,
      );

      if (!mounted) return;

      final userName = response['name'] ?? name;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '¡Cuenta creada correctamente, $userName! Ahora inicia sesión.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crear cuenta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Regístrate en Localy y comienza a descubrir nuevas experiencias.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel('Nombre'),
              _buildField(
                controller: nameController,
                hint: 'Ingresa tu nombre',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildLabel('Apellido'),
              _buildField(
                controller: lastNameController,
                hint: 'Ingresa tu apellido',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildLabel('Correo electrónico'),
              _buildField(
                controller: emailController,
                hint: 'ejemplo@correo.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _buildLabel('Contraseña'),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                enabled: !isLoading,
                decoration: _decoration(
                  hint: 'Crea una contraseña',
                  icon: Icons.lock_outline,
                ).copyWith(
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
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _register,
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
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes una cuenta?',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text(
                      'Inicia sesión',
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
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !isLoading,
      decoration: _decoration(hint: hint, icon: icon),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
