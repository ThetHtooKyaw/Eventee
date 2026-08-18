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
  late final AccountDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<AccountDetailViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.errorMessage != null && mounted) {
      AppSnackbars.showErrorSnackbar(context, _viewModel.errorMessage!);
      _viewModel.setError(null);
    } else if (_viewModel.successMessage != null && mounted) {
      AppSnackbars.showSuccessSnackbar(context, _viewModel.successMessage!);
      _viewModel.setSuccess(null);
    }
  }

  Future<void> _handleSave({
    required Future<bool> Function() updateAction,
  }) async {
    final accountVM = context.read<AccountViewModel>();

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
        title: Text("Personal Information", style: theme.textTheme.titleSmall),
      ),
      body: SingleChildScrollView(
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
                    onTap: () => _handleSave(updateAction: vm.updateUsername),
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
                    onTap: () =>
                        _handleSave(updateAction: vm.updatePhoneNumber),
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
                    child: _buildDateOfBirthPicker(theme, vm),
                  ),
                  _buildCustomDivider(),

                  // Address
                  PersonalInformationItem(
                    title: 'Address',
                    data: userData.address,
                    onTap: () => _handleSave(updateAction: vm.updateAddress),
                    child: _buildAddressPicker(theme, vm),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildPhoneNumberField(ThemeData theme, AccountDetailViewModel vm) {
    return InternationalPhoneNumberInput(
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onInputChanged: (PhoneNumber number) {
        vm.setPhoneNo(number.phoneNumber);
      },
      onInputValidated: (bool value) {
        vm.setPhoneNumberValidity(value);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number can\'t be empty';
        }
        if (!vm.isPhoneNumberValid) {
          return 'Please enter a valid phone number for the selected country.';
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

  Widget _buildDateOfBirthPicker(ThemeData theme, AccountDetailViewModel vm) {
    return FormField<DateTime>(
      initialValue: vm.selectedBirthday,
      validator: (value) {
        if (value == null) {
          return 'Please select your date of birth.';
        }
        final now = DateTime.now();
        final eighteenYearsAgoExact = DateTime(
          now.year - 18,
          now.month,
          now.day,
        );
        if (value.isAfter(eighteenYearsAgoExact)) {
          return 'You must be at least 18 years old.';
        }

        return null;
      },
      builder: (state) {
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
                      vm.formatBirthday(state.value ?? DateTime.now()),
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
                  initialDateTime: vm.selectedBirthday,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (newDate) {
                    vm.setBirthday(newDate);
                    state.didChange(newDate);
                  },
                ),
              ),
            ),

            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: Text(
                  state.errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAddressPicker(ThemeData theme, AccountDetailViewModel vm) {
    return FormField<String>(
      validator: (_) {
        if (vm.country == null || vm.country!.isEmpty) {
          return 'Please select a country.';
        }
        if (vm.state == null || vm.state!.isEmpty) {
          return 'Please select a state.';
        }
        if (vm.city == null || vm.city!.isEmpty) {
          return 'Please select a city.';
        }

        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: TextFormField(
                        controller: vm.addressController,
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
              key: ValueKey('${vm.country}-${vm.state}-${vm.city}'),
              defaultValue: vm.country,
              defaultState: vm.state,
              defaultCity: vm.city,
              onCountryChanged: (value) {
                vm.setCountry(value);
                state.didChange(value);
              },
              onStateChanged: (value) {
                vm.setState(value);
                state.didChange(value);
              },
              onCityChanged: (value) {
                vm.setCity(value);
                state.didChange(value);
              },
              spacing: 20,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.black),
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColor.textPlaceholder),
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

            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: Text(
                  state.errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
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
