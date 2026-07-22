import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/src/account/views/account_detail_view.dart';
import 'package:eventee/src/account/widgets/account_menu.dart';
import 'package:eventee/src/account/widgets/account_skeleton.dart';
import 'package:eventee/src/create_event/views/create_event_view.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<AccountViewModel>();
    if (vm.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.loadUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final userData = context.select<AccountViewModel, AppUser?>(
      (vm) => vm.user,
    );
    final isScreenLoading = context.select<AccountViewModel, bool>(
      (vm) => vm.isScreenLoading,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.white,
        title: Text("Eventee Account", style: t.textTheme.titleSmall),
      ),
      body: isScreenLoading
          ? AccountSkeleton()
          : userData == null
          ? Center(child: Text('No user found!', style: t.textTheme.bodyLarge))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppFormat.primaryPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfile(userData, t),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AccountDetailView(),
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
                              builder: (context) => const CreateEventView(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () =>
                          context.read<AccountViewModel>().logoutUser(),
                      child: Text('Logout'),
                    ),
                  ),
                ],
              ),
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
