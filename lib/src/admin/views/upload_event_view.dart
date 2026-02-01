import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/admin/view_models/params/upload_event_params.dart';
import 'package:eventee/src/admin/view_models/upload_event_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UploadEventView extends StatefulWidget {
  const UploadEventView({super.key});

  @override
  State<UploadEventView> createState() => _UploadEventViewState();
}

class _UploadEventViewState extends State<UploadEventView> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();
  final TextEditingController ticketPriceController = TextEditingController();
  final TextEditingController eventDetailController = TextEditingController();

  String? selectedCategory;
  final List<String> categories = ['Music', 'Sports', 'Art', 'Food'];

  @override
  void dispose() {
    super.dispose();
    eventDetailController.dispose();
    eventNameController.dispose();
    eventDateController.dispose();
    eventLocationController.dispose();
    ticketPriceController.dispose();
    eventDetailController.dispose();
  }

  void resetForm(UploadEventViewModel vm) {
    eventNameController.clear();
    eventDateController.clear();
    eventLocationController.clear();
    ticketPriceController.clear();
    eventDetailController.clear();
    setState(() {
      selectedCategory = null;
    });
    vm.clearEventImage();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
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
          child: Consumer<UploadEventViewModel>(
            builder: (context, vm, _) {
              if (vm.adminError != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(vm.adminError!.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                  vm.clearAdminError();
                });
              }

              if (vm.loading) {
                return LoadingColumn(message: 'Uploading event');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upload Image
                  Center(
                    child: GestureDetector(
                      onTap: () => vm.pickEventImage(),
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
                          child: vm.eventImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    AppFormat.primaryPadding,
                                  ),
                                  child: Image.file(
                                    vm.eventImage!,
                                    height: 300,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.camera_alt, size: 60),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Event Name TextField
                  _buildTextField(
                    t,
                    eventNameController,
                    TextInputType.text,
                    'Event Name',
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
                          eventDateController.text =
                              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                        });
                      }
                    },
                    controller: eventDateController,
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
                    eventLocationController,
                    TextInputType.text,
                    'Event Location',
                  ),
                  const SizedBox(height: 20),

                  // Ticket Price TextField
                  _buildTextField(
                    t,
                    ticketPriceController,
                    TextInputType.number,
                    'Ticket Price',
                  ),
                  const SizedBox(height: 20),

                  // Dropdown for Categories
                  Text('Select Category', style: t.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppFormat.secondaryPadding,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(
                        AppFormat.primaryBorderRadius,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        items: categories
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
                          style: t.textTheme.bodyLarge,
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Event Detail TextField
                  Text('Event Detail', style: t.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  TextField(
                    controller: eventDetailController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'What will be on that event...',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await vm.uploadEventDetail(
                          params: UploadEventParams(
                            eventImage: vm.eventImage!,
                            eventName: eventNameController.text.trim(),
                            eventDate: DateFormat(
                              'dd/MM/yyyy',
                            ).parse(eventDateController.text),
                            eventLocation: eventLocationController.text.trim(),
                            ticketPrice: double.parse(
                              ticketPriceController.text,
                            ),
                            eventDetail: eventDetailController.text.trim(),
                          ),
                        );

                        if (vm.adminError == null) {
                          resetForm(vm);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Event uploaded successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                      ),
                      child: Text('Upload'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    ThemeData t,
    TextEditingController controller,
    TextInputType keyboardType,
    String label,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(labelText: label),
        ),
      ],
    );
  }
}
