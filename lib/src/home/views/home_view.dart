import 'package:cached_network_image/cached_network_image.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/app_error.dart';
import 'package:eventee/core/widgets/skeleton_widget.dart';
import 'package:eventee/src/admin/model/event.dart';
import 'package:eventee/src/booking/views/event_details_view.dart';
import 'package:eventee/src/chat/views/chat_view.dart';
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

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatView()),
        ),
        backgroundColor: AppColor.white,
        child: const Icon(Icons.chat, color: AppColor.primary),
      ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Background Color
                  Container(
                    height: 146,
                    width: double.infinity,
                    color: AppColor.primary,
                  ),

                  // Header
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppFormat.primaryPadding,
                      ),
                      child: _buildHeader(t),
                    ),
                  ),

                  // Search Bar
                  Positioned(
                    bottom: 26,
                    right: AppFormat.primaryPadding,
                    left: AppFormat.primaryPadding,
                    child: Transform.translate(
                      offset: Offset(0, 25),
                      child: _buildSearchBar(vmAction),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppFormat.primaryPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppFormat.primaryPadding,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: vmAction.categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final (icon, label) = vmAction.categories[index];

                        return _buildCategory(t, icon, label);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Event Title
                  _buildTitle(t, 'Upcoming Events', () {}),
                  const SizedBox(height: 20),

                  // Event List
                  SizedBox(
                    height: 310,
                    child: Consumer<HomeViewModel>(
                      builder: (context, vm, child) {
                        if (vm.isScreenLoading) {
                          return ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppFormat.primaryPadding,
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 20),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: AppFormat.primaryPadding,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: vm.events.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 20),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Location
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Location',
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColor.white,
                ),
              ),
              // TODO: Get User Location
              Text(
                'Thailand, Bangkok',
                style: t.textTheme.titleMedium?.copyWith(color: AppColor.white),
              ),
            ],
          ),
        ),

        // TODO: Implement Notification Feature
        // Notification
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none_outlined, size: 32),
        ),
      ],
    );
  }

  Widget _buildSearchBar(HomeViewModel vmAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: vmAction.searchController,
            onChanged: (value) => vmAction.filterEvents(value),
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search, color: AppColor.primary),
              // TODO: Implement Filter Feature
              suffixIcon: IconButton(
                onPressed: () {},
                icon: Icon(Icons.filter_list, color: AppColor.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.primary, width: 1.5),
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColor.primary, width: 1.5),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildTitle(ThemeData t, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppFormat.primaryPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              'See all',
              style: t.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColor.primary,
              ),
            ),
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
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColor.primary,
                foregroundColor: AppColor.white,
                child: Icon(icon),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: t.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventSkeletion() {
    return Container(
      padding: const EdgeInsets.all(AppFormat.secondaryPadding),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.placeholder, width: 0.5),
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonWidget(height: 180, width: 300),
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
    return Container(
      padding: const EdgeInsets.all(AppFormat.secondaryPadding),
      width: 320,
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.placeholder, width: 0.5),
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Event Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(
                  AppFormat.primaryBorderRadius - 6,
                ),
                child: CachedNetworkImage(
                  imageUrl: event.eventImage,
                  height: 180,
                  width: 300,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) =>
                      SkeletonWidget(height: 180, width: 300),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              // TODO: Change to Category
              Container(
                margin: const EdgeInsets.only(left: 10, top: 10),
                width: 50,
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(
                    AppFormat.secondaryBorderRadius - 6,
                  ),
                ),
                child: Text(
                  eventDate,
                  textAlign: TextAlign.center,
                  style: t.textTheme.bodyLarge?.copyWith(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Event Name
          Text(
            event.eventName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Event Location, Date & Time
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 20),
              const SizedBox(width: 6),
              Text(
                event.eventLocation,
                style: t.textTheme.bodyLarge?.copyWith(
                  color: AppColor.textPlaceholder,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 20),

              Icon(Icons.timer, size: 20),
              const SizedBox(width: 6),
              // TODO: Get Event Time
              Text(
                '$eventDate - 10:00 PM',
                style: t.textTheme.bodyLarge?.copyWith(
                  color: AppColor.textPlaceholder,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Event Price
          Row(
            children: [
              Text(
                '฿${event.ticketPrice}',
                style: t.textTheme.titleSmall?.copyWith(
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/Person',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: AppColor.textPlaceholder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
