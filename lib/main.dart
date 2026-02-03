import 'package:eventee/core/themes/app_theme.dart';
import 'package:eventee/core/widgets/bottom_nav_bar.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/firebase_options.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/admin/repo/admin_service.dart';
import 'package:eventee/src/admin/view_models/upload_event_view_model.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:eventee/src/auth/view_models/login_view_model.dart';
import 'package:eventee/src/auth/view_models/signup_view_model.dart';
import 'package:eventee/src/auth/views/login_view.dart';
import 'package:eventee/src/booking/repo/booking_service.dart';
import 'package:eventee/src/booking/view_models/booking_history_view_model.dart';
import 'package:eventee/src/booking/view_models/event_details_view_model.dart';
import 'package:eventee/src/chat/repo/chat_service.dart';
import 'package:eventee/src/chat/view_models/chat_view_model.dart';
import 'package:eventee/src/home/viewa_models/home_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseAuth.instance.signOut();

  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => AdminService()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => BookingService()),
        Provider(create: (_) => ChatService()),

        // ViewModels
        ChangeNotifierProvider<UploadEventViewModel>(
          create: (context) =>
              UploadEventViewModel(context.read<AdminService>()),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(context.read<AdminService>()),
        ),
        ChangeNotifierProvider<EventDetailsViewModel>(
          create: (context) =>
              EventDetailsViewModel(context.read<BookingService>()),
        ),
        ChangeNotifierProvider<BookingHistoryViewModel>(
          create: (context) =>
              BookingHistoryViewModel(context.read<BookingService>()),
        ),
        ChangeNotifierProvider<AccountViewModel>(
          create: (context) => AccountViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatViewModel(context.read<ChatService>()),
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
      theme: AppTheme.darkTheme,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingColumn(message: 'App Loading');
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const BottomNavBar();
          }
          return const LoginView();
        },
      ),
    );
  }
}
