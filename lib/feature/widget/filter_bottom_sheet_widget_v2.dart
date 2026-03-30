import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/feature/model/match_filters.dart';
import 'package:sport_finding/feature/viewModel/filter_bottom_sheet_view_model.dart';
import 'package:sport_finding/feature/widget/auth_footer_text.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/custom_slider_widget.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key, required this.onApply});

  final Function(FilterData) onApply;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FilterBottomSheetViewModel(),
      child: _FilterBottomSheetBody(onApply: onApply),
    );
  }
}

class _FilterBottomSheetBody extends StatelessWidget {
  const _FilterBottomSheetBody({required this.onApply});

  final Function(FilterData) onApply;

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterBottomSheetViewModel>(
      builder: (context, vm, _) {
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
                  color: context.appColors.greylight,
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
                      // Header row
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

                      // Sport Type section
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        titleText: AppText.sportType,
                        maxLines: 2,
                        titleStyle: context.appText.text16W600,
                        titleColor: context.appColors.onSurface,
                      ),
                      SizedBox(height: context.h(8)),

                      SizedBox(
                        height: context.h(90),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: vm.sports.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: context.w(12)),
                          itemBuilder: (context, index) {
                            final sport = vm.sports[index];
                            final selected = vm.selectedSportIndex == index;
                            final border = Border.all(
                              color: selected
                                  ? context.appColors.primary
                                  : context.appColors.greylight,
                              width: 1,
                            );
                            final bg = selected
                                ? Colors.white
                                : context.appColors.blue10;

                            return GestureDetector(
                              onTap: () => vm.toggleSport(index),
                              child: Container(
                                width: context.h(90),
                                height: context.h(90),
                                padding: EdgeInsets.symmetric(
                                  vertical: context.h(12),
                                  horizontal: context.w(10),
                                ),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(
                                    context.radiusR(12),
                                  ),
                                  border: border,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      sport.icon,
                                      width: context.w(34),
                                      height: context.w(34),
                                      colorFilter: ColorFilter.mode(
                                        selected
                                            ? context.appColors.primary
                                            : context.appColors.greyDark,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(height: context.h(6)),
                                    NormalText(
                                      titleText: sport.name,
                                      titleStyle: context.appText.text14W500,
                                      titleColor: selected
                                          ? context.appColors.primary
                                          : context.appColors.onSurface,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: context.h(8)),

                      // Distance slider
                      AuthFooterText(
                        normalText: AppText.distanceFromYou,
                        actionText: AppText.km,
                      ),
                      SizedBox(height: context.h(4)),
                      CustomSlider(
                        value: vm.distance,
                        onChanged: vm.setDistance,
                      ),

                      SizedBox(height: context.h(16)),

                      // Skill level
                      NormalText(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        titleText: AppText.skillLevel,
                        maxLines: 2,
                        titleStyle: context.appText.text16W600,
                        titleColor: context.appColors.onSurface,
                      ),
                      SizedBox(height: context.h(8)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(vm.skillLevels.length, (index) {
                          final isSelected = vm.selectedSkillIndex == index;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.w(4),
                              ),
                              child: GestureDetector(
                                onTap: () => vm.toggleSkill(index),
                                child: Container(
                                  height: context.h(40),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? context.appColors.onPrimary
                                        : context.appColors.blue10,
                                    borderRadius: BorderRadius.circular(
                                      context.radiusR(20),
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? context.appColors.primary
                                          : context.appColors.greylight,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: NormalText(
                                    titleText: vm.skillLevels[index],
                                    titleFontSize: context.text(13),
                                    titleFontWeight: FontWeight.w400,
                                    titleColor: isSelected
                                        ? context.appColors.primary
                                        : context.appColors.greyDark,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: context.h(16)),

                      // Time and Date row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormFieldWidget(
                              label: AppText.date,
                              hintText: AppText.dateHit,
                              controller: vm.dateController,
                              readOnly: true,
                              customSuffix: Padding(
                                padding: EdgeInsets.all(context.w(12)),
                                child: SizedBox(
                                  height: context.h(20),
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
                                if (date != null) vm.setDate(date);
                              },
                            ),
                          ),
                          SizedBox(width: context.w(12)),
                          Expanded(
                            child: TextFormFieldWidget(
                              label: AppText.time,
                              hintText: AppText.dateHit,
                              controller: vm.timeController,
                              readOnly: true,
                              customSuffix: Padding(
                                padding: EdgeInsets.all(context.w(12)),
                                child: SizedBox(
                                  height: context.h(20),
                                  width: context.w(20),
                                  child: SvgPicture.asset(
                                    AppAssets.homeTimeIcon,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                final t = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (t != null) {
                                  vm.setTime(t, context);
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                vm.reset();
                                onApply(vm.buildFilterData());
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: context.h(48),
                                decoration: BoxDecoration(
                                  color: context.appColors.onPrimary,
                                  borderRadius: BorderRadius.circular(
                                    context.radiusR(12),
                                  ),
                                  border: Border.all(
                                    color: context.appColors.greylight,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    AppText.reset,
                                    style: context.appText.text16W500.copyWith(
                                      color: context.appColors.greyDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: context.w(12)),
                          Expanded(
                            flex: 2,
                            child: CustomButton(
                              text: AppText.apply,
                              color: context.appColors.primary,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              onTap: () {
                                onApply(vm.buildFilterData());
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
      },
    );
  }
}
