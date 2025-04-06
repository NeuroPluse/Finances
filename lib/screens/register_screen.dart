import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  final String language; 

  const RegisterScreen({super.key, required this.language});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.person_add_rounded,
                size: 80,
                color: Colors.blueAccent.shade700,
              ),
              const SizedBox(height: 24),
              Text(
                widget.language == 'English'
                    ? 'Create Account'
                    : 'Создать аккаунт',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.language == 'English'
                    ? 'Sign up to get started'
                    : 'Зарегистрируйтесь, чтобы начать',
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: widget.language == 'English' ? 'Name' : 'Имя',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.person_rounded,
                      color: Colors.blueAccent.shade700),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: widget.language == 'English'
                      ? 'Email'
                      : 'Электронная почта',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.email_rounded,
                      color: Colors.blueAccent.shade700),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText:
                      widget.language == 'English' ? 'Password' : 'Пароль',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock_rounded,
                      color: Colors.blueAccent.shade700),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.blueAccent.shade700,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                    Fluttertoast.showToast(
                      msg: widget.language == 'English'
                          ? "Please fill all fields"
                          : "Пожалуйста, заполните все поля",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.redAccent,
                      textColor: Colors.white,
                    );
                    return;
                  }
                  context.read<AuthBloc>().add(
                        RegisterEvent(
                          name: name,
                          email: email,
                          password: password,
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  widget.language == 'English'
                      ? 'Sign Up'
                      : 'Зарегистрироваться',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context
                    .read<AuthBloc>()
                    .add(const ConfirmEmailEvent(user: null)),
                child: Text(
                  widget.language == 'English'
                      ? 'Already have an account? Sign In'
                      : 'Уже есть аккаунт? Войти',
                  style: GoogleFonts.poppins(
                    color: Colors.blueAccent.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
