import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_1/screens/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String userName;
  final String language;

  const WelcomeScreen(
      {super.key, required this.userName, this.language = 'English'});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
                userName: widget.userName, language: widget.language),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 100,
                color: Colors.blueAccent.shade700,
              ),
              const SizedBox(height: 24),
              Text(
                widget.language == 'English' ? 'Welcome!' : 'Добро пожаловать!',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.userName,
                style: GoogleFonts.poppins(
                    fontSize: 20, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(color: Colors.blueAccent.shade700),
              const SizedBox(height: 16),
              Text(
                widget.language == 'English'
                    ? 'Redirecting...'
                    : 'Перенаправление...',
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
