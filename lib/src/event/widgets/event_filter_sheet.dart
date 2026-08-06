import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/src/event/view_models/event_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventFilterSheet extends StatelessWidget {
  const EventFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<EventListViewModel>();

    return Container(
      padding: const EdgeInsets.all(AppFormat.primaryPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            color: Theme.of(context).colorScheme.primary,
            thickness: 6,
            indent: 130,
            endIndent: 130,
            radius: BorderRadius.all(
              Radius.circular(AppFormat.secondaryBorderRadius),
            ),
          ),
          const SizedBox(height: 20),

          // Location Title
          Text(
            'Location',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Location TextField
          TextField(
            controller: vm.locationFilterController,
            decoration: InputDecoration(hintText: 'Enter a city or location'),
          ),
          const SizedBox(height: 20),

          // Category Title
          Text(
            'Category',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Category Chips
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: vm.categories.map((category) {
              return _buildChoiceChip(
                theme: theme,
                isSelected: vm.selectedCategory == category,
                label: category,
                onSelected: (isSelected) {
                  if (isSelected) {
                    vm.selectCategory(category);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Sort Title
          Text(
            'Sort By Price',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Price Chips
          Row(
            children: [
              _buildChoiceChip(
                theme: theme,
                isSelected: vm.sortOrder == EventSortOrder.priceAscending,
                label: 'Low to High',
                onSelected: (isSelected) {
                  if (isSelected) {
                    vm.setSortOrder(EventSortOrder.priceAscending);
                  } else {
                    vm.setSortOrder(EventSortOrder.none);
                  }
                },
              ),
              const SizedBox(width: 10),

              _buildChoiceChip(
                theme: theme,
                isSelected: vm.sortOrder == EventSortOrder.priceDescending,
                label: 'High to Low',
                onSelected: (isSelected) {
                  if (isSelected) {
                    vm.setSortOrder(EventSortOrder.priceDescending);
                  } else {
                    vm.setSortOrder(EventSortOrder.none);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Price Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Range',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '฿${vm.priceRange.start.round()} - ฿${vm.priceRange.end.round()}',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),

          // Price Range Slider
          RangeSlider(
            values: vm.priceRange,
            min: 0,
            max: vm.maxPrice,
            divisions: vm.maxPrice > 0 ? vm.maxPrice.round() : 1,
            labels: RangeLabels(
              '฿${vm.priceRange.start.round()}',
              '฿${vm.priceRange.end.round()}',
            ),
            onChanged: (values) {
              vm.setPriceRange(values);
            },
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    vm.resetFilters();
                  },
                  child: Text('Reset', style: theme.textTheme.titleSmall),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    vm.applyFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required ThemeData theme,
    required bool isSelected,
    required String label,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: theme.colorScheme.onPrimary,
      label: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
        side: BorderSide(color: AppColor.placeholder, width: 0.5),
      ),
    );
  }
}
