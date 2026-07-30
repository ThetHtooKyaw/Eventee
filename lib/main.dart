import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/services/location_service.dart';
import 'package:eventee/core/themes/app_theme.dart';
import 'package:eventee/core/view_models/location_view_model.dart';
import 'package:eventee/core/widgets/bottom_nav_bar.dart';
import 'package:eventee/core/widgets/loading_indicator.dart';
import 'package:eventee/firebase_options_loader.dart';
import 'package:eventee/src/auth/view_models/signup_view_model.dart';
import 'package:eventee/src/account/repo/account_service.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/auth/view_models/login_view_model.dart';
import 'package:eventee/src/event/repo/create_event_service.dart';
import 'package:eventee/src/event/view_models/booked_event_history_view_model.dart';
import 'package:eventee/src/home/view_models/home_view_model.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:eventee/src/auth/views/login_view.dart';
import 'package:eventee/src/event/repo/booked_event_service.dart';
import 'package:eventee/src/onboarding/repo/onboarding_service.dart';
import 'package:eventee/src/onboarding/view_models/onboarding_view_model.dart';
import 'package:eventee/src/onboarding/views/onboarding_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => OnboardingService()),
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
          create: (context) => OnboardingViewModel(
            context.read<LocationViewModel>(),
            context.read<OnboardingService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AccountViewModel(context.read<AccountService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(context.read<AdminService>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BookedEventHistoryViewModel(context.read<BookingService>()),
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
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }

        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: _isOnboardingComplete(),
            builder: (context, onboardingSnapshot) {
              if (onboardingSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return LoadingIndicator();
              }

              if (onboardingSnapshot.data == true) {
                return const BottomNavBar();
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return LoadingIndicator();
                  }

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final data =
                        userSnapshot.data!.data() as Map<String, dynamic>;

                    if (data.containsKey('phoneNumber') &&
                        data['phoneNumber'] != '') {
                      _setOnboardingComplete();

                      return const BottomNavBar();
                    }
                  }

                  return const OnboardingView();
                },
              );
            },
          );
        }
        return const LoginView();
      },
    );
  }

  Future<bool> _isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingComplete') ?? false;
  }

  Future<void> _setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
  }
}
