String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Podaj adres e-mail";
  }

  final emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  if (!emailRegex.hasMatch(value)) {
    return "Podaj poprawny adres e-mail";
  }
  return null;
}

String? phoneNumberValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Podaj numer telefonu";
  }

  final countryCodeRegex = RegExp(r'^\+48*');
  if (!countryCodeRegex.hasMatch(value)) {
    return "Numer telefonu musi zaczynać się od +48";
  }

  final phoneRegex = RegExp(r'^\+48\d{9}$');
  if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
    return "Podaj poprawny numer telefonu w\nformacie +48 XXX XXX XXX";
  }
  return null;
}

String? usernameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Podaj nazwę użytkownika";
  }
  return null;
}

String? signUpPasswordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Podaj hasło.";
  }
  
  if (value.length < 8) {
    return "Hasło musi mieć conajmniej 12 znaków";
  }

  if (value.length > 4096) {
    return "Hasło musi mieć conajwyżej 4096 znaków";
  }

  RegExp digitRegex = RegExp(r'\d');
  if (!digitRegex.hasMatch(value)) {
    return "Hasło musi zawierać co najmniej jedną cyfrę";
  }

  return null;
}

String? signUpConfirmPasswordValidator(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return "Powtórz hasło";
  }
  if (value != password) {
    return "Hasła muszą być takie same!";
  }
  return null;
}
