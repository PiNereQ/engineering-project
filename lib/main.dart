import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/data/repositories/auth_repository.dart';
import 'package:proj_inz/data/repositories/category_repository.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/presentation/screens/auth_screen.dart';
import 'package:proj_inz/presentation/screens/main_screen.dart';

import 'firebase_options.dart';

// Global debugging flags
bool debugSkipAuth = false; // Skip authentication in debug mode; Default to false

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51RZ6Tm4DImOdy65uRnbKVa6pT1KzVub777bSf0keLjSfqeGxK4gQwfr23Vh7viegnfDqh5SVQza5rEnnIPt8HKUR00KKyHv98E';
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Stripe.instance.applySettings();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => CouponRepository()),
        RepositoryProvider(create: (_) => UserRepository()),
        RepositoryProvider(create: (_) => ShopRepository()),
        RepositoryProvider(create: (_) => CategoryRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          RepositoryProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
           title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
            home: (kDebugMode && debugSkipAuth) ? const MainScreen() : (FirebaseAuth.instance.currentUser != null ? const MainScreen() : const AuthScreen()),
        ),
      ),
    );
  }
}
