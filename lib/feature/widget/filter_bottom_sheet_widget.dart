import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/custom_slider_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';
import 'package:sport_finding/Data/model/match_filters.dart';

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
  double distance = kMaxFilterDistanceKm;
  final List<SportType> sports = [
    SportType(name: 'Football', icon: AppAssets.footBallIcon),
    SportType(name: 'Basketball', icon: AppAssets.basketBallIcon),
    SportType(name: 'Volleyball', icon: AppAssets.volleyBallIcon),
    SportType(name: 'Tennis', icon: AppAssets.tableTennisIcon),
  ];
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  TimeOfDay? _selectedTime;
  TimeOfDay? get selectedTime => _selectedTime;

  // 📅 Date
  void setDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      dateController.text =
          '${date.day}/${_getMonthName(date.month)}/${date.year}';
    });
  }

  // ⏰ Time
  void setTime(TimeOfDay time, BuildContext context) {
    setState(() {
      _selectedTime = time;
      timeController.text = time.format(context);
    });
  }

  final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.onPrimary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radiusR(12)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: context.h(8)),
            width: context.w(40),
            height: context.h(4),
            decoration: BoxDecoration(
              color: AppColors.greylight,
              borderRadius: BorderRadius.circular(context.radiusR(2)),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: context.padSym(h: 20),
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

                  SizedBox(height: context.h(12)),

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
                          onTap: () {
                            setState(() {
                              selectedSportIndex = selectedSportIndex == index
                                  ? null
                                  : index;
                            });
                          },
                          isActive: isSelected,
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

                  // Distance Slider
                  SizedBox(height: context.h(8)),
                  AuthFooterText(
                    normalText: AppText.distanceFromYou,
                    actionText: AppText.km,
                  ),
                  SizedBox(height: context.h(4)),

                  CustomSlider(
                    value: distance,
                    onChanged: (val) {
                      setState(() {
                        distance = val; // 🔥 value coming from widget
                      });
                    },
                  ),

                  SizedBox(height: context.h(16)),

                  // Skill Level Section
                  NormalText(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    titleText: AppText.skillLevel,
                    maxLines: 2,
                    titleStyle: context.appText.text16W600,
                    titleColor: context.appColors.onSurface,
                  ),

                  SizedBox(height: context.h(8)),

                  // Skill Level Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(skillLevels.length, (index) {
                      final isSelected = selectedSkillIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSkillIndex = selectedSkillIndex == index
                                ? null
                                : index;
                          });
                        },
                        child: CardWidget(
                          isActive: isSelected,
                          activeBorderColor: context.appColors.primary,
                          padding: context.padSym(h: 24, v: 8),

                          child: NormalText(
                            titleText: skillLevels[index],

                            titleColor: context.appColors.greyDark,
                            titleFontSize: context.text(13),
                            titleFontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: context.h(16)),

                  // Time and Date Row
                  Row(
                    children: [
                      // Time Picker
                      Expanded(
                        child: TextFormFieldWidget(
                          label: AppText.date,
                          hintText: AppText.dateHit,
                          controller: dateController,
                          readOnly: true,
                          customSuffix: Padding(
                            padding: EdgeInsets.all(
                              context.w(12),
                            ), // controls spacing
                            child: SizedBox(
                              height: context.h(20), // 👈 exact icon size
                              width: context.w(20),
                              child: SvgPicture.asset(
                                AppAssets.calendarIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
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
                              setDate(date);
                            }
                          },
                        ),
                      ),

                      SizedBox(width: context.w(12)),

                      // Date Picker
                      Expanded(
                        child: TextFormFieldWidget(
                          label: AppText.time,
                          hintText: AppText.dateHit,
                          controller: timeController,
                          readOnly: true,
                          customSuffix: Padding(
                            padding: EdgeInsets.all(
                              context.w(12),
                            ), // controls spacing
                            child: SizedBox(
                              height: context.h(20), // 👈 exact icon size
                              width: context.w(20),
                              child: SvgPicture.asset(
                                AppAssets.homeTimeIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setTime(time, context);
                            }
                          },
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
                            // Clear UI state + immediately apply "empty filter"
                            // so the list resets without pressing "Apply" again.
                            setState(() {
                              selectedSportIndex = null;
                              selectedSkillIndex = null;
                              distance = kMaxFilterDistanceKm;
                              _selectedTime = null;
                              _selectedDate = null;
                              dateController.clear();
                              timeController.clear();
                            });

                            widget.onApply(
                              FilterData(
                                sportIndex: null,
                                sportName: null,
                                skillLevel: null,
                                distance: kMaxFilterDistanceKm,
                                time: null,
                                date: null,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Card(
                            elevation: 2, // shadow
                            color: context.appColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                context.radiusR(12),
                              ),
                              side: BorderSide(
                                color: context
                                    .appColors
                                    .onPrimary, // ✅ border color
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: context.padSym(v: 14),
                              child: NormalText(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                titleText: AppText.reset,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: context.w(12)),

                      // Apply Button
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          text: AppText.apply,
                          color: context.appColors.primary,
                          onTap: () {
                            final filterData = FilterData(
                              sportIndex: selectedSportIndex,
                              sportName: selectedSportIndex != null
                                  ? sports[selectedSportIndex!].name
                                  : null,
                              skillLevel: selectedSkillIndex != null
                                  ? skillLevels[selectedSkillIndex!]
                                  : null,
                              distance: distance,
                              time: _selectedTime,
                              date: _selectedDate,
                            );
                            widget.onApply(filterData);
                            Navigator.pop(context);
                          },
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
