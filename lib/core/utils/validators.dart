String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "E-mail jest wymagany";
  }
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  if (!emailRegex.hasMatch(value)) {
    return "Podaj poprawny adres e-mail";
  }
  // TODO: backend check
  return null;
}

String? usernameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Nazwa użytkownika jest wymagana";
  }
  // TODO: backend check
  return null;
}