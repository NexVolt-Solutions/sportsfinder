import 'package:flutter/material.dart';

class ProfileItem {
  final String leading; // Icon path
  final String title;
  final String subtitle;
  final String trailingType; // "arrow" or "switch"
  bool switchValue; // mutable
  final VoidCallback? onTap;

  ProfileItem({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailingType,
    this.switchValue = false,
    this.onTap,
  });
}
