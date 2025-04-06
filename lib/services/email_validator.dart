class EmailValidator {
  static bool validateEmail(String email) {
    email = email.trim();

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    print('Validating email: "$email"');
    final isValid = emailRegExp.hasMatch(email);
    print('Email valid: $isValid');
    return isValid;
  }

  static String? validateEmailString(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email не может быть пустым';
    }

    if (!validateEmail(email)) {
      return 'Некорректный формат email';
    }

    return null;
  }
}
