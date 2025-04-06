import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_1/models/transaction.dart';

import 'blocs/auth_bloc.dart';
import 'router.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactions');

  await Supabase.initialize(
    url: 'https://vxrlgsllgrnuhrsojikb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4cmxnc2xsZ3JudWhyc29qaWtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI4MDU0NzcsImV4cCI6MjA1ODM4MTQ3N30.rh6ToF9nKy6ZW-zdTpb44hyVh9yDZj3cPB3GBpi3UdM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authService: AuthService(supabase),
            supabaseService: SupabaseService(supabase),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Ваше Приложение',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
      ),
    );
  }
}
