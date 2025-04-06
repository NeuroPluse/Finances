import 'package:flutter/material.dart';
import 'package:task_1/screens/add_transaction_screen.dart';
import 'package:task_1/screens/auth_screen.dart';
import 'package:task_1/screens/home_screen.dart';
import 'package:task_1/screens/statistics_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/add_transaction':
        return MaterialPageRoute(builder: (_) => const AddTransactionScreen());
      case '/home':
        final args = settings.arguments as Map<String, dynamic>?;
        final userName = args?['userName'] as String? ?? 'User';
        return MaterialPageRoute(
            builder: (_) => HomeScreen(userName: userName));
      case '/statistics':
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Маршрут не найден')),
          ),
        );
    }
  }
}
