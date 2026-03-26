import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/model/discovery_match.dart';

/// Reusable discovery match card: title, distance, sport, location, date/time, participants, See All.
class DiscoveryCard extends StatelessWidget {
  const DiscoveryCard({super.key, required this.match, this.onSeeAllTap});

  final DiscoveryMatch match;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: EdgeInsets.all(context.sw(16)),
      decoration: BoxDecoration(
        color: c.blue10,
        borderRadius: BorderRadius.circular(context.radiusR(12)),
        boxShadow: [
          BoxShadow(
            color: c.blue20.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  match.title,
                  style: context.appText.text16W600.copyWith(
                    color: c.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.sw(8),
                  vertical: context.sh(4),
                ),
                decoration: BoxDecoration(
                  color: c.blue10,
                  borderRadius: BorderRadius.circular(context.radiusR(8)),
                  border: Border.all(color: c.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${match.distanceKm} km',
                  style: context.appText.text12W500.copyWith(color: c.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sh(8)),
          Text(
            match.sportType,
            style: context.appText.text14W400.copyWith(color: c.onSurface),
          ),
          SizedBox(height: context.sh(8)),
          _InfoRow(
            iconPath: AppAssets.locationIcon,
            text: match.location,
            context: context,
          ),
          SizedBox(height: context.sh(4)),
          _InfoRow(
            iconPath: AppAssets.clockIcon,
            text: match.date,
            context: context,
          ),
          SizedBox(height: context.sh(4)),
          _InfoRow(
            iconPath: AppAssets.playerIcon,
            text: match.participantsLabel,
            context: context,
          ),
          SizedBox(height: context.sh(12)),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(context.radiusR(8)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sw(16),
                    vertical: context.sh(8),
                  ),
                  decoration: BoxDecoration(
                    color: c.blue10,
                    borderRadius: BorderRadius.circular(context.radiusR(8)),
                    border: Border.all(color: c.primary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    AppText.discover,
                    style: context.appText.text14W500.copyWith(
                      color: c.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.iconPath,
    required this.text,
    required this.context,
  });

  final String iconPath;
  final String text;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final c = this.context.appColors;
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: this.context.sw(16),
          height: this.context.sw(16),
          colorFilter: ColorFilter.mode(c.greyDark, BlendMode.srcIn),
        ),
        SizedBox(width: this.context.sw(8)),
        Expanded(
          child: Text(
            text,
            style: this.context.appText.text14W400.copyWith(color: c.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
