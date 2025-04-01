// import 'package:flutter/material.dart';
// import '../utils/constants.dart';

// class SearchFilterWidget extends StatelessWidget {
//   final Function(String) onFilterChanged;
//   final Function(String) onSearchChanged;
//   final String selectedFilter;

//   const SearchFilterWidget({
//     Key? key,
//     required this.onFilterChanged,
//     required this.onSearchChanged,
//     required this.selectedFilter,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildSearchField(),
//           const SizedBox(height: 16),
//           _buildFilterChips(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchField() {
//     return TextField(
//       decoration: InputDecoration(
//         hintText: 'Search Jobs',
//         prefixIcon: const Icon(Icons.search, color: Colors.grey),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.blue.shade300),
//         ),
//       ),
//       onChanged: onSearchChanged,
//     );
//   }

//   Widget _buildFilterChips() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: JobConstants.filterOptions.map((filter) => Padding(
//           padding: const EdgeInsets.only(right: 8),
//           child: FilterChip(
//             selected: selectedFilter == filter,
//             label: Text(filter),
//             onSelected: (selected) => onFilterChanged(filter),
//             backgroundColor: Colors.white,
//             selectedColor: JobConstants.primaryColor.withAlpha(50),
//             checkmarkColor: JobConstants.primaryColor,
//           ),
//         )).toList(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SearchFilterWidget extends StatelessWidget {
  final Function(String) onFilterChanged;
  final Function(String) onSearchChanged;
  final String selectedFilter;

  const SearchFilterWidget({
    Key? key,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.selectedFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search Jobs',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: JobConstants.primaryColor.withAlpha(123)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: onSearchChanged,
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: JobConstants.filterOptions.length,
        itemBuilder: (context, index) {
          final filter = JobConstants.filterOptions[index];
          final isSelected = selectedFilter == filter;
          final displayName = JobConstants.filterDisplayNames[filter] ?? filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(displayName),
              onSelected: (_) => onFilterChanged(filter),
              backgroundColor: Colors.white,
              selectedColor: JobConstants.primaryColor.withAlpha(37),
              checkmarkColor: JobConstants.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? JobConstants.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}