import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/src/admin/views/upload_event_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventee/core/widgets/loading_column.dart';
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Account", style: t.textTheme.titleMedium),
      ),
      body: Consumer<AccountViewModel>(
        builder: (context, vm, child) {
          if (vm.loading) {
            return LoadingColumn(message: 'Loading account information');
          }

          if (vm.accountError != null) {
            return Center(child: Text('Error: ${vm.accountError!.message}'));
          }

          final userData = vm.user;
          final photoUrl = '';

          if (userData == null) {
            return const Center(child: Text("User data not found"));
          }

          return ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              // Header
              _buildProfileHeader(
                context,
                t,
                userData.username,
                userData.email,
                photoUrl,
              ),
              const SizedBox(height: 10),

              // Account Info
              Column(
                children: [
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

                  // _buildMenuListItem(
                  //   context,
                  //   icon: Icons.history,
                  //   title: 'Order History',
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => OrderHistoryView(),
                  //     ),
                  //   ),
                  // ),
                  const Divider(),

                  _buildMenuListItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => vm.logoutUser(),
                  child: Text('Logout'),
                ),
              ),
            ],
          );
        },
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
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // User Image
          CircleAvatar(
            radius: 40,
            backgroundImage: photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
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
                  style: t.textTheme.bodyLarge?.copyWith(
                    color: AppColor.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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
      title: Text(title, style: TextStyle(color: AppColor.textPrimary)),
      trailing: Icon(Icons.chevron_right, color: AppColor.textPrimary),
      onTap: onTap,
    );
  }
}
