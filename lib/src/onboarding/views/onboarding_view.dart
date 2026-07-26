import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:eventee/src/onboarding/view_models/onboarding_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocation();
    });
  }

  Future<void> getCurrentLocation() async {
    final vm = context.read<OnboardingViewModel>();
    final success = await vm.initialLocation();

    if (!mounted) return;

    if (!success) {
      AppSnackbars.showErrorSnackbar(context, vm.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppFormat.secondaryPadding,
                horizontal: AppFormat.primaryPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Progress Indicator
                  LinearProgressIndicator(
                    value: (vm.currentPage + 1) / vm.totalPages,
                    backgroundColor: AppColor.textPlaceholder,
                    color: AppColor.secondary,
                    borderRadius: BorderRadius.circular(
                      AppFormat.secondaryBorderRadius,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Step ${vm.currentPage + 1} of ${vm.totalPages}',
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Content
                  Expanded(
                    child: PageView(
                      controller: vm.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          vm.currentPage = index;
                        });
                      },
                      children: [_buildLocationStep(t, vm)],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                      ),
                      onPressed: vm.nextPage,
                      child: const Text('Next'),
                    ),
                  ),
                  vm.currentPage == 0
                      ? const SizedBox.shrink()
                      : const SizedBox(height: 10),

                  vm.currentPage == 0
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: vm.previousPage,
                          child: Text(
                            'Back',
                            style: t.textTheme.titleSmall?.copyWith(
                              color: AppColor.primary,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            if (vm.isScreenLoading)
              LoadingOverlayColumn(message: 'Fetching Location'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep(ThemeData theme, OnboardingViewModel vm) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Title
        Text(
          'Find events near you!',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 10),

        Text(
          'We will customize your dashboard with concerts and shows in this area.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColor.primary),
        ),
        const SizedBox(height: 40),

        if (vm.isScreenLoading)
          Column(
            children: [
              SkeletonWidget(height: 50, width: double.infinity),
              const SizedBox(height: 20),
              SkeletonWidget(height: 50, width: double.infinity),
              const SizedBox(height: 20),
              SkeletonWidget(height: 50, width: double.infinity),
            ],
          )
        else
          SelectState(
            key: ValueKey('${vm.country}-${vm.state}-${vm.city}'),
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
}
