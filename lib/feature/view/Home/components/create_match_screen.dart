import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view/Home/viewModel/create_match_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/custom_bottom_sheet_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/drop_down_from_field_widget.dart';
import 'package:sport_finding/feature/widget/search_drop_down_field_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  Future<void> _showDurationPicker(
    BuildContext context,
    CreateMatchScreenViewModel model,
  ) async {
    final initialIndex = model.durationOptions.indexOf(model.duration);
    final safeInitialIndex = initialIndex < 0 ? 0 : initialIndex;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final pickerHeight = context.h(260);
        return SizedBox(
          height: pickerHeight,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: context.appColors.onPrimary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.radiusR(16)),
                ),
              ),
              padding: EdgeInsets.only(bottom: context.h(12)),
              child: Column(
                children: [
                  SizedBox(height: context.h(8)),
                  SizedBox(
                    height: context.h(200),
                    child: CupertinoPicker(
                      itemExtent: context.h(40),
                      scrollController: FixedExtentScrollController(
                        initialItem: safeInitialIndex,
                      ),
                      onSelectedItemChanged: (i) {
                        final minutes = model.durationOptions[i];
                        model.setDuration(minutes);
                      },
                      children: model.durationOptions
                          .map(
                            (m) => Center(
                              child: Text(
                                '$m minutes',
                                style: context.appText.text16W600,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      AppText.done,
                      style: context.appText.text16W600,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateMatchScreenViewModel>(
      builder: (context, model, child) => Scaffold(
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              top: context.h(5),
              bottom: context.h(20),
              right: context.w(20),
              left: context.w(20),
            ),
            child: CustomButton(
              text: AppText.createMatch,
              color: context.appColors.primary,
              onTap: () {
                if (!model.validateForCreate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter match title, date, time, and location.',
                      ),
                    ),
                  );
                  return;
                }
                final created = model.toCreatedDiscoveryMatch();
                Navigator.pushNamed(
                  context,
                  RoutesName.matchCreatedDoneScreen,
                  arguments: created,
                );
              },
            ),
          ),
        ),
        body: MainFrame(
          child: Form(
            key: model.formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: context.padSym(h: 20),
                child: Column(
                  children: [
                    // Header Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.h(20)),
                        AppBarWidget(
                          onTapFirst: () => Navigator.pop(context),
                          title: AppText.sportFinding,
                        ),
                        SizedBox(height: context.h(20)),
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: AppText.createMatch,
                          titleStyle: context.appText.text18W600,
                          titleColor: Colors.white,
                          subText: AppText.setUpANewGameForOthersToJoin,
                          subColor: const Color(0xFF9E9E9E),
                          subStyle: context.appText.text14W400,
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(16)),
                    SectionHeaderWidget(title: AppText.basicInfo),
                    SizedBox(height: context.h(16)),

                    TextFormFieldWidget(
                      label: AppText.matchTitle,
                      hintText: AppText.matchTitleHit,
                      controller: model.matchTitleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppText.matchTitleValidation;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: context.h(16)),
                    TextFormFieldWidget(
                      label: AppText.description,
                      hintText: AppText.descriptionHit,
                      controller: model.descriptionController,
                      maxLines: 5,
                    ),
                    SizedBox(height: context.h(16)),
                    // Same height controls for consistency.
                    SizedBox(
                      height: context.h(56),
                      child: DropdownFormFieldWidget(
                        label: AppText.sportType,
                        hintText: AppText.chooseYourSports,
                        items: model.sportTypes,
                        value: model.selectedSportType,
                        onChanged: model.setSportType,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppText.sportTypeValidation;
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    SizedBox(
                      height: context.h(56),
                      child: DropdownFormFieldWidget(
                        label: AppText.skillLevel,
                        hintText: AppText.skillLevelHint,
                        items: model.skillLevels,
                        value: model.selectedSkillLevel,
                        onChanged: model.setSkillLevel,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppText.skillLevelValidation;
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    SectionHeaderWidget(title: AppText.schedule),
                    SizedBox(height: context.h(16)),
                    SizedBox(
                      height: context.h(56),
                      child: TextFormFieldWidget(
                        label: AppText.date,
                        hintText: AppText.dateHit,
                        controller: model.dateController,
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
                          if (date != null) {
                            model.setDate(date);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: context.h(16)),

                    SizedBox(
                      height: context.h(56),
                      child: TextFormFieldWidget(
                        label: AppText.time,
                        hintText: AppText.dateHit,
                        controller: model.timeController,
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
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            model.setTime(time, context);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    SearchDropdownField(
                      label: AppText.location,
                      hintText: "Search location...",
                      controller: model.locationController,
                      items: [
                        "Central Park",
                        "Denmark Central Park",
                        "Denmark Central Park Court",
                        "Denmark Central Park Court 2",
                        "Denmark Central Park Court 3",
                        "Denmark Central Park Court 4",
                        "Denmark Central Park Court 5",
                        "Denmark Central Park Court 6",
                        "Denmark Central Park Court 7",
                        "Denmark Central Park Court 8",
                        "Denmark Central Park Court 9",
                        "Denmark Central Park Court 10",
                      ],
                    ),
                    SizedBox(height: context.h(12)),

                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: context.w(8)),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) => CustomBottomSheetWidget(
                                isCenter: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ), // rounded corners
                                      child: Stack(
                                        children: [
                                          // 1️⃣ Map Image
                                          Container(
                                            height: context.h(174),
                                            width: context.w(380),
                                            decoration: BoxDecoration(
                                              color: context.appColors.blue10,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    context.radiusR(12),
                                                  ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: context.padAll(12),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.fullscreen,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {},
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: NormalText(
                            titleText: AppText.selectOnMap,
                            titleColor: context.appColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(12)),

                    SizedBox(
                      height: context.h(56),
                      child: TextFormFieldWidget(
                        label: AppText.matchDuration,
                        controller: model.matchDurationController,
                        readOnly: true,
                        customSuffix: Padding(
                          padding: EdgeInsets.all(context.w(12)),
                          child: Icon(
                            Icons.timer_rounded,
                            size: context.w(20),
                            color: context.appColors.greyDark,
                          ),
                        ),
                        onTap: () => _showDurationPicker(context, model),
                      ),
                    ),

                    SizedBox(height: context.h(16)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
