import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/feature/view_model/choose_sport_screen_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/card_icon_widget.dart';
import 'package:sport_finding/feature/widget/card_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';

class ChooseSportScreen extends StatefulWidget {
  const ChooseSportScreen({super.key});

  @override
  State<ChooseSportScreen> createState() => _ChooseSportScreenState();
}

class _ChooseSportScreenState extends State<ChooseSportScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChooseSportScreenViewModel>(
      builder: (context, model, child) => MainFrame(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: context.padSym(h: 20),
                children: [
                  AppBarWidget(
                    onTap: () => Navigator.pop(context),
                    title: AppText.appName,
                  ),
                  NormalText(
                    titleText: AppText.chooseSportsTitle,
                    titleStyle: context.appText.text18W600,
                    titleColor: context.appColors.onSurface,
                    subText: AppText.chooseSportsDesc,
                    subStyle: context.appText.text16W400,
                    subColor: context.appColors.greyLight60,
                  ),
                  SizedBox(height: context.h(20)),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: model.sports.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                    itemBuilder: (context, index) {
                      final sport = model.sports[index];
                      final isSelected = model.selectedIndex == index;

                      return CardWidget(
                        padding: context.padSym(h: 12, v: 14),
                        borderColor: isSelected
                            ? context.appColors.primary
                            : context.appColors.blue10,
                        onTap: () => model.selectSkill(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CardIconWidget(
                              imageAsset: sport.imagePath,
                              isSelected: isSelected,
                            ),
                            SizedBox(height: context.h(12)),
                            NormalText(
                              titleText: sport.title,
                              titleStyle: context.appText.text14W600,
                              titleColor: context.appColors.onSurface,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
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
                  if (!model.hasSelection) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Please select a sport to continue.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  Navigator.pushNamed(context, RoutesName.LocationAccessScreen);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
