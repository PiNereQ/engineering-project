import 'app_error_type.dart';

String chatErrorMessage(AppErrorType type) {
  switch (type) {
    case AppErrorType.noConnection:
      return 'Brak połączenia z internetem. Nie udało się załadować rozmowy.';
    case AppErrorType.timeout:
      return 'Czat chwilowo nie odpowiada. Spróbuj ponownie za moment.';
    case AppErrorType.notFound:
      return 'Nie udało się znaleźć tej rozmowy.';
    case AppErrorType.serverError:
      return 'Wystąpił błąd serwera podczas ładowania czatu.';
    case AppErrorType.unknown:
      return 'Nie udało się załadować rozmowy.';
  }
}

String couponListErrorMessage(AppErrorType type) {
  switch (type) {
    case AppErrorType.noConnection:
      return 'Brak połączenia z internetem. Nie udało się załadować kuponów.';
    case AppErrorType.timeout:
      return 'Ładowanie kuponów trwa zbyt długo. Spróbuj ponownie.';
    case AppErrorType.notFound:
      return 'Nie znaleziono kuponów.';
    case AppErrorType.serverError:
      return 'Wystąpił błąd serwera podczas ładowania kuponów.';
    case AppErrorType.unknown:
      return 'Nie udało się załadować kuponów.';
  }
}