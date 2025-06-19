import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {

  final _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> singUp({required String email, required String password, required String confirmPassword}) async {
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch(e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else {
        throw Exception('Error signing up: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch(e) {
      print(e.code);
      if (e.code == 'invalid-email') {
        throw AuthException('Podany adres e-mail jest nieprawidłowy.');
      } else if (e.code == 'too-many-requests') {
        throw AuthException('Zbyt wiele prób logowania, spróbuj ponownie za chwilę.');
      } else if (e.code == 'network-request-failed') {
        throw AuthException('Nie udało się połączyć z siecią, spróbuj ponownie za chwilę lub sprawdź ustawienia połączenia.');
      } else if (e.code == 'invalid-credential'
                  || e.code == 'INVALID_LOGIN_CREDENTIALS'
                  || e.code == 'user-not-found'
                  || e.code == 'user-not-found'
                  || e.code == 'wrong-password') {
        throw AuthException('Podane dane logowania są nieprawidłowe.');
      } else {
        throw AuthException('Błąd logowania: ${e.message}');
      }
    } catch (e) {
      throw AuthException('Błąd logowania: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      //print('Signed out successfully (repository)');
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }
}


class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}