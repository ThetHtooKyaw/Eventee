import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/view_appbar.dart';
import 'package:eventee/src/account/widgets/account_menu.dart';
import 'package:eventee/src/settings/view_models/theme_view_model.dart';
import 'package:eventee/src/settings/widgets/settings_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ViewAppbar(title: 'Settings', centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(AppFormat.primaryPadding),
        child: MenuCard(
          color: Theme.of(context).colorScheme.primary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notifications
              SettingsCard(
                icon: Icons.notifications,
                title: 'Notifications',
                switchValue: true,
                onChanged: (value) {
                  // Handle notification toggle
                },
              ),
              _buildCustomDivider(context),

              // Theme
              Selector<ThemeViewModel, bool>(
                selector: (context, vm) => vm.isDarkMode,
                builder: (context, isDarkMode, child) {
                  return SettingsCard(
                    icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    title: isDarkMode ? 'Dark Mode' : 'Light Mode',
                    switchValue: isDarkMode,
                    onChanged: (value) {
                      context.read<ThemeViewModel>().toggleTheme(value);
                    },
                  );
                },
              ),
              _buildCustomDivider(context),

              // Privacy Policy
              SettingsLinkCard(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  // Handle privacy policy tap
                },
              ),
              _buildCustomDivider(context),

              // Terms of Service
              SettingsLinkCard(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () {
                  // Handle terms of service tap
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDivider(context) {
    return Divider(
      height: 0,
      thickness: 0.8,
      indent: 64,
      endIndent: 20,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }
}
