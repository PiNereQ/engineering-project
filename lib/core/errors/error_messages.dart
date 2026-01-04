import 'app_error_type.dart';

String chatErrorMessage(AppErrorType type) {
  switch (type) {
    case AppErrorType.noConnection:
      return 'Brak połączenia z internetem. Nie udało się załadować czatu.';
    case AppErrorType.timeout:
      return 'Czat chwilowo nie odpowiada. Spróbuj ponownie za moment.';
    case AppErrorType.notFound:
      return 'Nie udało się znaleźć tego czatu.';
    case AppErrorType.serverError:
      return 'Wystąpił błąd serwera podczas ładowania czatu.';
    case AppErrorType.unknown:
      return 'Nie udało się załadować czatu.';
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

String searchErrorMessage(AppErrorType type) {
  switch (type) {
    case AppErrorType.noConnection:
      return 'Brak połączenia z internetem. Nie udało się załadować wyników.';
    case AppErrorType.timeout:
      return 'Wyszukiwanie trwa zbyt długo. Spróbuj ponownie.';
    case AppErrorType.notFound:
      return 'Nie udało się znaleźć wyników.';
    case AppErrorType.serverError:
      return 'Wystąpił błąd serwera podczas wyszukiwania.';
    case AppErrorType.unknown:
      return 'Nie udało się załadować wyników wyszukiwania.';
  }
}

String addCouponErrorMessage(AppErrorType type) {
  switch (type) {
    case AppErrorType.noConnection:
      return 'Brak połączenia z internetem. Nie udało się dodać kuponu.';
    case AppErrorType.timeout:
      return 'Dodawanie kuponu trwa zbyt długo. Spróbuj ponownie.';
    case AppErrorType.notFound:
      return 'Nie udało się dodać kuponu.';
    case AppErrorType.serverError:
      return 'Wystąpił błąd serwera podczas dodawania kuponu.';
    case AppErrorType.unknown:
      return 'Nie udało się dodać kuponu.';
  }
}
