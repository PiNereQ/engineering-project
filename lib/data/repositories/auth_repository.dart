import 'package:proj_inz/data/api/api_client.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  late final ApiClient _apiClient;
  final _userRepository = UserRepository();
  final storage = FlutterSecureStorage();

  AuthRepository() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://49.13.155.21:8000';
    _apiClient = ApiClient(baseUrl: baseUrl);
  }

  Future<void> singUp({required String email, required String username, required String password, required String confirmPassword}) async {
    if (password != confirmPassword) {
      throw 'Podane hasła nie są takie same.';
    }
    
    try {
      final response = await _apiClient.postJson('/auth/signup', {
        'email': email,
        'username': username,
        'password': password,
      });
      
      // Optionally create user profile if needed
      // await _userRepository.createUserProfile(...)
    } catch (e) {
      // Parse API errors and throw user-friendly messages
      if (e.toString().contains('409')) {
        throw 'Podany adres e-mail lub nazwa użytkownika jest już używany.';
      } else if (e.toString().contains('400')) {
        throw 'Nieprawidłowe dane rejestracji.';
      } else if (e.toString().contains('network')) {
        throw 'Nie udało się połączyć z siecią, spróbuj ponownie za chwilę lub sprawdź ustawienia połączenia.';
      }
      throw 'Błąd rejestracji: $e';
    }
  }

  Future<String> signIn(String email, String password) async {
    try {
      final response = await _apiClient.postJson('/auth/login', {
        'email': email,
        'password': password,
      });
      
      // Extract token from response
      if (response is Map && response.containsKey('token')) {
        final token = response['token'] as String;
        // Save token to secure storage
        await storage.write(key: 'auth_token', value: token);
        return token;
      }
      throw 'Brak tokenu w odpowiedzi serwera';
    } catch (e) {
      // Parse API errors and throw user-friendly messages
      if (e.toString().contains('401') || e.toString().contains('403')) {
        throw 'Podane dane logowania są nieprawidłowe.';
      } else if (e.toString().contains('429')) {
        throw 'Zbyt wiele prób logowania, spróbuj ponownie za chwilę.';
      } else if (e.toString().contains('network')) {
        throw 'Nie udało się połączyć z siecią, spróbuj ponownie za chwilę lub sprawdź ustawienia połączenia.';
      }
      throw 'Błąd logowania: $e';
    }
  }

  Future<void> signOut() async {
    try {
      // Delete token from secure storage
      await storage.delete(key: 'auth_token');
      
      // Optionally call API to invalidate token on server
      // await _apiClient.postJson('/auth/logout', {});
    } catch (e) {
      throw 'Błąd wylogowania: $e';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _apiClient.postJson('/auth/reset-password', {
        'email': email,
      });
    } catch (e) {
      // Parse API errors and throw user-friendly messages
      if (e.toString().contains('404')) {
        throw 'Użytkownik z podanym adresem e-mail nie istnieje.';
      } else if (e.toString().contains('429')) {
        throw 'Zbyt wiele prób resetowania hasła, spróbuj ponownie za chwilę.';
      } else if (e.toString().contains('network')) {
        throw 'Nie udało się połączyć z siecią, spróbuj ponownie za chwilę lub sprawdź ustawienia połączenia.';
      }
      throw 'Błąd resetowania hasła: $e';
    }
  }
}