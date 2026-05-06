import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

/// Width-based text scale (375pt design width) clamped for readability.
/// Multiplies with the platform text scaler (accessibility) using a reference size.
TextScaler appResponsiveTextScaler(BuildContext context) {
  final mq = MediaQuery.of(context);
  final width = mq.size.width;
  final layoutFactor = (width / kFigmaDesignWidth).clamp(0.88, 1.22);
  final parent = mq.textScaler;
  final parentFactor = parent.scale(16) / 16;
  return TextScaler.linear((layoutFactor * parentFactor).clamp(0.8, 1.45));
}
