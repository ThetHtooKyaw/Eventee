import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/loading_column.dart';
import 'package:eventee/src/admin/model/event.dart';
import 'package:eventee/src/booking/views/event_details_view.dart';
import 'package:eventee/src/home/viewa_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController searchController = TextEditingController();

  final items = const [
    (Icons.music_note, 'Music'),
    (Icons.sports_basketball, 'Sports'),
    (Icons.brush, 'Art'),
    (Icons.fastfood, 'Food'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchAllEvents();
    });
  }

  String formatDate(DateTime eventDate) {
    return DateFormat('MMM, dd').format(eventDate);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.watch<HomeViewModel>();

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
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final (icon, label) = items[index];

                    return _buildCategory(t, icon, label);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Upcoming Events
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
              StreamBuilder(
                stream: vm.eventStream,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingColumn(message: 'Loading Events');
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: t.textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasData) {
                    List<EventModel> events = snapshot.data;

                    if (events.isEmpty) {
                      return Center(
                        child: Text(
                          'No events found!',
                          style: t.textTheme.bodyLarge,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: events.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        EventModel event = events[index];
                        String eventDate = formatDate(event.eventDate);

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
                  }

                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvents(ThemeData t, EventModel event, String eventDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(right: AppFormat.primaryPadding),
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
                      CircularProgressIndicator(),
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

        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
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
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCategory(ThemeData t, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(AppFormat.secondaryPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppFormat.primaryBorderRadius),
      ),
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          Text(label, style: t.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
