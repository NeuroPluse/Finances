import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/auth_bloc.dart';

class EmailConfirmationScreen extends StatelessWidget {
  final dynamic user;
  final String email;
  final String password;
  final bool showError;
  final String language; 

  const EmailConfirmationScreen({
    super.key,
    required this.user,
    required this.email,
    required this.password,
    this.showError = false,
    required this.language,
  });

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
                Icons.email_rounded,
                size: 80,
                color: Colors.blueAccent.shade700,
              ),
              const SizedBox(height: 24),
              Text(
                language == 'English'
                    ? 'Verify Your Email'
                    : 'Подтвердите вашу почту',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                language == 'English'
                    ? 'We’ve sent a verification link to $email. Please check your inbox and verify your email.'
                    : 'Мы отправили ссылку для подтверждения на $email. Пожалуйста, проверьте ваш почтовый ящик и подтвердите email.',
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              if (showError) ...[
                const SizedBox(height: 16),
                Text(
                  language == 'English'
                      ? 'Email not verified yet. Please verify to continue.'
                      : 'Email еще не подтвержден. Пожалуйста, подтвердите, чтобы продолжить.',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        CheckEmailVerificationEvent(
                          user: user,
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
                  language == 'English'
                      ? 'I’ve Verified My Email'
                      : 'Я подтвердил(а) email',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(ConfirmEmailEvent(user: user)),
                child: Text(
                  language == 'English'
                      ? 'Back to Sign In'
                      : 'Вернуться к входу',
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
