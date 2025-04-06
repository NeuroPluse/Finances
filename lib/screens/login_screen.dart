import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  final String? errorMessage;
  final Function(String)? onLanguageChanged;

  const LoginScreen({super.key, this.errorMessage, this.onLanguageChanged});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedLanguage = 'English';
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    if (widget.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(
          msg: widget.errorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
      });
    }
  }

  @override
  void dispose() {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'English',
                        label: Text('English'),
                      ),
                      ButtonSegment<String>(
                        value: 'Russian',
                        label: Text('Русский'),
                      ),
                    ],
                    selected: {_selectedLanguage},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedLanguage = newSelection.first;
                      });
                      widget.onLanguageChanged?.call(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.blueAccent.shade700,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: Colors.blueAccent.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.lock_rounded,
                size: 80,
                color: Colors.blueAccent.shade700,
              ),
              const SizedBox(height: 24),
              Text(
                _selectedLanguage == 'English'
                    ? 'Welcome Back!'
                    : 'С возвращением!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedLanguage == 'English'
                    ? 'Sign in to continue'
                    : 'Войдите, чтобы продолжить',
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: _selectedLanguage == 'English'
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
                      _selectedLanguage == 'English' ? 'Password' : 'Пароль',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: Colors.blueAccent.shade700,
                  ),
                  Text(
                    _selectedLanguage == 'English'
                        ? 'Remember Me'
                        : 'Запомнить меня',
                    style: GoogleFonts.poppins(color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  if (email.isEmpty || password.isEmpty) {
                    Fluttertoast.showToast(
                      msg: _selectedLanguage == 'English'
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
                        LoginEvent(
                          email: email,
                          password: password,
                          rememberMe: _rememberMe,
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
                  _selectedLanguage == 'English' ? 'Sign In' : 'Войти',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const ShowRegisterEvent()),
                child: Text(
                  _selectedLanguage == 'English'
                      ? 'Don’t have an account? Sign Up'
                      : 'Нет аккаунта? Зарегистрируйтесь',
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
