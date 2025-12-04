import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _userRepository = UserRepository();

  Future<void> singUp({required String email, required String username, required String password, required String confirmPassword}) async {
    if (password != confirmPassword) {
      throw 'Podane hasła nie są takie same.';
    }
    
    if (await _userRepository.isUsernameInUse(username)) {
      throw "Nazwa użytkownika jest zajęta";
    }
    
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        await _userRepository.createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          username: username,
        );
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

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch(e) {
      switch (e.code) {
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
          throw 'Błąd logowania: ${e.message}';
      }
    } catch (e) {
      throw 'Błąd logowania: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      //print('Signed out successfully (repository)');
    } catch (e) {
      throw'Błąd wylogowania: $e';
    }
  }
}