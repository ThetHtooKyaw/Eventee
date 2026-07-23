import 'package:eventee/core/themes/app_theme.dart';
import 'package:eventee/core/widgets/bottom_nav_bar.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/firebase_options_loader.dart';
import 'package:eventee/src/account/repo/account_service.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/auth/view_models/login_view_model.dart';
import 'package:eventee/src/create_event/repo/admin_service.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:eventee/src/auth/views/login_view.dart';
import 'package:eventee/src/booking/repo/booking_service.dart';
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

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => AdminService()),
        Provider(create: (_) => AuthService(), lazy: false),
        Provider(create: (_) => BookingService()),
        Provider(create: (_) => AccountService()),
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
            return ChangeNotifierProvider<AccountViewModel>(
              create: (context) =>
                  AccountViewModel(context.read<AccountService>()),
              child: const BottomNavBar(),
            );
          }
          return ChangeNotifierProvider<LoginViewModel>(
            create: (context) => LoginViewModel(context.read<AuthService>()),
            child: const LoginView(),
          );
        },
      ),
    );
  }
}
