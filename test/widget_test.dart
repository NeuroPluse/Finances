import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_1/blocs/auth_bloc.dart';
import 'package:task_1/main.dart';
import 'package:task_1/services/auth_service.dart';
import 'package:task_1/services/supabase_service.dart';

void main() {
  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://vxrlgsllgrnuhrsojikb.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4cmxnc2xsZ3JudWhyc29qaWtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4MDU0NzcsImV4cCI6MjA1ODM4MTQ3N30.rh6ToF9nKy6ZW-zdTpb44hyVh9yDZj3cPB3GBpi3UdM',
    );
  });

  testWidgets('LoginScreen displays correctly', (WidgetTester tester) async {
    final supabase = Supabase.instance;
    final authService = AuthService(supabase);
    final supabaseService = SupabaseService(supabase);
    final authBloc = AuthBloc(
      authService: authService,
      supabaseService: supabaseService,
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
        ],
        child: const MaterialApp(
          home: MyApp(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Пароль'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('Нет аккаунта? Зарегистрируйтесь'), findsOneWidget);
  });
}
