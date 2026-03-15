import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/view_model/skill_level_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';

class SkillLevelScreen extends StatefulWidget {
  const SkillLevelScreen({super.key});

  @override
  State<SkillLevelScreen> createState() => _SkillLevelScreenState();
}

class _SkillLevelScreenState extends State<SkillLevelScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SkillLevelScreenViewModel>(
      builder: (context, model, child) => MainFrame(
        bottomNavigationBar: Padding(
          padding: EdgeInsetsGeometry.only(
            top: context.h(3),
            left: context.w(20),
            right: context.w(20),
            bottom: context.text(20),
          ),
          child: CustomButton(
            text: AppText.continueButton,
            color: context.appColors.primary,
            onTap: () {
              Navigator.pushNamed(context, RoutesName.ChooseSportScreen);
            },
          ),
        ),
        child: ListView(
              padding: context.padSym(h: 20),
              children: [
                SizedBox(height: context.h(22)),
                AppBarWidget(title: AppText.appName),
                SizedBox(height: context.h(20)),
                NormalText(
                  titleText: AppText.skillLevelTitle,
                  titleStyle: context.appText.text18W600,
                  titleColor: context.appColors.onSurface,
                  subText: AppText.skillLevelDesc,
                  subStyle: context.appText.text16W400,
                  subColor: context.appColors.greyLight60,
                ),
                SizedBox(height: context.h(20)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: model.skillLevels.length,
                  itemBuilder: (context, index) {
                    final skillLevel = model.skillLevels[index];
                    final isSelected = model.selectedIndex == index;

                    return CardWidget(
                      padding: context.padSym(h: 12, v: 14),
                      borderColor: isSelected
                          ? context.appColors.primary
                          : Colors.transparent,
                      onTap: () => model.selectSkill(index),
                      child: Row(
                        children: [
                          CardIconWidget(
                            imageAsset: skillLevel.imagePath,
                            isSelected: isSelected,
                          ),
                          SizedBox(width: context.h(20)),
                          NormalText(
                            titleText: skillLevel.title,
                            titleStyle: context.appText.text14W600,
                            titleColor: context.appColors.onSurface,
                            subText: skillLevel.subTitle,
                            subStyle: context.appText.text12W400,
                            subColor: context.appColors.greyDark,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Container(
                //   height: 90,
                //   width: 300,
                //   decoration: BoxDecoration(
                //     color: AppColors.bluecolor.withOpacity(.9),
                //     borderRadius: BorderRadius.circular(context.radiusR(12)),

                //     boxShadow: [
                //       BoxShadow(
                //         color: AppColors.greylight60,
                //         offset: Offset(0, 4),
                //         blurRadius: 95,
                //         blurStyle: BlurStyle.inner,
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
        ),
    );
  }
}
