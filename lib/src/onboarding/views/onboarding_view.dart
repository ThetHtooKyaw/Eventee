import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/bottom_nav_bar.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:eventee/src/onboarding/view_models/onboarding_view_model.dart';
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
  final _formKey = GlobalKey<FormState>();
  List<Widget>? _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentProfileAvatar();
      _getCurrentLocation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages ??= _buildPages();
  }

  Future<void> _getCurrentProfileAvatar() async {
    final vm = context.read<OnboardingViewModel>();
    final success = await vm.initializeProfileAvatar();

    if (!mounted) return;

    if (!success) {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
    }
  }

  Future<void> _getCurrentLocation() async {
    final vm = context.read<OnboardingViewModel>();
    final success = await vm.initialLocation();

    if (!mounted) return;

    if (!success) {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
    }
  }

  Future<void> _submit() async {
    final vm = context.read<OnboardingViewModel>();
    final success = await vm.submitOnboardingData();

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
        (route) => false,
      );
    } else {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
    }
  }

  void _nextPage() {
    final vm = context.read<OnboardingViewModel>();
    if (_formKey.currentState!.validate()) {
      vm.nextPage();
    }
  }

  List<Widget> _buildPages() {
    return [
      _OnboardingStep(
        title: 'Show us your concert smile',
        description: 'Upload a profile picture to personalize your experience.',
        child: _ProfileImagePicker(),
      ),
      _OnboardingStep(
        title: 'What\'s Your Birthday?',
        description:
            'Some nightlife events, comedy clubs, and festivals have strict age limits. \nConfirm your birthday to view them.',
        child: _DateOfBirthPicker(),
      ),
      _OnboardingStep(
        title: 'Stay Connected',
        description:
            'Never miss an event with our timely notifications and updates.',
        child: _PhoneNumberField(),
      ),
      _OnboardingStep(
        title: 'Find Events Near You',
        description:
            'We will customize your dashboard with concerts and shows in this area.',
        child: _AddressPicker(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: AppColor.background,
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
                    final totalPages = context
                        .read<OnboardingViewModel>()
                        .totalPages;
                    return Column(
                      children: [
                        // Progress Indicator
                        LinearProgressIndicator(
                          value: (currentPage + 1) / totalPages,
                          backgroundColor: AppColor.textPlaceholder,
                          color: AppColor.secondary,
                          borderRadius: BorderRadius.circular(
                            AppFormat.secondaryBorderRadius,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Step Counter
                        Text(
                          'Step ${currentPage + 1} of $totalPages',
                          style: t.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary,
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
                    children: _pages!,
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                            ),
                            onPressed: currentPage == vm.totalPages - 1
                                ? _submit
                                : _nextPage,
                            child: Text(
                              currentPage == vm.totalPages - 1
                                  ? 'Submit'
                                  : 'Next',
                            ),
                          ),
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
                                  style: t.textTheme.titleSmall?.copyWith(
                                    color: AppColor.primary,
                                  ),
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
    return Selector<OnboardingViewModel, ImageProvider?>(
      selector: (_, vm) => vm.getProfileAvatar(),
      builder: (context, profileAvatar, child) {
        final vm = context.read<OnboardingViewModel>();
        return Column(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: profileAvatar,
              backgroundColor: AppColor.placeholder.withOpacity(0.4),
              child:
                  profileAvatar ==
                      null // Check if any image is present
                  ? const Icon(Icons.person, color: Colors.black, size: 40)
                  : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => vm.pickProfileAvatar(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(70, 40),
                backgroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppFormat.primaryPadding),
                ),
              ),
              child: const Text('Pick Image'),
            ),
          ],
        );
      },
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
        color: AppColor.white,
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
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
}

class _AddressPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<OnboardingViewModel>();

    return Selector<OnboardingViewModel, bool>(
      selector: (_, vm) => vm.isScreenLoading,
      builder: (context, isScreenLoading, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isScreenLoading
              ? Column(
                  key: const ValueKey('loading'),
                  children: [
                    SkeletonWidget(height: 50, width: double.infinity),
                    const SizedBox(height: 20),
                    SkeletonWidget(height: 50, width: double.infinity),
                    const SizedBox(height: 20),
                    SkeletonWidget(height: 50, width: double.infinity),
                  ],
                )
              : SelectState(
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
                  ).textTheme.bodyLarge?.copyWith(color: AppColor.primary),
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColor.textPlaceholder,
                  ),
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
        );
      },
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Title
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 10),

        // Description
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColor.primary),
        ),
        const SizedBox(height: 40),

        child,
      ],
    );
  }
}
