import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/utils/bottom_nav_bar.dart';
import 'package:eventee/src/onboarding/view_models/onboarding_view_model.dart';
import 'package:eventee/src/onboarding/widgets/address_textfields_skeletion.dart';
import 'package:eventee/src/onboarding/widgets/onboarding_step_widget.dart';
import 'package:eventee/src/onboarding/widgets/profile_avatar_skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final OnboardingViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<OnboardingViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _pages = _buildPages();
    _viewModel.fetchInitialData();
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
    }
  }

  Future<void> _submit(BuildContext context) async {
    final success = await _viewModel.submitOnboardingData();

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
        (route) => false,
      );
    }
  }

  void _nextPage(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _viewModel.nextPage();
    }
  }

  List<Widget> _buildPages() {
    return [
      OnboardingStepWidget(
        title: 'Show us your concert smile',
        description: 'Upload a profile picture to personalize your experience.',
        child: _ProfileImagePicker(),
      ),
      OnboardingStepWidget(
        title: 'What\'s Your Birthday?',
        description:
            'Some nightlife events, comedy clubs, and festivals have strict age limits. \nConfirm your birthday to view them.',
        child: _DateOfBirthPicker(),
      ),
      OnboardingStepWidget(
        title: 'Stay Connected',
        description:
            'Never miss an event with our timely notifications and updates.',
        child: _PhoneNumberField(),
      ),
      OnboardingStepWidget(
        title: 'Find Events Near You',
        description:
            'We will customize your dashboard with concerts and shows in this area.',
        child: _AddressPicker(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<OnboardingViewModel>();

    return Scaffold(
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppFormat.secondaryPadding,
              horizontal: AppFormat.primaryPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Selector<OnboardingViewModel, int>(
                  selector: (_, vm) => vm.currentPage,
                  builder: (context, currentPage, child) {
                    final totalPages = _pages.length;

                    return Column(
                      children: [
                        // Progress Indicator
                        LinearProgressIndicator(
                          value: (currentPage + 1) / totalPages,
                          backgroundColor: AppColor.textPlaceholder,
                          color: AppColor.placeholder,
                          borderRadius: BorderRadius.circular(
                            AppFormat.secondaryBorderRadius,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Step Counter
                        Text(
                          'Step ${currentPage + 1} of $totalPages',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Content
                Expanded(
                  child: PageView(
                    controller: vm.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: vm.setCurrentPage,
                    children: _pages,
                  ),
                ),
                const SizedBox(height: 20),

                // Action Button
                Selector<OnboardingViewModel, int>(
                  selector: (_, vm) => vm.currentPage,
                  builder: (context, currentPage, child) {
                    return Column(
                      children: [
                        // Next Button
                        Selector<OnboardingViewModel, bool>(
                          selector: (_, vm) => vm.isActionLoading,
                          builder: (context, isActionLoading, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: currentPage == _pages.length - 1
                                    ? (isActionLoading
                                          ? null
                                          : () => _submit(context))
                                    : () => _nextPage(context),
                                child:
                                    isActionLoading &&
                                        currentPage == _pages.length - 1
                                    ? const CircularProgressIndicator()
                                    : Text(
                                        currentPage == _pages.length - 1
                                            ? 'Submit'
                                            : 'Next',
                                      ),
                              ),
                            );
                          },
                        ),

                        // Back Button
                        if (currentPage > 0)
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: vm.previousPage,
                                child: Text(
                                  'Back',
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileImagePicker extends StatelessWidget {
  const _ProfileImagePicker();

  @override
  Widget build(BuildContext context) {
    return Selector<OnboardingViewModel, bool>(
      selector: (_, vm) => vm.isScreenLoading,
      builder: (context, isScreenLoading, child) {
        if (isScreenLoading) {
          return ProfileAvatarSkeleton();
        }

        return child!;
      },
      child: Selector<OnboardingViewModel, ImageProvider?>(
        key: const ValueKey('content'),
        selector: (_, vm) => vm.getProfileAvatar(),
        builder: (context, profileAvatar, child) {
          final vm = context.read<OnboardingViewModel>();

          return Column(
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: profileAvatar,
                backgroundColor: AppColor.placeholder.withOpacity(0.4),
                child: profileAvatar == null
                    ? const Icon(Icons.person, color: Colors.black, size: 40)
                    : null,
              ),
              const SizedBox(height: 20),

              Selector<OnboardingViewModel, bool>(
                selector: (_, vm) => vm.isActionLoading,
                builder: (context, isActionLoading, child) {
                  return ElevatedButton(
                    onPressed: isActionLoading ? null : vm.pickProfileAvatar,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 40),
                    ),
                    child: isActionLoading
                        ? const CircularProgressIndicator()
                        : const Text('Pick Image'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DateOfBirthPicker extends StatelessWidget {
  const _DateOfBirthPicker();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<OnboardingViewModel>();

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
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
          initialDateTime: DateTime(
            DateTime.now().year - 18,
            DateTime.now().month,
            DateTime.now().day,
          ),
          minimumDate: DateTime(1900),
          maximumDate: DateTime.now(),
          onDateTimeChanged: (newDate) => vm.setBirthday(newDate),
        ),
      ),
    );
  }
}

class _PhoneNumberField extends StatelessWidget {
  const _PhoneNumberField();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<OnboardingViewModel>();

    return InternationalPhoneNumberInput(
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onInputChanged: (PhoneNumber number) {
        vm.setPhoneNo(number.phoneNumber);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Phone number can\'theme be empty';
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
}

class _AddressPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<OnboardingViewModel>();

    return Selector<OnboardingViewModel, bool>(
      selector: (_, vm) => vm.isScreenLoading,
      builder: (context, isScreenLoading, child) {
        if (isScreenLoading) {
          return AddressTextfieldsSkeletion();
        }
        return child!;
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: SelectState(
          key: ValueKey('${vm.country}-${vm.state}-${vm.city}'),
          defaultValue: vm.country,
          defaultState: vm.state,
          defaultCity: vm.city,
          onCountryChanged: (value) => vm.setCountry(value),
          onStateChanged: (value) => vm.setState(value),
          onCityChanged: (value) => vm.setCity(value),
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
      ),
    );
  }
}
