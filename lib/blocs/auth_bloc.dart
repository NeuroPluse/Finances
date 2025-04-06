import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final SupabaseService _supabaseService;

  AuthBloc({
    required AuthService authService,
    required SupabaseService supabaseService,
  })  : _authService = authService,
        _supabaseService = supabaseService,
        super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<CheckEmailVerificationEvent>(_onCheckEmailVerification);
    on<ConfirmEmailEvent>(_onConfirmEmail);
    on<LogoutEvent>(_onLogout);
    on<ShowRegisterEvent>(_onShowRegister);
    on<CheckSavedSessionEvent>(_onCheckSavedSession);
    on<RegisterButtonPressedEvent>(
        _onRegisterButtonPressed); 
    // on<CheckAuthEvent>(_onCheckAuth);
  }

  void _onShowRegister(ShowRegisterEvent event, Emitter<AuthState> emit) {
    print('Emitting AuthRegister');
    emit(AuthRegister());
  }

  void _onRegisterButtonPressed(
      RegisterButtonPressedEvent event, Emitter<AuthState> emit) {
    print('Emitting AuthRegister from RegisterButtonPressedEvent');
    emit(AuthRegister());
  }

  void _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      print(
          'Starting registration for email: ${event.email}, name: ${event.name}');
      final user = await _authService.register(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      print('User after register: $user');
      if (user == null) {
        print('User is null after registration');
        emit(AuthError(
            message:
                "Не удалось зарегистрировать пользователя: пользователь не возвращён"));
        return;
      }
      print(
          'Emitting EmailUnverifiedState with email: ${event.email}, user: $user');
      emit(EmailUnverifiedState(
          email: event.email, user: user, password: event.password));
    } catch (e) {
      print('Error in register: $e');
      if (e.toString().contains('SocketException')) {
        emit(AuthError(
            message:
                "Ошибка сети: проверьте подключение к интернету и попробуйте снова"));
      } else {
        emit(AuthError(message: "Ошибка регистрации: $e"));
      }
    }
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      print('Starting login for email: ${event.email}');
      final user = await _authService.login(
          email: event.email, password: event.password);

      await _authService.saveSession(
          event.email, event.password, event.rememberMe);

      print('User after login: $user');
      if (user == null) {
        print('User is null after login');
        emit(AuthError(
            message: "Не удалось войти в аккаунт: пользователь не возвращён"));
        return;
      }

      final isVerified =
          await _supabaseService.isEmailVerified(event.email, event.password);
      print('Email verified on login: $isVerified');
      if (isVerified) {
        print('Email is verified, emitting AuthAuthenticated with user: $user');
        emit(AuthAuthenticated(user: user));
      } else {
        print('Email not verified, redirecting to EmailConfirmationScreen');
        emit(EmailUnverifiedState(
            email: event.email,
            user: user,
            password: event.password,
            showError: false));
      }
    } catch (e) {
      print('Error in login: $e');
      if (e.toString().contains('SocketException')) {
        emit(AuthError(
            message:
                "Ошибка сети: проверьте подключение к интернету и попробуйте снова"));
      } else {
        emit(AuthError(message: "Ошибка входа: $e"));
      }
    }
  }

  void _onCheckEmailVerification(
      CheckEmailVerificationEvent event, Emitter<AuthState> emit) async {
    try {
      print('Checking email verification for user: ${event.user}');
      final isVerified =
          await _supabaseService.isEmailVerified(event.email, event.password);
      print('Email verified: $isVerified');
      if (isVerified) {
        print(
            'Email is verified, emitting AuthAuthenticated with user: ${event.user}');
        emit(AuthAuthenticated(user: event.user));
      } else {
        if (event.user == null) {
          print('User is null in CheckEmailVerificationEvent');
          emit(AuthError(message: "Пользователь не найден"));
          return;
        }
        print('Email not verified, staying on EmailConfirmationScreen');
        emit(EmailUnverifiedState(
            email: event.user.email ?? "unknown",
            user: event.user,
            password: event.password,
            showError: true));
      }
    } catch (e) {
      print('Error in check email verification: $e');
      if (e.toString().contains('SocketException')) {
        emit(AuthError(
            message:
                "Ошибка сети: проверьте подключение к интернету и попробуйте снова"));
      } else {
        emit(AuthError(message: "Ошибка проверки email: $e"));
      }
    }
  }

  void _onConfirmEmail(ConfirmEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      print('Confirming email for user: ${event.user}');
      await _authService.logout();
      print('Returning to login screen');
      emit(AuthInitial());
    } catch (e) {
      print('Error in confirm email: $e');
      emit(AuthError(
          message:
              "Ошибка при подтверждении почты, пожалуйста, войдите заново"));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    print('Processing LogoutEvent');

    try {
      await _authService.clearSession();
      print('Session cleared successfully');

      await _authService.logout();
      print('Supabase logout successful');

      print('Emitting AuthInitial after logout');
      emit(AuthInitial());
    } catch (e) {
      print('Error during logout: $e');

      emit(AuthInitial());
    }
  }

  void _onCheckSavedSession(
      CheckSavedSessionEvent event, Emitter<AuthState> emit) async {
    try {
      final currentState = state;
      if (currentState is AuthInitial && event.afterLogout) {
        print('Ignoring saved session check after logout');
        return;
      }

      final sessionData = await _authService.getSavedSession();
      final email = sessionData['email'];
      final password = sessionData['password'];

      if (email != null && password != null) {
        print('Found saved session for: $email, attempting auto-login');
        add(LoginEvent(email: email, password: password, rememberMe: true));
      } else {
        print('No saved session found');
      }
    } catch (e) {
      print('Error checking saved session: $e');
    }
  }
}
