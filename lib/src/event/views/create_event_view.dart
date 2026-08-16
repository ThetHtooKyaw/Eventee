import 'dart:io';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/utils/app_snackbars.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/event/view_models/create_event_view_model.dart';
import 'package:eventee/src/event/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  late final CreateEventViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<CreateEventViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.setFormKey(_formKey);
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

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.uploadEventDetail();

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _viewModel.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      _viewModel.onDatePicked(pickedDate);
    }
  }

  Future<void> _pickStartTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _viewModel.startTime ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      _viewModel.onStartTimePicked(pickedTime);
    }
  }

  Future<void> _pickEndTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_viewModel.endTime ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      _viewModel.onEndTimePicked(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<CreateEventViewModel>();

    return Selector<CreateEventViewModel, bool>(
      selector: (_, vm) => vm.isActionLoading,
      builder: (context, isActionLoading, child) {
        return Stack(
          children: [
            // Device Status Bar Color
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: theme.brightness == Brightness.light
                  ? SystemUiOverlayStyle.dark
                  : SystemUiOverlayStyle.light,
              child: child!,
            ),
            if (isActionLoading)
              const LoadingOverlayColumn(message: 'Uploading event'),
          ],
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppFormat.primaryPadding,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppFormat.secondaryPadding),

                  // Upload Image
                  Text(
                    'Event Image',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColor.textPlaceholder,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildImagePicker(theme, vm),
                  const SizedBox(height: 20),

                  // Event Title
                  CustomTextfield(
                    controller: vm.eventNameController,
                    label: 'Event Title',
                    keyboardType: TextInputType.text,
                    hintText: 'Enter event title',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Event title is required';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Organization Name
                  CustomTextfield(
                    controller: vm.organizationNameController,
                    label: 'Organization Name',
                    keyboardType: TextInputType.text,
                    hintText: 'Enter organization name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Organization name is required';
                      }
                      if (value.length < 3) {
                        return 'Organization name must be at least 3 characters long';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Organizer Name
                  CustomTextfield(
                    controller: vm.organizerNameController,
                    label: 'Organizer Name',
                    keyboardType: TextInputType.text,
                    hintText: 'Enter organizer name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Organizer name is required';
                      }
                      if (value.length < 3) {
                        return 'Organizer name must be at least 3 characters long';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      // Date
                      Expanded(
                        child: CustomTextfield(
                          controller: vm.dateController,
                          label: 'Date',
                          hintText: 'dd MMM, yyyy',
                          readOnly: true,
                          icon: Icons.calendar_month,
                          onTap: _pickDate,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Event date is required';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Category Dropdown
                      Expanded(child: _buildCategoryDropDown(theme)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      // Start Time
                      Expanded(
                        child: CustomTextfield(
                          controller: vm.startTimeController,
                          label: 'Start Time',
                          hintText: 'hh:mm',
                          readOnly: true,
                          icon: Icons.timer_outlined,
                          onTap: _pickStartTime,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Start time is required';
                            }
                            if (vm.endTime != null &&
                                vm.startTime != null &&
                                (vm.startTime!.isAfter(vm.endTime!) ||
                                    vm.startTime!.isAtSameMomentAs(
                                      vm.endTime!,
                                    ))) {
                              return 'Must be before end time';
                            }
                            if (DateUtils.isSameDay(
                                  vm.selectedDate,
                                  DateTime.now(),
                                ) &&
                                vm.startTime!.isBefore(DateTime.now())) {
                              return 'Must be after current time';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 20),

                      // End Time
                      Expanded(
                        child: CustomTextfield(
                          controller: vm.endTimeController,
                          label: 'End Time',
                          hintText: 'hh:mm',
                          readOnly: true,
                          icon: Icons.timer_outlined,
                          onTap: _pickEndTime,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'End time is required';
                            }
                            if (vm.startTime != null &&
                                vm.endTime != null &&
                                vm.endTime!.isBefore(vm.startTime!)) {
                              return 'Must be after start time';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Location TextField
                  CustomTextfield(
                    controller: vm.locationController,
                    label: 'Location',
                    keyboardType: TextInputType.streetAddress,
                    hintText: 'Enter location',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Event location is required';
                      }
                      if (value.length < 6) {
                        return 'Event location must be at least 6 characters long';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Price TextField
                  CustomTextfield(
                    controller: vm.ticketPriceController,
                    label: 'Price',
                    hintText: 'Enter price',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ticket price is required';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Please enter numbers only';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Description TextField
                  Text(
                    'Additional Information',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColor.textPlaceholder,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: vm.eventDetailController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'What will be on that event...',
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Action Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _handleUpload,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                      ),
                      child: const Text('Upload'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                      ),
                      child: Text('Back'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme, CreateEventViewModel vm) {
    return Selector<CreateEventViewModel, File?>(
      selector: (context, vm) => vm.eventImage,
      builder: (context, eventImage, _) {
        return FormField<File>(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (vm.eventImage == null) {
              return 'Please select an event image.';
            }

            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    await vm.pickImage();
                    state.didChange(vm.eventImage);
                  },
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      border: Border.all(color: AppColor.placeholder, width: 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: eventImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.file(
                              eventImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : const Center(child: Icon(Icons.camera_alt, size: 60)),
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
      },
    );
  }

  Widget _buildCategoryDropDown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColor.textPlaceholder,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        Selector<CreateEventViewModel, String?>(
          selector: (_, vm) => vm.selectedCategory,
          builder: (context, selectedCategory, child) {
            return FormField<String>(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (selectedCategory == null) {
                  return 'Please select a category';
                }

                return null;
              },
              builder: (state) {
                final vm = context.read<CreateEventViewModel>();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppFormat.secondaryBorderRadius,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          onChanged: (String? newValue) {
                            vm.setCategory(newValue);
                            state.didChange(newValue);
                          },
                          items: vm.categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              )
                              .toList(),
                          dropdownColor: theme.colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(
                            AppFormat.secondaryBorderRadius,
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                            size: 40,
                          ),
                          hint: Text(
                            'Select Category',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColor.textPlaceholder,
                            ),
                          ),
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
          },
        ),
      ],
    );
  }
}
