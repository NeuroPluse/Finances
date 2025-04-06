import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final Supabase _supabase;

  SupabaseService(this._supabase);

  Future<bool> isEmailVerified(String email, String pass) async {
    try {
      await _supabase.client.auth
          .signInWithPassword(email: email, password: pass);
      final user = _supabase.client.auth.currentUser;

      print('user: $user');

      if (user == null) {
        print('check');
        return false;
      }
      if (user.emailConfirmedAt != null) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error in isEmailVerified: $e');

      return false;
    }
  }
}

      // print('Current user in isEmailVerified: $user');
      // if (user == null) {
      //   print('No user found in isEmailVerified, returning false');
      //   return false;
      // }

      // print('Refreshing session before checking email verification');
      // await _supabase.client.auth.refreshSession();
      // final updatedUser = _supabase.client.auth.currentUser;
      // print('Updated user after refresh: $updatedUser');
      // if (updatedUser == null) {
      //   print('No user found after refresh, returning false');
      //   return false;
      // }

      // final isVerified = updatedUser.emailConfirmedAt != null;
      // print(
      //     'Email confirmed at: ${updatedUser.emailConfirmedAt}, isVerified: $isVerified');
      // return isVerified;
