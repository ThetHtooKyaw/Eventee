import 'dart:io';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/admin/view_models/upload_event_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadEventView extends StatefulWidget {
  const UploadEventView({super.key});

  @override
  State<UploadEventView> createState() => _UploadEventViewState();
}

class _UploadEventViewState extends State<UploadEventView> {
  Future<void> _handleUpload() async {
    final vm = context.read<UploadEventViewModel>();

    if (vm.eventImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an event image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (vm.formKey.currentState!.validate()) {
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
    final isActionLoading = context.select<UploadEventViewModel, bool>(
      (vm) => vm.isActionLoading,
    );
    final vm = context.read<UploadEventViewModel>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Upload Event',
              style: t.textTheme.titleLarge?.copyWith(color: AppColor.primary),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppFormat.primaryPadding,
              ),
              child: Form(
                key: vm.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upload Image
                    _buildEventImagePicker(),
                    const SizedBox(height: 20),

                    // Event Name TextField
                    _buildTextField(
                      t,
                      vm.eventNameController,
                      TextInputType.text,
                      'Event Name',
                      (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Event name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Event Date TextField
                    Text('Event Date', style: t.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    TextField(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2030),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            vm.eventDateController.text =
                                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                          });
                        }
                      },
                      controller: vm.eventDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Event Date',
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Event Location TextField
                    _buildTextField(
                      t,
                      vm.eventLocationController,
                      TextInputType.text,
                      'Event Location',
                      (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Event location is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Ticket Price TextField
                    _buildTextField(
                      t,
                      vm.ticketPriceController,
                      TextInputType.number,
                      'Ticket Price',
                      (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ticket price is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Dropdown for Categories
                    Text('Select Category', style: t.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _buildCategoryDropDown(t),
                    const SizedBox(height: 20),

                    // Event Detail TextField
                    Text('Event Detail', style: t.textTheme.titleMedium),
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
                        onPressed: isActionLoading
                            ? null
                            : () => _handleUpload(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 60),
                        ),
                        child: Text('Upload'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),

        if (isActionLoading) LoadingOverlayColumn(message: 'Uploading event'),
      ],
    );
  }

  Widget _buildEventImagePicker() {
    return Selector<UploadEventViewModel, File?>(
      selector: (context, vm) => vm.eventImage,
      builder: (context, eventImage, child) {
        return GestureDetector(
          onTap: () => context.read<UploadEventViewModel>().pickEventImage(),
          child: Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border.all(width: 3, color: Colors.black45),
              borderRadius: BorderRadius.circular(
                AppFormat.primaryBorderRadius,
              ),
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
    return Consumer<UploadEventViewModel>(
      builder: (context, vm, child) {
        return FormField<String>(
          validator: (value) {
            if (vm.selectedCategory == null) {
              return 'Please select a category';
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppFormat.secondaryPadding,
                  ),
                  width: double.infinity,
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
                      value: vm.selectedCategory,
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
                      hint: Text(
                        'Select Category',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: AppColor.placeholder,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  ),
                ),

                if (state.hasError)
                  Padding(
                    padding: const EdgeInsetsGeometry.only(top: 10),
                    child: Text(
                      state.errorText!,
                      style: t.textTheme.bodyLarge?.copyWith(color: Colors.red),
                    ),
                  ),
              ],
            );
          },
        );
      },
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
        Text(label, style: t.textTheme.titleMedium),
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
