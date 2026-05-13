import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/custom_seeting_card.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/shimmer_loading.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';

class WebProfileContent extends StatelessWidget {
  const WebProfileContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.displayName,
    required this.location,
    required this.bio,
    required this.safeAvatarUrl,
    required this.isLoading,
    required this.followersValue,
    required this.followingValue,
    required this.ratingValue,
    required this.matchesPlayedValue,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onRatingTap,
    this.onMatchesTap,
    this.actionSection,
    this.middleSection,
    this.footerSection,
    this.settingsItems = const <Map<String, dynamic>>[],
    this.notificationsEnabled = false,
    this.isUpdatingPreference = false,
    this.onSwitchChanged,
    this.onTapSetting,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.secondaryActionIconAsset = AppAssets.follow,
    this.onBackTap,
    this.headerActionText,
    this.onHeaderActionTap,
    this.showHeaderText = true,
  });

  final String title;
  final String subtitle;
  final String displayName;
  final String location;
  final String bio;
  final String? safeAvatarUrl;
  final bool isLoading;
  final String followersValue;
  final String followingValue;
  final String ratingValue;
  final String matchesPlayedValue;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onRatingTap;
  final VoidCallback? onMatchesTap;
  final Widget? actionSection;
  final Widget? middleSection;
  final Widget? footerSection;
  final List<Map<String, dynamic>> settingsItems;
  final bool notificationsEnabled;
  final bool isUpdatingPreference;
  final ValueChanged<bool>? onSwitchChanged;
  final void Function(int index)? onTapSetting;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final String secondaryActionIconAsset;
  final VoidCallback? onBackTap;
  final String? headerActionText;
  final VoidCallback? onHeaderActionTap;
  final bool showHeaderText;

  @override
  Widget build(BuildContext context) {
    return MainFrame(
      showDecorationLayer: false,
      child: ListView(
        padding: context.padSym(h: 20, v: 20),
        children: [
          Row(
            children: [
              if (onBackTap != null) ...[
                InkWell(
                  onTap: onBackTap,
                  borderRadius: BorderRadius.circular(context.radius(12)),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: context.appColors.onSurface,
                  ),
                ),
                SizedBox(width: context.w(16)),
              ],
              Expanded(
                child: WebDashboardTitle(title: title, subtitle: subtitle),
              ),
              if (headerActionText != null && onHeaderActionTap != null)
                SizedBox(
                  width: context.w(180),
                  child: CustomButton(
                    text: headerActionText!,
                    onTap: onHeaderActionTap,
                    color: context.appColors.primary,
                    titleStyle: context.appText.text14W500.copyWith(
                      color: context.appColors.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.h(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: context.w(300),
                child: WebDashboardPanel(
                  child: isLoading
                      ? const _WebProfileCardShimmer()
                      : Column(
                          children: [
                            AppAvatar(
                              size: context.w(128),
                              imageUrl: safeAvatarUrl,
                              fallbackText: displayName,
                              backgroundColor: context.appColors.white,
                              iconColor: context.appColors.primary,
                            ),
                            SizedBox(height: context.h(24)),
                            NormalText(
                              titleText: displayName.isNotEmpty
                                  ? displayName
                                  : 'Player',
                              titleAlign: TextAlign.center,
                              titleStyle: context.appText.text28W700.copyWith(
                                color: context.appColors.greyDark,
                              ),
                            ),
                            SizedBox(height: context.h(4)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.iconOutline,
                                  width: context.w(16),
                                  height: context.w(16),
                                  colorFilter: ColorFilter.mode(
                                    context.appColors.greyDark,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: context.w(6)),
                                Flexible(
                                  child: Text(
                                    location.isNotEmpty
                                        ? location
                                        : AppText.profilePlaceholderLocation,
                                    style: context.appText.text14W400.copyWith(
                                      color: context.appColors.greyDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (actionSection != null) ...[
                              SizedBox(height: context.h(24)),
                              actionSection!,
                            ] else if (primaryActionLabel != null &&
                                onPrimaryAction != null) ...[
                              SizedBox(height: context.h(24)),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      padding: context.padAll(6),
                                      text: primaryActionLabel!,
                                      onTap: onPrimaryAction,
                                      color: context.appColors.primary,
                                      titleStyle: context.appText.text14W500
                                          .copyWith(
                                            color: context.appColors.onPrimary,
                                          ),
                                    ),
                                  ),
                                  if (onSecondaryAction != null) ...[
                                    SizedBox(width: context.w(10)),
                                    InkWell(
                                      onTap: onSecondaryAction,
                                      borderRadius: BorderRadius.circular(
                                        context.radius(12),
                                      ),
                                      child: Container(
                                        padding: context.padAll(16),
                                        decoration: BoxDecoration(
                                          color: context.appColors.blue10,
                                          borderRadius: BorderRadius.circular(
                                            context.radius(12),
                                          ),
                                          border: Border.all(
                                            color: AppColors.whitecolor,
                                          ),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            secondaryActionIconAsset,
                                            colorFilter: ColorFilter.mode(
                                              context.appColors.primary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                ),
              ),
              SizedBox(width: context.w(20)),
              Expanded(
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final rowW = constraints.maxWidth.isFinite
                            ? constraints.maxWidth
                            : MediaQuery.sizeOf(context).width;
                        final gap = rowW < 400
                            ? 8.0
                            : rowW < 900
                            ? 12.0
                            : 16.0;
                        final slotW = (rowW - 3 * gap) / 4;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _StatCard(
                                value: followersValue,
                                label: AppText.followers,
                                onTap: onFollowersTap,
                                slotWidth: slotW,
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: _StatCard(
                                value: followingValue,
                                label: AppText.following,
                                onTap: onFollowingTap,
                                slotWidth: slotW,
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: _StatCard(
                                value: ratingValue,
                                label: AppText.rating,
                                onTap: onRatingTap,
                                slotWidth: slotW,
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: _StatCard(
                                value: matchesPlayedValue,
                                label: AppText.matchesPlayed,
                                onTap: onMatchesTap,
                                slotWidth: slotW,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: context.h(20)),
                    WebDashboardPanel(
                      padding: context.padAll(32),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About',
                              style: context.appText.text18W400.copyWith(
                                color: context.appColors.onSurface,
                              ),
                            ),
                            SizedBox(height: context.h(16)),
                            Text(
                              bio.isNotEmpty
                                  ? bio
                                  : 'Passionate athlete who loves team sports and meeting new players. Always up for a match!',
                              textAlign: TextAlign.start,
                              style: context.appText.text16W400.copyWith(
                                color: context.appColors.greylight,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (middleSection != null) ...[
                      SizedBox(height: context.h(20)),
                      middleSection!,
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (settingsItems.isNotEmpty) ...[
            SizedBox(height: context.h(20)),
            WebDashboardPanel(
              child: Column(
                children: settingsItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == settingsItems.length - 1
                          ? 0
                          : context.h(8),
                    ),
                    child: CustomSettingCard(
                      icon: item['leading'],
                      title: item['title'],
                      subtitle: item['subtitle'],
                      trailingType: item['trailingType'],
                      switchValue: index == 2
                          ? notificationsEnabled
                          : item['switchValue'],
                      onSwitchChanged: index == 2 && onSwitchChanged != null
                          ? onSwitchChanged!
                          : (val) {},
                      switchEnabled: index == 2 ? !isUpdatingPreference : true,
                      switchLoading: index == 2 ? isUpdatingPreference : false,
                      onTap: onTapSetting == null
                          ? null
                          : () => onTapSetting!(index),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (footerSection != null) ...[
            SizedBox(height: context.h(20)),
            footerSection!,
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.slotWidth,
    this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  /// Width of one stat slot (row minus gaps / 4); drives padding and font scale.
  final double slotWidth;

  @override
  Widget build(BuildContext context) {
    final pad = math.min(20.0, math.max(8.0, slotWidth * 0.22));
    final valueSize = math.min(28.0, math.max(14.0, slotWidth * 0.34));
    final labelSize = math.min(12.0, math.max(9.0, slotWidth * 0.14));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.radius(12)),
      child: WebDashboardPanel(
        backgroundColor: context.appColors.blue10,
        padding: EdgeInsets.all(pad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.appText.text28W700.copyWith(
                color: context.appColors.onSurface,
                fontSize: valueSize,
              ),
            ),
            SizedBox(height: math.min(8.0, pad * 0.35)),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              style: context.appText.text12W400.copyWith(
                color: context.appColors.greyDark,
                fontSize: labelSize,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebProfileCardShimmer extends StatelessWidget {
  const _WebProfileCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerBox(width: 104, height: 104, shape: BoxShape.circle),
        SizedBox(height: 16),
        ShimmerBox(width: 140, height: 18),
        SizedBox(height: 10),
        ShimmerBox(width: 120, height: 12),
        SizedBox(height: 18),
        ShimmerBox(height: 42),
      ],
    );
  }
}
