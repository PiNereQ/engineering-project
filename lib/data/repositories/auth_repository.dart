import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _userRepository = UserRepository();
  final storage = FlutterSecureStorage();

  AuthRepository();

  /// Get current user ID from Firebase Auth
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  /// Get Firebase Auth ID token (JWT)
  Future<String?> getIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  /// Get current Firebase user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> singUp({required String email, required String username, required String password, required String confirmPassword}) async {
    if (password != confirmPassword) {
      throw 'Podane hasła nie są takie same.';
    }
    
    // Check if username is already taken in API
    if (await _userRepository.isUsernameInUse(username)) {
      throw "Nazwa użytkownika jest zajęta";
    }
    
    try {
      // Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // Create user profile in your API
        await _userRepository.createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          username: username,
        );
        
        // Store Firebase token
        final token = await user.getIdToken();
        if (token != null) {
          await storage.write(key: 'auth_token', value: token);
        }
      }
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'weak-password':
          throw 'Podane hasło jest zbyt słabe.';
        case 'email-already-in-use':
          throw 'Podany adres e-mail jest już używany.';
        case 'invalid-email':
          throw 'Podany adres e-mail jest nieprawidłowy.';
        case 'too-many-requests':
          throw 'Zbyt wiele prób rejestracji, spróbuj ponownie za chwilę.';
        case 'network-request-failed':
          throw 'Nie udało się połączyć z siecią, spróbuj ponownie za chwilę lub sprawdź ustawienia połączenia.';
        default:
          throw 'Błąd rejestracji: ${e.message}';
      }
    } catch (e) {
      throw 'Błąd rejestracji: $e';
    }
  }

  Future<String> signIn(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user == null) {
        throw 'Nie udało się zalogować.';
      }
      
      // Get Firebase ID token
      final token = await user.getIdToken();
      if (token == null) {
        throw 'Nie udało się uzyskać tokenu.';
      }
      
      // Save token to secure storage
      await storage.write(key: 'auth_token', value: token);
      
      return token;
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
        case 'user-disabled':
          throw 'To konto zostało dezaktywowane. Logowanie nie jest możliwe.';        
        case 'invalid-email':
          throw 'Podany adres e-mail jest nieprawidłowy.';
        case 'too-many-requests':
          throw 'Zbyt wiele prób logowania, spróbuj ponownie za chwilę.';
        case 'network-request-failed':
          throw 'Nie udało się połączyć z siecią, spróbuj ponownie za chwilę lub sprawdź ustawienia połączenia.';
        case 'invalid-credential':
        case 'INVALID_LOGIN_CREDENTIALS':
        case 'user-not-found':
        case 'wrong-password':
          throw 'Podane dane logowania są nieprawidłowe.';
        default:
          throw 'Nie udało się zalogować. Spróbuj ponownie.';
      }
    } catch (e) {
      throw 'Błąd logowania: $e';
    }
  }

  Future<void> signOut() async {
    try {
      // Delete FCM token
      await FirebaseMessaging.instance.deleteToken();

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Delete token from secure storage
      await storage.delete(key: 'auth_token');
    } catch (e) {
      throw 'Błąd wylogowania: $e';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw 'Podany adres e-mail jest nieprawidłowy.';
        case 'user-not-found':
          throw 'Użytkownik z podanym adresem e-mail nie istnieje.';
        case 'too-many-requests':
          throw 'Zbyt wiele prób resetowania hasła, spróbuj ponownie za chwilę.';
        case 'network-request-failed':
          throw 'Nie udało się połączyć z siecią, spróbuj ponownie za chwilę lub sprawdź ustawienia połączenia.';
        default:
          throw 'Błąd resetowania hasła: ${e.message}';
      }
    } catch (e) {
      throw 'Błąd resetowania hasła: $e';
    }
  }
}