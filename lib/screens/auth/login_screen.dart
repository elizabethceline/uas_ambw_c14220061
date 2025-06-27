import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../widgets/auth_widget.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState<bool>(false);

    Future<void> login() async {
      FocusManager.instance.primaryFocus?.unfocus();
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      final authService = Provider.of<AuthService>(context, listen: false);
      final error = await authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!context.mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      isLoading.value = false;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.mood, size: 80, color: Colors.blue.shade700),
              const SizedBox(height: 20),
              const Text(
                'Mood Journal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF212529),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 40),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Gunakan widget baru
                    EmailField(controller: emailController),
                    const SizedBox(height: 20),
                    // Gunakan widget baru
                    PasswordField(controller: passwordController),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              isLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade700,
                      ),
                    )
                  // Gunakan widget baru
                  : AuthButton(label: 'SIGN IN', onPressed: login),
              const SizedBox(height: 24),
              // Gunakan widget baru
              AuthRedirectLink(
                text: "Don't have an account? ",
                linkText: 'Sign Up',
                onTap: () => context.go('/signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
