import 'package:eventee/core/services/location_service.dart';
import 'package:eventee/src/notification/repo/notification_service.dart';
import 'package:eventee/core/view_models/location_view_model.dart';
import 'package:eventee/src/notification/view_models/notification_view_model.dart';
import 'package:eventee/src/account/repo/account_service.dart';
import 'package:eventee/src/account/repo/payout_stepup_service.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/auth/repo/auth_service.dart';
import 'package:eventee/src/auth/view_models/forgot_password_view_model.dart';
import 'package:eventee/src/auth/view_models/login_view_model.dart';
import 'package:eventee/src/auth/view_models/signup_view_model.dart';
import 'package:eventee/src/event/repo/booked_event_service.dart';
import 'package:eventee/src/event/repo/create_event_service.dart';
import 'package:eventee/src/event/repo/event_service.dart';
import 'package:eventee/src/event/view_models/booked_event_history_view_model.dart';
import 'package:eventee/src/event/view_models/event_list_view_model.dart';
import 'package:eventee/src/favourite/services/favourite_service.dart';
import 'package:eventee/src/favourite/view_models/favourite_view_model.dart';
import 'package:eventee/src/home/view_models/home_view_model.dart';
import 'package:eventee/src/onboarding/repo/onboarding_service.dart';
import 'package:eventee/src/onboarding/view_models/onboarding_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class CoreProviders {
  static final List<SingleChildWidget> providers = [
    // Services
    Provider(create: (_) => AuthService()),
    Provider(create: (_) => NotificationService()),
    Provider(create: (_) => OnboardingService()),
    Provider(create: (_) => LocationService()),
    Provider(create: (_) => AccountService()),
    Provider(create: (_) => PayoutStepupService()),
    Provider(create: (_) => EventService()),
    Provider(create: (_) => CreateEventService()),
    Provider(create: (_) => FavouriteService()),
    Provider(create: (_) => BookedEventService()),

    // View Models
    ChangeNotifierProvider(
      create: (context) => LoginViewModel(context.read<AuthService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => ForgotPasswordViewModel(context.read<AuthService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => SignUpViewModel(context.read<AuthService>()),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          NotificationViewModel(context.read<NotificationService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => OnboardingViewModel(
        context.read<LocationViewModel>(),
        context.read<OnboardingService>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => LocationViewModel(context.read<LocationService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => AccountViewModel(context.read<AccountService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => EventListViewModel(context.read<EventService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => HomeViewModel(context.read<EventListViewModel>()),
    ),
    ChangeNotifierProvider(
      create: (context) => FavouriteViewModel(context.read<FavouriteService>()),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          BookedEventHistoryViewModel(context.read<BookedEventService>()),
    ),
  ];
}
