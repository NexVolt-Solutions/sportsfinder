import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/view_model/card_icon_widget.dart';
import 'package:sport_finding/feature/view_model/choose_sport_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/splash_background.dart';

class ChooseSportScreen extends StatefulWidget {
  const ChooseSportScreen({super.key});

  @override
  State<ChooseSportScreen> createState() => _ChooseSportScreenState();
}

class _ChooseSportScreenState extends State<ChooseSportScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChooseSportScreenViewModel(),
      child: Consumer<ChooseSportScreenViewModel>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: Padding(
            padding: EdgeInsetsGeometry.only(
              top: context.h(3),
              left: context.w(20),
              right: context.w(20),
              bottom: context.text(20),
            ),
            child: CustomButton(
              isEnabled: true,
              text: AppText.continueButton,
              color: AppColors.bluecolor,
              onTap: () {},
            ),
          ),
          body: SafeArea(
            child: SplashBackground(
              child: ListView(
                padding: context.padSym(h: 20),
                children: [
                  SizedBox(height: context.h(22)),
                  AppBarWidget(
                    onTap: () => Navigator.pop(context),
                    title: AppText.appName,
                  ),
                  SizedBox(height: context.h(20)),
                  NormalText(
                    titleText: AppText.chooseSportsTitle,
                    titleSize: context.sp(20),
                    titleColor: AppColors.blackcolor,
                    titleWeight: FontWeight.w600,
                    subText: AppText.chooseSportsDesc,
                    subColor: AppColors.greylight60,
                    subSize: context.sp(16),
                    subWeight: FontWeight.w500,
                  ),
                  SizedBox(height: context.h(20)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: model.skillLevelData.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 cards per row
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                    itemBuilder: (context, index) {
                      final data = model.skillLevelData[index];
                      bool isSelected = model.selectedIndex == index;

                      return CardWidget(
                        padding: context.padSym(h: 12, v: 14),
                        borderColor: isSelected
                            ? AppColors.bluecolor
                            : AppColors.blue10,
                        onTap: () {
                          model.selectSkill(index);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CardIconWidget(
                              imageAsset: data['Image'],
                              isSelected: isSelected,
                            ),

                            SizedBox(height: context.h(12)),

                            NormalText(
                              titleText: data['title'],
                              titleSize: context.sp(14),
                              titleColor: AppColors.blackcolor,
                              titleWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
