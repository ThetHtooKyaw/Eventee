import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/services/app_links_service.dart';
import 'package:eventee/core/utils/bottom_nav_bar.dart';
import 'package:eventee/core/themes/app_theme.dart';
import 'package:eventee/core/utils/core_providers.dart';
import 'package:eventee/core/widgets/loading_indicator.dart';
import 'package:eventee/firebase_options_loader.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:eventee/src/auth/view_models/reset_password_view_model.dart';
import 'package:eventee/src/auth/views/login_view.dart';
import 'package:eventee/src/onboarding/views/onboarding_view.dart';
import 'package:eventee/src/auth/views/reset_password_view.dart';
import 'package:eventee/src/settings/view_models/theme_view_model.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
  );

  if (kDebugMode) {
    try {
      final token = await FirebaseAppCheck.instance.getToken(true);
      print("App Check initialized successfully! Token: $token");
    } catch (e) {
      print(
        "Token fetch triggered background logging. Check your system logs.",
      );
    }
  }

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        ...CoreProviders.providers,
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeViewModel, bool>(
      selector: (context, vm) => vm.isDarkMode,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    AppLinksService.instance.uriLinkStream.listen((Uri uri) {
      if (uri.queryParameters['mode'] == 'resetPassword') {
        String? oobCode = uri.queryParameters['oobCode'];

        if (oobCode != null && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) =>
                    ResetPasswordViewModel(context.read<AuthService>()),
                child: ResetPasswordView(oobCode: oobCode),
              ),
            ),
          );
        }
      }
    });
  }

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
