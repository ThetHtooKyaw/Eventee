import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/src/account/widgets/account_skeleton.dart';
import 'package:eventee/src/admin/views/upload_event_view.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:eventee/src/chat/views/chat_view.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountViewModel>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isScreenLoading = context.select<AccountViewModel, bool>(
      (vm) => vm.isScreenLoading,
    );
    final userData = context.select<AccountViewModel, AppUser?>(
      (vm) => vm.user,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Account", style: t.textTheme.titleMedium),
      ),
      body: isScreenLoading
          ? AccountSkeleton()
          : userData == null
          ? Center(child: Text('No user found!', style: t.textTheme.bodyLarge))
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppFormat.secondaryPadding,
              ),
              physics: NeverScrollableScrollPhysics(),
              children: [
                // Header
                _buildProfileHeader(
                  context,
                  t,
                  userData.username,
                  userData.email,
                  'photoUrl',
                ),
                const SizedBox(height: 20),

                // Account Info
                _buildMenuListItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile Information',
                  onTap: () {},
                ),

                _buildMenuListItem(
                  context,
                  icon: Icons.add,
                  title: 'Add Event',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UploadEventView(),
                    ),
                  ),
                ),

                _buildMenuListItem(
                  context,
                  icon: Icons.chat,
                  title: 'Chat With AI Assistant',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatView()),
                  ),
                ),
                const Divider(indent: 20, endIndent: 20),

                _buildMenuListItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {},
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData t,
    String userName,
    String userEmail,
    String photoUrl,
  ) {
    return Row(
      children: [
        // User Image
        CircleAvatar(
          radius: 40,
          backgroundImage: null,
          // backgroundImage: photoUrl.isNotEmpty ? (photoUrl) : null,
          backgroundColor: AppColor.white,
          child: const Icon(Icons.person, color: Colors.black),
        ),
        const SizedBox(width: 20),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              Text(
                userEmail,
                style: t.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColor.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: AppColor.textPrimary),
      onTap: onTap,
    );
  }
}
