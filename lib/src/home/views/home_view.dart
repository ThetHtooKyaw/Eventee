import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/app_error.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:eventee/src/admin/model/event.dart';
import 'package:eventee/src/booking/views/event_details_view.dart';
import 'package:eventee/src/home/viewa_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vmAction = context.read<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: AppFormat.primaryPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Location
              Row(
                children: [
                  Icon(Icons.location_on_outlined),
                  const SizedBox(width: 4),
                  Text('Thailand, Bangkok', style: t.textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 10),

              // User Greeting
              Text(
                'Hello, Tony',
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Events Suggestion
              Text(
                'There are 20 events around your location!',
                style: t.textTheme.bodyLarge?.copyWith(color: AppColor.primary),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Padding(
                padding: const EdgeInsets.only(right: AppFormat.primaryPadding),
                child: TextField(
                  controller: vmAction.searchController,
                  onChanged: (value) => vmAction.filterEvents(value),
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    hintText: 'Search an Event',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Categories
              SizedBox(
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vmAction.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final (icon, label) = vmAction.categories[index];

                    return _buildCategory(t, icon, label);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Event Title
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming Events', style: t.textTheme.titleMedium),
                    InkWell(
                      onTap: () {},
                      child: Text('See all', style: t.textTheme.bodyLarge),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Event List
              Consumer<HomeViewModel>(
                builder: (context, vm, child) {
                  if (vm.isScreenLoading) {
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildEventSkeletion();
                      },
                    );
                  }

                  if (vm.errorMessage != null) {
                    return AppError(errorMessage: vm.errorMessage!);
                  }

                  if (vm.events.isEmpty && !vm.isScreenLoading) {
                    return Center(
                      child: Text(
                        'No upcoming events!',
                        style: t.textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.events.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      EventModel event = vm.events[index];
                      String eventDate = vm.formatDate(event.eventDate);

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsView(event: event),
                          ),
                        ),
                        child: _buildEvents(t, event, eventDate),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventSkeletion() {
    return Padding(
      padding: const EdgeInsets.only(right: AppFormat.primaryPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonWidget(height: 200, width: double.infinity),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonWidget(height: 20, width: 100),
              SkeletonWidget(height: 20, width: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvents(ThemeData t, EventModel event, String eventDate) {
    return Padding(
      padding: const EdgeInsets.only(right: AppFormat.primaryPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(
                    AppFormat.primaryBorderRadius,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: event.eventImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) =>
                        SkeletonWidget(height: 200, width: double.infinity),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10, top: 10),
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppFormat.secondaryBorderRadius,
                    ),
                  ),
                  child: Text(
                    eventDate,
                    textAlign: TextAlign.center,
                    style: t.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(event.eventName, style: t.textTheme.titleSmall),
              Text(
                'B${event.ticketPrice}',
                style: t.textTheme.titleSmall?.copyWith(
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(ThemeData t, IconData icon, String label) {
    return Selector<HomeViewModel, String>(
      selector: (_, vm) => vm.selectedCategory,
      builder: (context, selectedCategory, child) {
        return GestureDetector(
          onTap: () => context.read<HomeViewModel>().filterByCategory(label),
          child: Container(
            padding: const EdgeInsets.all(AppFormat.secondaryPadding),
            decoration: BoxDecoration(
              color: selectedCategory == label ? AppColor.white : Colors.grey,
              borderRadius: BorderRadius.circular(
                AppFormat.primaryBorderRadius,
              ),
            ),
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                Text(label, style: t.textTheme.bodyLarge),
              ],
            ),
          ),
        );
      },
    );
  }
}
