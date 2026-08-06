import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/src/account/view_models/account_detail_view_model.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/account/widgets/account_bottonsheet.dart';
import 'package:eventee/src/account/widgets/account_menu.dart';
import 'package:eventee/src/account/widgets/personal_information_card.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class AccountDetailView extends StatefulWidget {
  const AccountDetailView({super.key});

  @override
  State<AccountDetailView> createState() => _AccountDetailViewState();
}

class _AccountDetailViewState extends State<AccountDetailView> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSave({
    required Future<bool> Function() updateAction,
    bool requiresValidation = false,
  }) async {
    final accountVM = context.read<AccountViewModel>();

    if (requiresValidation && !_formKey.currentState!.validate()) return;

    final success = await updateAction();

    if (!mounted) return;

    if (success) {
      await accountVM.loadUser(forceRefresh: true);
      Navigator.pop(context);
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
              await _handleSave(updateAction: vm.updateProfileAvatar);
            },
            child: Column(
              children: [
                // Image
                Center(
                  child: GestureDetector(
                    onTap: () => vm.pickProfileAvatar(),
                    child: _buildAvatar(avatarImage, radius: 140, iconSize: 60),
                  ),
                ),
                const SizedBox(height: 20),

                // Pick Button
                _buildActionButton('Pick Image', () => vm.pickProfileAvatar()),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<AccountDetailViewModel>();
    final userData = context.select<AccountViewModel, AppUser?>(
      (vm) => vm.user,
    );
    final profileAvatar = vm.getProfileAvatar(userData?.photoUrl ?? '');

    return Consumer<AccountDetailViewModel>(
      builder: (context, vm, child) {
        if (vm.successMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbars.showSuccessSnackbar(context, vm.successMessage!);
            vm.setSuccess(null);
          });
        }
        if (vm.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
            vm.setError(null);
          });
        }
        return child!;
      },
      child: Scaffold(
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
          title: Text(
            "Personal Information",
            style: theme.textTheme.titleSmall,
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppFormat.primaryPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image
                Center(
                  child: GestureDetector(
                    onTap: () => _handlePickProfileImage(vm, profileAvatar),
                    child: _buildAvatar(profileAvatar),
                  ),
                ),
                const SizedBox(height: 10),

                // Change Button
                _buildActionButton(
                  'Change',
                  () => _handlePickProfileImage(vm, profileAvatar),
                ),
                const SizedBox(height: 20),

                MenuCard(
                  color: theme.colorScheme.primary,
                  child: Column(
                    children: [
                      // Name
                      PersonalInformationItem(
                        title: 'Name',
                        data: userData!.username,
                        onTap: () => _handleSave(
                          updateAction: vm.updateUsername,
                          requiresValidation: true,
                        ),
                        child: _buildUsernameField(theme, vm),
                      ),
                      _buildCustomDivider(),

                      // Email
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: PersonalInformationItem(
                          title: 'Email',
                          data: userData.email,
                          isReadOnly: true,
                          child: SizedBox(),
                        ),
                      ),
                      _buildCustomDivider(),

                      // Phone Number
                      PersonalInformationItem(
                        title: 'Phone Number',
                        data: userData.phoneNumber,
                        onTap: () => _handleSave(
                          updateAction: vm.updatePhoneNumber,
                          requiresValidation: true,
                        ),
                        child: _buildPhoneNumberField(theme, vm),
                      ),
                      _buildCustomDivider(),

                      // Birthday
                      PersonalInformationItem(
                        title: 'Birthday',
                        data: vm.formatBirthday(
                          userData.dateOfBirth ?? DateTime.now(),
                        ),
                        onTap: () =>
                            _handleSave(updateAction: vm.updateDateOfBirth),
                        child: _buildDateOfBirthPicker(theme),
                      ),
                      _buildCustomDivider(),

                      // Address
                      PersonalInformationItem(
                        title: 'Address',
                        data: userData.address,
                        onTap: () =>
                            _handleSave(updateAction: vm.updateAddress),
                        child: _buildAddressPicker(theme, vm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(ThemeData theme, AccountDetailViewModel vm) {
    return InternationalPhoneNumberInput(
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onInputChanged: (PhoneNumber number) {
        vm.setPhoneNo(number.phoneNumber);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number can\'t be empty';
        }
        return null;
      },
      selectorConfig: SelectorConfig(
        selectorType: PhoneInputSelectorType.DIALOG,
        setSelectorButtonAsPrefixIcon: true,
        leadingPadding: 20,
        trailingSpace: true,
      ),
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      inputDecoration: InputDecoration(
        hintText: 'Enter your phone number',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: AppColor.textPlaceholder,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
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
    return Selector<AccountDetailViewModel, bool>(
      selector: (_, vm) => vm.isActionLoading,
      builder: (context, isActionLoading, child) {
        return ElevatedButton(
          onPressed: isActionLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(minimumSize: const Size(70, 40)),
          child: isActionLoading
              ? const CircularProgressIndicator()
              : Text(label),
        );
      },
    );
  }

  Widget _buildUsernameField(ThemeData theme, AccountDetailViewModel vm) {
    return PersonalInformationCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppFormat.primaryPadding,
        ),
        child: Row(
          children: [
            Text(
              'Username',
              maxLines: 1,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 40),

            Expanded(
              child: TextFormField(
                controller: vm.nameController,
                keyboardType: TextInputType.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name can\'t be empty';
                  }
                  if (value.length < 4) {
                    return 'Name must be at least 4 characters long';
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

  Widget _buildDateOfBirthPicker(ThemeData theme) {
    return Selector<AccountDetailViewModel, DateTime?>(
      selector: (_, vm) => vm.selectedBirthday,
      builder: (context, selectedBirthday, child) {
        final vm = context.read<AccountDetailViewModel>();

        return Column(
          children: [
            PersonalInformationCard(
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
                        color: Colors.black,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AppFormat.primaryBorderRadius,
                ),
              ),
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime:
                      selectedBirthday ??
                      DateTime(
                        DateTime.now().year - 18,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (newDate) => vm.setBirthday(newDate),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddressPicker(ThemeData theme, AccountDetailViewModel vm) {
    return Column(
      children: [
        PersonalInformationCard(
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
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: TextField(
                    controller: vm.addressController,
                    keyboardType: TextInputType.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black,
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
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
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
    return Divider(
      height: 0,
      thickness: 0.8,
      indent: 20,
      endIndent: 20,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }
}
