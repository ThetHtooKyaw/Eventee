import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/src/account/repo/account_service.dart';
import 'package:eventee/src/account/view_models/account_detail_view_model.dart';
import 'package:eventee/src/account/views/account_detail_view.dart';
import 'package:eventee/src/account/widgets/account_menu.dart';
import 'package:eventee/src/account/widgets/account_skeleton.dart';
import 'package:eventee/src/event/repo/create_event_service.dart';
import 'package:eventee/src/event/views/create_event_view.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:eventee/src/auth/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventee/src/event/view_models/create_event_view_model.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  Future<void> _logout() async {
    final vm = context.read<AccountViewModel>();
    final success = await vm.logoutUser();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginView()),
        (Route<dynamic> route) => false,
      );
    } else {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Selector<AccountViewModel, String?>(
      selector: (_, vm) => vm.errorMessage,
      builder: (context, errorMessage, child) {
        if (errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbars.showErrorSnackbar(context, errorMessage);
            context.read<AccountViewModel>().setError(null);
          });
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColor.white,
            title: Text("Eventee Account", style: t.textTheme.titleSmall),
          ),
          body: Selector<AccountViewModel, bool>(
            selector: (_, vm) => vm.isScreenLoading,
            builder: (context, isScreenLoading, child) {
              if (isScreenLoading) {
                return AccountSkeleton();
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppFormat.primaryPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile
                    Selector<AccountViewModel, AppUser?>(
                      selector: (_, vm) => vm.user,
                      builder: (context, userData, child) {
                        if (userData == null) {
                          return _buildErrorProfile(t, context);
                        }

                        return _buildProfile(userData, t);
                      },
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'PERSONALIZE',
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: AppColor.textPlaceholder,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    MenuCard(
                      child: Column(
                        children: [
                          // Personal Information
                          MenuItem(
                            icon: Icons.person,
                            title: 'Personal Information',
                            onTap: () async {
                              final user = context
                                  .read<AccountViewModel>()
                                  .user;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (newContext) =>
                                      ChangeNotifierProvider<
                                        AccountDetailViewModel
                                      >(
                                        create: (context) =>
                                            AccountDetailViewModel(
                                              context.read<AccountService>(),
                                              user,
                                            ),
                                        child: const AccountDetailView(),
                                      ),
                                ),
                              );
                            },
                          ),
                          _buildCustomDivider(),

                          // Settings
                          MenuItem(
                            icon: Icons.settings,
                            title: 'Settings',
                            onTap: () {},
                          ),
                          _buildCustomDivider(),

                          // Billing
                          MenuItem(
                            icon: Icons.wallet,
                            title: 'Billing',
                            onTap: () {},
                          ),
                          _buildCustomDivider(),

                          // Favorites
                          MenuItem(
                            icon: Icons.bookmark,
                            title: 'Favorites',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'GENERAL',
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: AppColor.textPlaceholder,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    MenuCard(
                      child: Column(
                        children: [
                          // Notifications
                          MenuItem(
                            icon: Icons.notifications,
                            title: 'Notifications',
                            onTap: () {},
                          ),
                          _buildCustomDivider(),

                          // Language
                          MenuItem(
                            icon: Icons.language,
                            title: 'Language',
                            onTap: () {},
                          ),
                          _buildCustomDivider(),

                          // Theme Mode
                          MenuItem(
                            icon: Icons.wb_sunny,
                            title: 'Light/Dark Mode',
                            onTap: () {},
                          ),
                          _buildCustomDivider(),

                          // Add Event
                          MenuItem(
                            icon: Icons.add,
                            title: 'Add Event',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider<
                                      CreateEventViewModel
                                    >(
                                      create: (context) => CreateEventViewModel(
                                        context.read<CreateEventService>(),
                                      ),
                                      child: const CreateEventView(),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: Selector<AccountViewModel, bool>(
                        selector: (_, vm) => vm.isActionLoading,
                        builder: (context, isActionLoading, child) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: isActionLoading ? null : _logout,
                            child: isActionLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('Logout'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorProfile(ThemeData t, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppFormat.secondaryPadding,
        horizontal: AppFormat.primaryPadding,
      ),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Failed to load user data",
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          ElevatedButton(
            onPressed: () => context.read<AccountViewModel>().loadUser(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(AppUser userData, ThemeData t) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppFormat.secondaryPadding,
        horizontal: AppFormat.primaryPadding,
      ),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
      ),
      child: Row(
        children: [
          // Image
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(userData.photoUrl),
            backgroundColor: AppColor.placeholder.withOpacity(0.4),
            child: userData.photoUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.black)
                : null,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  userData.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  userData.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodyLarge?.copyWith(
                    color: AppColor.textPlaceholder,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDivider() {
    return const Divider(height: 0, thickness: 0.8, indent: 64, endIndent: 20);
  }
}
