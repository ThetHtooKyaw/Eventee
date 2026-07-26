import 'package:eventee/core/services/location_service.dart';
import 'package:eventee/core/themes/app_theme.dart';
import 'package:eventee/core/view_models/location_view_model.dart';
import 'package:eventee/core/widgets/bottom_nav_bar.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/firebase_options_loader.dart';
import 'package:eventee/src/auth/view_models/signup_view_model.dart';
import 'package:eventee/src/account/repo/account_service.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/auth/view_models/login_view_model.dart';
import 'package:eventee/src/create_event/repo/admin_service.dart';
import 'package:eventee/src/booking/view_models/booking_history_view_model.dart';
import 'package:eventee/src/home/view_models/home_view_model.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:eventee/src/auth/views/login_view.dart';
import 'package:eventee/src/booking/repo/booking_service.dart';
import 'package:eventee/src/onboarding/view_models/onboarding_view_model.dart';
import 'package:eventee/src/onboarding/views/onboarding_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must load .env before initializing Firebase
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: FirebaseOptionsLoader.currentPlatform);
  // await FirebaseAuth.instance.signOut();

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => AdminService()),
        Provider(create: (_) => LocationService()),
        Provider(create: (context) => AuthService()),
        Provider(create: (_) => BookingService()),
        Provider(create: (_) => AccountService()),

        ChangeNotifierProvider(
          create: (context) => LoginViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => SignUpViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              LocationViewModel(context.read<LocationService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              OnboardingViewModel(context.read<LocationViewModel>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AccountViewModel(context.read<AccountService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<AdminService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BookingHistoryViewModel(context.read<BookingService>()),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingColumn(message: 'App Loading');
          }

          if (snapshot.hasData && snapshot.data != null) {
            return const OnboardingView();
            // return const BottomNavBar();
          }

          return const LoginView();
        },
      ),
    );
  }
}
