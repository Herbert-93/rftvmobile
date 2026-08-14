/// Shared form validators used across the sign-up (and optionally login)
/// screens, so the rules live in exactly one place.
class Validators {
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Enter a password';
    if (value.length < 7) return 'Use at least 7 characters';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Add a lowercase letter';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Add an uppercase letter';
    if (!RegExp(r'\d').hasMatch(value)) return 'Add a number';
    if (!RegExp(r'[!@#\$&*~%^()\-_=+\[\]{};:,.<>/?]').hasMatch(value)) {
      return 'Add a symbol (e.g. ! @ # \$ %)';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || !value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter your name';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().length < 9)
      return 'Enter a valid phone number';
    return null;
  }
}
