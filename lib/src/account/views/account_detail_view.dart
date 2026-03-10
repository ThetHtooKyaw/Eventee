import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/src/account/view_models/account_detail_view_model.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/account/widgets/account_bottonsheet.dart';
import 'package:eventee/src/account/widgets/account_menu.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountDetailView extends StatefulWidget {
  const AccountDetailView({super.key});

  @override
  State<AccountDetailView> createState() => _AccountDetailViewState();
}

class _AccountDetailViewState extends State<AccountDetailView> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<AccountDetailViewModel>();
    final accountVM = context.read<AccountViewModel>();
    final user = accountVM.user;
    if (user != null) {
      vm.nameController.text = user.username;
      vm.phNoController.text = user.phoneNumber;
      vm.setBirthday(user.dateOfBirth);
      vm.locationController.text = user.address;
    }
  }

  Future<void> _handleSave({
    required Future<void> Function() updateAction,
    bool requiresValidation = false,
  }) async {
    final vm = context.read<AccountDetailViewModel>();
    final accountVM = context.read<AccountViewModel>();

    if (requiresValidation && !vm.formKey.currentState!.validate()) return;

    await updateAction();

    if (vm.errorMessage != null) {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
      vm.setError(null);
    } else {
      AppSnackbars.showSuccessSnackbar(context, vm.successMessage!);
      await accountVM.loadUser(forceRefresh: true);
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _handlePickProfileImage(ImageProvider? avatarImage) {
    final vm = context.read<AccountDetailViewModel>();

    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (context) {
        return ChangeNotifierProvider<AccountDetailViewModel>.value(
          value: vm,
          child: AccountBottonsheet(
            height: MediaQuery.of(context).size.height * 0.95,
            title: 'Profile Image',
            onTap: () async {
              if (vm.profileImage == null) {
                AppSnackbars.showErrorSnackbar(
                  context,
                  'Please pick an image first.',
                );
                return;
              }
              await _handleSave(updateAction: vm.updateProfileImage);
            },
            child: Column(
              children: [
                // Image
                Center(
                  child: GestureDetector(
                    onTap: () => vm.pickProfileImage(),

                    child: _buildAvatar(avatarImage, radius: 140, iconSize: 60),
                  ),
                ),
                const SizedBox(height: 20),

                // Pick Button
                _buildActionButton('Pick Image', () => vm.pickProfileImage()),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.read<AccountDetailViewModel>();

    final userData = context.select<AccountViewModel, AppUser?>(
      (vm) => vm.user,
    );

    final avatarImage = vm.getAvatarImage(userData?.photoUrl ?? '');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 80,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: AppColor.placeholder.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 32),
        ),
        title: Text("Personal Information", style: t.textTheme.titleSmall),
      ),
      body: Form(
        key: vm.formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppFormat.primaryPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              Center(
                child: GestureDetector(
                  onTap: () => _handlePickProfileImage(avatarImage),
                  child: _buildAvatar(avatarImage),
                ),
              ),
              const SizedBox(height: 10),

              // Change Button
              _buildActionButton(
                'Change',
                () => _handlePickProfileImage(avatarImage),
              ),
              const SizedBox(height: 20),

              MenuCard(
                child: Column(
                  children: [
                    // Name
                    _buildPICard(
                      title: 'Name',
                      data: userData!.username,
                      onTap: () => _handleSave(
                        updateAction: vm.updateUsername,
                        requiresValidation: true,
                      ),
                      child: _buildTextField(
                        'Name',
                        vm.nameController,
                        'Name can\'t be empty',
                      ),
                    ),
                    _buildCustomDivider(),

                    // Email
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _buildPICard(
                        title: 'Email',
                        data: userData.email,
                        isReadOnly: true,
                        child: SizedBox(),
                      ),
                    ),
                    _buildCustomDivider(),

                    // Phone Number
                    _buildPICard(
                      title: 'Phone Number',
                      data: userData.phoneNumber,
                      onTap: () => _handleSave(
                        updateAction: vm.updatePhoneNumber,
                        requiresValidation: true,
                      ),
                      child: _buildTextField(
                        'Phone Number',
                        vm.phNoController,
                        'Phone number can\'t be empty',
                      ),
                    ),
                    _buildCustomDivider(),

                    // Birthday
                    _buildPICard(
                      title: 'Birthday',
                      data: vm.formatBirthday(
                        userData.dateOfBirth ?? DateTime.now(),
                      ),
                      onTap: () =>
                          _handleSave(updateAction: vm.updateDateOfBirth),
                      child: _buildDatePicker(),
                    ),
                    _buildCustomDivider(),

                    // Address
                    _buildPICard(
                      title: 'Address',
                      data: userData.address,
                      onTap: () => _handleSave(updateAction: vm.updateLocation),
                      child: _buildAddLocation(vm),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(
    ImageProvider? avatarImage, {
    double radius = 80,
    double iconSize = 40,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: avatarImage,
      backgroundColor: AppColor.placeholder.withOpacity(0.4),
      child: avatarImage == null
          ? Icon(Icons.person, color: Colors.black, size: iconSize)
          : null,
    );
  }

  Widget _buildActionButton(String label, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(70, 40),
        backgroundColor: AppColor.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppFormat.primaryPadding),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildPICard({
    required String title,
    required String data,
    bool isReadOnly = false,
    Future<void> Function()? onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: AppColor.placeholder.withOpacity(0.4),
        highlightColor: AppColor.placeholder.withOpacity(0.4),
        onTap: isReadOnly
            ? null
            : () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  isDismissible: false,
                  context: context,
                  builder: (context) {
                    return ChangeNotifierProvider<AccountDetailViewModel>.value(
                      value: context.read<AccountDetailViewModel>(),
                      child: AccountBottonsheet(
                        height: MediaQuery.of(context).size.height * 0.7,
                        title: title,
                        onTap: onTap,
                        child: child,
                      ),
                    );
                  },
                );
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: AppFormat.primaryPadding,
          ),
          child: Row(
            children: [
              Text(
                title,
                maxLines: 1,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  data,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColor.textPlaceholder,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              isReadOnly
                  ? const SizedBox.shrink()
                  : Icon(Icons.chevron_right, color: AppColor.textPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String? errorMessage,
  ) {
    return MenuCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppFormat.primaryPadding,
        ),
        child: Row(
          children: [
            Text(
              label,
              maxLines: 1,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 40),

            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return errorMessage;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Consumer<AccountDetailViewModel>(
      builder: (context, vm, child) {
        return Column(
          children: [
            MenuCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppFormat.secondaryPadding,
                  horizontal: AppFormat.primaryPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Birthday',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      vm.formatBirthday(vm.selectedBirthday ?? DateTime.now()),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColor.textPlaceholder,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(
                  AppFormat.primaryBorderRadius,
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                minimumDate: DateTime(1900),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (newDate) => vm.setBirthday(newDate),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddLocation(AccountDetailViewModel vm) {
    return Column(
      children: [
        MenuCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFormat.primaryPadding,
            ),
            child: Row(
              children: [
                Text(
                  'Address',
                  maxLines: 1,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: TextField(
                    controller: vm.locationController,
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        CSCPickerPlus(
          onCountryChanged: (value) => vm.setCountry(value),
          onStateChanged: (value) => vm.setState(value),
          onCityChanged: (value) => vm.setCity(value),
          dropdownDecoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(
              AppFormat.secondaryBorderRadius,
            ),
          ),
          disabledDropdownDecoration: BoxDecoration(
            color: AppColor.placeholder,
            borderRadius: BorderRadius.circular(
              AppFormat.secondaryBorderRadius,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDivider() {
    return const Divider(height: 0, thickness: 0.8, indent: 20, endIndent: 20);
  }
}
