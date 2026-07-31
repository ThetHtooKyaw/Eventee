import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/src/event/view_models/event_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventFilterSheet extends StatelessWidget {
  const EventFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vm = context.watch<EventListViewModel>();

    return Container(
      padding: const EdgeInsets.all(AppFormat.primaryPadding),
      decoration: BoxDecoration(
        color: AppColor.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            color: AppColor.primary,
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
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Location TextField
          TextField(
            controller: vm.locationFilterController,
            decoration: InputDecoration(
              hintText: 'Enter a city or location',
              filled: true,
              fillColor: AppColor.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Category Title
          Text(
            'Category',
            style: t.textTheme.titleSmall?.copyWith(
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
                theme: t,
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
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Price Chips
          Row(
            children: [
              _buildChoiceChip(
                theme: t,
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
                theme: t,
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
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '฿${vm.priceRange.start.round()} - ฿${vm.priceRange.end.round()}',
                style: t.textTheme.bodyLarge,
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
                  child: Text(
                    'Reset',
                    style: t.textTheme.titleSmall?.copyWith(
                      color: AppColor.primary,
                    ),
                  ),
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
      selectedColor: AppColor.primary,
      checkmarkColor: AppColor.white,
      label: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected ? AppColor.white : AppColor.textPrimary,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppFormat.secondaryBorderRadius),
        side: BorderSide(color: AppColor.placeholder, width: 0.5),
      ),
    );
  }
}
