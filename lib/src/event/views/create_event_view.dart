import 'dart:io';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/event/view_models/create_event_view_model.dart';
import 'package:eventee/src/event/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleUpload() async {
    final vm = context.read<CreateEventViewModel>();

    if (vm.eventImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an event image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      await vm.uploadEventDetail();

      if (vm.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        vm.setError(null);
      } else {
        vm.resetForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.watch<CreateEventViewModel>();

    return Stack(
      children: [
        Scaffold(
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
                    _buildImagePicker(),
                    const SizedBox(height: 20),

                    // Event Title
                    Row(children: []),
                    Text(
                      'Event Title',
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: AppColor.textPlaceholder,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: vm.eventNameController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Event title is required';
                        }
                        return null;
                      },
                      decoration: InputDecoration(labelText: 'Enter Title'),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Date
                        CustomTextfield(
                          controller: vm.eventDateController,
                          label: 'Date',
                          hintText: 'dd MMM, yyyy',
                          icon: Icons.calendar_month,
                          onTap: () => vm.pickDate(context),
                        ),

                        // Category Dropdown
                        _buildCategoryDropDown(t),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Start Time
                        CustomTextfield(
                          controller: vm.eventStartTimeController,
                          label: 'Start Time',
                          hintText: 'hh:mm',
                          icon: Icons.timer_outlined,
                          onTap: () => vm.pickStartTime(context),
                        ),

                        // End Time
                        CustomTextfield(
                          controller: vm.eventEndTimeController,
                          label: 'End Time',
                          hintText: 'hh:mm',
                          icon: Icons.timer_outlined,
                          onTap: () => vm.pickEndTime(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Location TextField
                    _buildTextField(
                      t,
                      vm.eventLocationController,
                      TextInputType.text,
                      'Enter Location',
                      (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Event location is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Price TextField
                    _buildTextField(
                      t,
                      vm.ticketPriceController,
                      TextInputType.number,
                      'Enter Price',
                      (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ticket price is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description TextField
                    Text(
                      'Additional Information',
                      style: t.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: vm.eventDetailController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'What will be on that event...',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Button
                    Center(
                      child: ElevatedButton(
                        onPressed: vm.isActionLoading
                            ? null
                            : () => _handleUpload(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 60),
                        ),
                        child: Text('Upload'),
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

        if (vm.isActionLoading)
          LoadingOverlayColumn(message: 'Uploading event'),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Selector<CreateEventViewModel, File?>(
      selector: (context, vm) => vm.eventImage,
      builder: (context, eventImage, child) {
        return GestureDetector(
          onTap: () => context.read<CreateEventViewModel>().pickImage(),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border.all(color: AppColor.placeholder, width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: eventImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(
                        AppFormat.primaryPadding,
                      ),
                      child: Image.file(eventImage, fit: BoxFit.cover),
                    )
                  : Icon(Icons.camera_alt, size: 60),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropDown(ThemeData t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: t.textTheme.bodyMedium?.copyWith(
            color: AppColor.textPlaceholder,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        Selector<CreateEventViewModel, String?>(
          selector: (_, vm) => vm.selectedCategory,
          builder: (context, selectedCategory, child) {
            return FormField<String>(
              validator: (value) {
                if (selectedCategory == null) {
                  return 'Please select a category';
                }
                return null;
              },

              builder: (FormFieldState<String> state) {
                final vm = context.read<CreateEventViewModel>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      width: 174,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        border: state.hasError
                            ? Border.all(color: Colors.red, width: 1.0)
                            : null,
                        borderRadius: BorderRadius.circular(
                          AppFormat.primaryBorderRadius,
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
                                    style: t.textTheme.bodyLarge,
                                  ),
                                ),
                              )
                              .toList(),
                          dropdownColor: AppColor.white,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                            size: 40,
                          ),
                          style: t.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          hint: Text(
                            'Select Category',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.textTheme.bodyLarge?.copyWith(
                              color: AppColor.textPlaceholder,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsetsGeometry.only(top: 10),
                        child: Text(
                          state.errorText!,
                          style: t.textTheme.bodyLarge?.copyWith(
                            color: Colors.red,
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

  Widget _buildTextField(
    ThemeData t,
    TextEditingController controller,
    TextInputType keyboardType,
    String label,
    FormFieldValidator<String>? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.textTheme.bodyMedium?.copyWith(
            color: AppColor.textPlaceholder,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(labelText: label),
        ),
      ],
    );
  }
}
