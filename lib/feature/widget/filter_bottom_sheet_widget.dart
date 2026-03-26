import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(FilterData) onApply;

  const FilterBottomSheet({super.key, required this.onApply});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int? selectedSportIndex;
  int? selectedSkillIndex;
  double selectedDistance = 10.0;
  TimeOfDay? selectedTime;
  DateTime? selectedDate;

  final List<SportType> sports = [
    SportType(name: 'Football', icon: AppAssets.footBallIcon),
    SportType(name: 'Volleyball', icon: AppAssets.volleyBallIcon),
    SportType(name: 'Cricket', icon: AppAssets.tableTennisIcon),
  ];

  final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: context.h(8)),
            width: context.w(40),
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greylight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: context.padSym(h: 20, v: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        titleText: AppText.filters,
                        maxLines: 2,
                        titleStyle: context.appText.text16W600,
                        titleColor: context.appColors.onSurface,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: context.appColors.greyDark,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.h(16)),

                  // Sport Type Section
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: AppText.sportType,
                    maxLines: 2,
                    titleStyle: context.appText.text16W600,
                    titleColor: context.appColors.onSurface,
                  ),

                  SizedBox(height: context.h(8)),

                  // Sport Cards
                  SizedBox(
                    height: context.h(140),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sports.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: context.w(12)),
                      itemBuilder: (context, index) {
                        final sport = sports[index];
                        final isSelected = selectedSportIndex == index;

                        return CardWidget(
                          onTap: () {},
                          isActive: isSelected, // ✅ highlight selected
                          activeBorderColor: context.appColors.primary,
                          padding: context.padSym(h: 32, v: 18),
                          child: Column(
                            children: [
                              CardIconWidget(imageAsset: sport.icon),
                              NormalText(
                                titleText: sport.name,
                                titleStyle: context.appText.text16W500,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: context.h(24)),

                  // Distance Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Distance from you:',
                        style: TextStyle(
                          fontSize: context.sp(14),
                          fontWeight: FontWeight.w400,
                          color: AppColors.blackcolor,
                        ),
                      ),
                      Text(
                        '${selectedDistance.toInt()} km',
                        style: TextStyle(
                          fontSize: context.sp(14),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3EA7FD),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.h(8)),

                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF3EA7FD),
                      inactiveTrackColor: const Color(0xFFE0E0E0),
                      thumbColor: const Color(0xFF3EA7FD),
                      overlayColor: const Color(0xFF3EA7FD).withOpacity(0.2),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: selectedDistance,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: (value) {
                        setState(() {
                          selectedDistance = value;
                        });
                      },
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 km',
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: AppColors.greydark,
                        ),
                      ),
                      Text(
                        'Any km',
                        style: TextStyle(
                          fontSize: context.sp(12),
                          color: AppColors.greydark,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.h(24)),

                  // Skill Level Section
                  Text(
                    'Skill Level',
                    style: TextStyle(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackcolor,
                    ),
                  ),

                  SizedBox(height: context.h(12)),

                  // Skill Level Buttons
                  Row(
                    children: List.generate(skillLevels.length, (index) {
                      final isSelected = selectedSkillIndex == index;
                      return Padding(
                        padding: EdgeInsets.only(right: context.w(12)),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSkillIndex = selectedSkillIndex == index
                                  ? null
                                  : index;
                            });
                          },
                          child: Container(
                            padding: context.padSym(h: 20, v: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3EA7FD).withOpacity(0.1)
                                  : const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3EA7FD)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              skillLevels[index],
                              style: TextStyle(
                                fontSize: context.sp(14),
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFF3EA7FD)
                                    : AppColors.greydark,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: context.h(24)),

                  // Time and Date Row
                  Row(
                    children: [
                      // Time Picker
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                          child: Container(
                            padding: context.padSym(h: 16, v: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time',
                                      style: TextStyle(
                                        fontSize: context.sp(12),
                                        color: AppColors.greydark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: context.h(4)),
                                    Text(
                                      selectedTime?.format(context) ?? '--:--',
                                      style: TextStyle(
                                        fontSize: context.sp(14),
                                        color: AppColors.blackcolor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: AppColors.greydark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: context.w(12)),

                      // Date Picker
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: context.padSym(h: 16, v: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: context.sp(12),
                                        color: AppColors.greydark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: context.h(4)),
                                    Text(
                                      selectedDate != null
                                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                          : 'dd/mm/yyyy',
                                      style: TextStyle(
                                        fontSize: context.sp(14),
                                        color: AppColors.blackcolor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: AppColors.greydark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.h(24)),

                  // Bottom Buttons
                  Row(
                    children: [
                      // Reset Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSportIndex = null;
                              selectedSkillIndex = null;
                              selectedDistance = 10.0;
                              selectedTime = null;
                              selectedDate = null;
                            });
                          },
                          child: Container(
                            padding: context.padSym(v: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Reset',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackcolor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: context.w(12)),

                      // Apply Button
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            final filterData = FilterData(
                              sportIndex: selectedSportIndex,
                              skillLevel: selectedSkillIndex != null
                                  ? skillLevels[selectedSkillIndex!]
                                  : null,
                              distance: selectedDistance,
                              time: selectedTime,
                              date: selectedDate,
                            );
                            widget.onApply(filterData);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: context.padSym(v: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Apply',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.sp(16),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.h(16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sport Type Model
class SportType {
  final String name;
  final String icon;

  SportType({required this.name, required this.icon});
}

// Filter Data Model
class FilterData {
  final int? sportIndex;
  final String? skillLevel;
  final double distance;
  final TimeOfDay? time;
  final DateTime? date;

  FilterData({
    this.sportIndex,
    this.skillLevel,
    required this.distance,
    this.time,
    this.date,
  });
}
