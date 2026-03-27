import 'package:flutter/material.dart';
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
import 'package:sport_finding/feature/widget/discovery_search_field.dart';
import 'package:sport_finding/feature/widget/drop_down_from_field_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_drop_down_field_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

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
                Navigator.pushNamed(context, RoutesName.matchCreatedDoneScreen);
              },
            ),
          ),
        ),
        body: MainFrame(
          child: Form(
            key: formKey,
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
                    SectionHeaderWidget(title: AppText.schedule),
                    SizedBox(height: context.h(16)),
                    TextFormFieldWidget(
                      label: AppText.date,
                      hintText: AppText.dateHit,
                      controller: model.dateController,
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
                          model.setDate(date);
                        }
                      },
                    ),
                    SizedBox(height: context.h(16)),

                    TextFormFieldWidget(
                      label: AppText.time,
                      hintText: AppText.dateHit,
                      controller: model.timeController,
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
                          model.setTime(time, context);
                        }
                      },
                    ),
                    SizedBox(height: context.h(16)),
                    SearchDropdownField(
                      label: AppText.location,
                      hintText: "Search location...",
                      controller: model.locationController,
                      items: [
                        "Peshawar",
                        "Islamabad",
                        "Lahore",
                        "Karachi",
                        "Quetta",
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
                                                  onPressed: () {
                                                    print('Fullscreen tapped');
                                                  },
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

                    TextFormFieldWidget(
                      label: AppText.matchDuration,
                      controller: model.matchDurationController,
                      readOnly: true,
                      customSuffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: model.decrementDuration,
                            icon: Icon(
                              Icons.remove,
                              color: context.appColors.greyDark,
                            ),
                          ),
                          Text('${model.duration}'),
                          IconButton(
                            onPressed: model.incrementDuration,
                            icon: Icon(
                              Icons.add,
                              color: context.appColors.greyDark,
                            ),
                          ),
                        ],
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
