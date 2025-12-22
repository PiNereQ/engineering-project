import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_bloc.dart';
import 'package:proj_inz/bloc/number_verification/number_verification_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/repositories/auth_repository.dart';
import 'package:proj_inz/data/repositories/category_repository.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/presentation/screens/sign_in_screen.dart';
import 'package:proj_inz/presentation/screens/main_screen.dart';
import 'package:proj_inz/data/repositories/chat_repository.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_bloc.dart';
import 'firebase_options.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('BG message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  

  await dotenv.load(fileName: "assets/.env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  Stripe.publishableKey =
      'pk_test_51RZ6Tm4DImOdy65uRnbKVa6pT1KzVub777bSf0keLjSfqeGxK4gQwfr23Vh7viegnfDqh5SVQza5rEnnIPt8HKUR00KKyHv98E';
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
        RepositoryProvider(create: (_) => ChatRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              userRepository: context.read<UserRepository>(),
            )
          ),
          BlocProvider(
            create:
                (context) => NumberVerificationBloc(
                  userRepository: context.read<UserRepository>(),
                ),
          ),
          BlocProvider(
            create: (context) =>
              ChatListBloc(chatRepository: context.read<ChatRepository>()),         
          ),
          BlocProvider(
            create: (context) =>
                ChatUnreadBloc(chatRepository: context.read<ChatRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                return const MainScreen();
              } else {
                return const SignInScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
