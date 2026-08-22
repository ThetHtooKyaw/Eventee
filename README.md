# Eventee

Eventee is a cross-platform event discovery and ticketing application built with Flutter. Users can discover events, find events near their location, save favourites, purchase tickets securely, receive booking updates, and manage their tickets in one place.

The project demonstrates production-oriented mobile development with Firebase authentication and data, Stripe payments, push notifications, location services, deep links, and native calendar integration.

## Features

- Browse upcoming events with search and category-based discovery.
- Find events using location and geocoding services.
- View event details, schedules, pricing, and availability.
- Save and manage favourite events.
- Create events with image uploads and organizer information.
- Register and sign in with email/password or Google.
- Complete onboarding with profile, date-of-birth, phone, and address details.
- Purchase tickets through Stripe PaymentSheet.
- Store booking history with active, completed, and cancelled states.
- Add booked events to the Android device calendar.
- Receive booking confirmation and failure
- View notification history from Firestore.
- Support light and dark themes.

## Tech Stack

### Client

- **Flutter** and **Dart** for the cross-platform application
- **Provider** for dependency injection and state management
- **Material Design** for the UI system
- **Flutter Stripe** for secure payment collection
- **Geolocator** and **Geocoding** for location-aware experiences
- **Image Picker** and **Firebase Storage** for profile and event images
- **App Links** for deep-link handling
- **WebView** and **URL Launcher** for web-based flows
- **Shared Preferences** for local preferences

### Backend

- **Firebase Authentication** for email/password and Google sign-in
- **Cloud Firestore** for users, events, bookings, favourites, and notifications
- **Cloud Functions for Firebase** for trusted payment and notification operations
- **Firebase Cloud Messaging** for push notifications
- **Firebase App Check** to help protect backend resources
- **Stripe Connect** for organizer payout onboarding and transfers
- **Firebase Storage** for image hosting

### Native Integration

- Kotlin `MethodChannel` integration for adding events to the Android calendar
- Android notification channel configuration
- Android and iOS Firebase configuration

## Architecture: MVVM

Eventee follows a layered **Model-View-ViewModel (MVVM)** architecture. Presentation, state management, business workflows, and external services are separated so each layer remains focused and maintainable.

```text
View
	| User interaction and rendering
	v
ViewModel
	| Presentation state and use-case coordination
	v
Repository / Service
	| Firebase, Stripe, device, and HTTP operations
	v
External services
```

### Models

Models represent application data and serialization rules, including `EventModel`, `BookingModel`, `EventHistoryModel`, `AppUser`, and `NotificationModel`.

### Views

Views handle layout, interaction, navigation, and observing ViewModel state. They do not directly manage Firebase or Stripe workflows.

### ViewModels

ViewModels coordinate use cases and expose loading, error, success, and data state to the UI. They also manage reactive stream subscriptions.

Examples include `EventListViewModel`, `EventDetailsViewModel`, `BookedEventHistoryViewModel`, `NotificationViewModel`, `OnboardingViewModel`, and `AccountViewModel`.

### Services and Repositories

Services isolate infrastructure concerns from presentation code:

- `AuthService` handles authentication and user creation.
- `CreateEventService` handles event creation and image uploads.
- `BookedEventService` handles payments, bookings, calendar integration, and booking notifications.
- `NotificationService` handles notification permission and notification streams.
- `PayoutStepupService` starts Stripe organizer onboarding.

## Project Structure

```text
lib/
├── core/
│   ├── services/          Shared application and platform services
│   ├── themes/            Theme and design constants
│   ├── utils/             Providers, navigation, and utilities
│   ├── view_models/       Shared ViewModel behavior
│   └── widgets/           Reusable UI components
├── src/
│   ├── account/           Profile and payout features
│   ├── auth/              Authentication and account recovery
│   ├── event/             Discovery, creation, booking, and history
│   ├── favourite/         Saved events
│   ├── home/              Main dashboard
│   ├── notification/      Notification models, services, and screens
│   └── onboarding/        New-user setup
├── firebase_options_loader.dart
└── main.dart

functions/
└── index.js               Server-side payment and notification functions
```

## Key Workflows

### Ticket Purchase

1. The user selects an event and ticket quantity.
2. Flutter calls the regional `createPaymentIntent` function.
3. The function validates the authenticated user and organizer account.
4. Stripe PaymentSheet securely collects payment details.
5. The booking and confirmation notification are saved to Firestore.
6. The event can be added to the device calendar.

### Notifications

Notifications are stored under:

```text
users/{userId}/notifications/{notificationId}
```

Cloud Functions use the user’s FCM token for push delivery. The Flutter notification screen listens to the same Firestore collection, so notification history remains available after a push is dismissed.

## Getting Started

### Requirements

- Flutter SDK and a Dart SDK compatible with `pubspec.yaml`
- Android Studio or Xcode for platform builds
- Firebase project configuration
- Stripe account and test keys
- Firebase CLI for deploying Cloud Functions

### Installation

```bash
git clone <repository-url>
cd eventee
flutter pub get
```

Create a local `.env` file with the Firebase and Stripe values expected by `FirebaseOptionsLoader` and `main.dart`. Never commit this file or private API keys.

Run the application:

```bash
flutter run
```

Install backend dependencies and deploy Functions:

```bash
cd functions
npm ci
cd ..
firebase deploy --only functions
```

## Engineering Practices

- Clear separation of UI, state, and infrastructure responsibilities
- Reactive Firestore streams for live updates
- Explicit loading, success, and failure states
- Authenticated callable Functions for privileged operations
- Server-side Stripe secret handling
- Defensive validation of payment and authentication inputs
- Reusable widgets and centralized theme constants
- Environment-based configuration for secrets and Firebase settings

## Security Notes

- Keep Stripe secret keys in Firebase Functions secrets only.
- Do not commit `.env` files or private credentials.
- Configure Firestore Security Rules to protect profiles, bookings, and notifications.
- Validate authentication before accessing user or payment data in callable Functions.

## Status

Eventee is an active portfolio project demonstrating a complete event marketplace workflow from discovery through payment, booking history, and post-purchase notifications.
