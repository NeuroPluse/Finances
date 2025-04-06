import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_1/blocs/auth_bloc.dart';
import 'package:task_1/screens/email_confirmation_screen.dart';
import 'package:task_1/screens/home_screen.dart';
import 'package:task_1/screens/login_screen.dart';
import 'package:task_1/screens/register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _currentLanguage = 'English'; 

  void _updateLanguage(String language) {
    setState(() {
      _currentLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: state.user.email?.split('@').first ?? 'User',
                language: _currentLanguage,
              ),
            ),
          );
        } else if (state is AuthError) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                errorMessage: state.message,
                onLanguageChanged: _updateLanguage,
              ),
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return Scaffold(
              backgroundColor: Colors.white, 
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .hourglass_empty_rounded, 
                      size: 80,
                      color:
                          Colors.blueAccent.shade700, 
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _currentLanguage == 'English'
                          ? 'Loading...'
                          : 'Загрузка...',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blueAccent.shade700),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is EmailUnverifiedState) {
            return EmailConfirmationScreen(
              user: state.user,
              email: state.email,
              password: state.password,
              showError: state.showError,
              language: _currentLanguage,
            );
          } else if (state is AuthRegister) {
            return RegisterScreen(
              language: _currentLanguage,
            );
          } else {
            return LoginScreen(
              onLanguageChanged: _updateLanguage,
            );
          }
        },
      ),
    );
  }
}
