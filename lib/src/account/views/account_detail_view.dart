import 'package:country_state_city_picker/country_state_city_picker.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountVM = context.read<AccountViewModel>();
      if (accountVM.user != null) {
        context.read<AccountDetailViewModel>().initialize(accountVM.user!);
      }
    });
  }

  Future<void> _handleSave({
    required Future<bool> Function() updateAction,
    bool requiresValidation = false,
  }) async {
    final vm = context.read<AccountDetailViewModel>();
    final accountVM = context.read<AccountViewModel>();

    if (requiresValidation && !vm.formKey.currentState!.validate()) return;

    final success = await updateAction();

    if (!mounted) return;

    if (success) {
      AppSnackbars.showSuccessSnackbar(context, vm.successMessage!);
      await accountVM.loadUser(forceRefresh: true);
      Navigator.pop(context);
    } else {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
    }
  }

  void _handlePickProfileImage(
    AccountDetailViewModel vm,
    ImageProvider? avatarImage,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: vm,
          child: AccountBottonsheet(
            height: MediaQuery.of(context).size.height * 0.95,
            title: 'Profile Image',
            onTap: () async {
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
    final vm = context.watch<AccountDetailViewModel>();
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
                  onTap: () => _handlePickProfileImage(vm, avatarImage),
                  child: _buildAvatar(avatarImage),
                ),
              ),
              const SizedBox(height: 10),

              // Change Button
              _buildActionButton(
                'Change',
                () => _handlePickProfileImage(vm, avatarImage),
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
                        t,
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
                        t,
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
                      child: _buildDatePicker(t),
                    ),
                    _buildCustomDivider(),

                    // Address
                    _buildPICard(
                      title: 'Address',
                      data: userData.address,
                      onTap: () => _handleSave(updateAction: vm.updateAddress),
                      child: _buildAddAddress(t, vm),
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
            : () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (sheetContext) {
                  return ChangeNotifierProvider.value(
                    value: context.read<AccountDetailViewModel>(),
                    child: AccountBottonsheet(
                      height: MediaQuery.of(sheetContext).size.height * 0.7,
                      title: title,
                      onTap: onTap,
                      child: child,
                    ),
                  );
                },
              ),
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
    ThemeData theme,
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
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 40),

            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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

  Widget _buildDatePicker(ThemeData theme) {
    return Selector<AccountDetailViewModel, DateTime?>(
      selector: (_, vm) => vm.selectedBirthday,
      builder: (context, selectedBirthday, child) {
        final vm = context.read<AccountDetailViewModel>();

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
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      vm.formatBirthday(selectedBirthday ?? DateTime.now()),
                      style: theme.textTheme.bodyLarge?.copyWith(
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

  Widget _buildAddAddress(ThemeData theme, AccountDetailViewModel vm) {
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: TextField(
                    controller: vm.addressController,
                    keyboardType: TextInputType.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
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

        SelectState(
          defaultValue: vm.country,
          defaultState: vm.state,
          defaultCity: vm.city,
          onCountryChanged: (value) => vm.setCountry(value),
          onStateChanged: (value) => vm.setState(value),
          onCityChanged: (value) => vm.setCity(value),
          spacing: 20,
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColor.primary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColor.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppFormat.secondaryBorderRadius,
              ),
              borderSide: BorderSide.none,
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
