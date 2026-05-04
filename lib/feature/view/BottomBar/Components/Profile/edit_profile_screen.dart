// // // import 'package:flutter/material.dart';
// // // import 'package:sport_finding/core/Constants/app_text.dart';
// // // import 'package:sport_finding/core/Constants/app_theme.dart';
// // // import 'package:sport_finding/core/Constants/size_extension.dart';
// // // import 'package:sport_finding/feature/widget/app_bar_widget.dart';
// // // import 'package:sport_finding/feature/widget/custom_button.dart';
// // // import 'package:sport_finding/feature/widget/mainframe.dart';
// // // import 'package:sport_finding/feature/widget/normal_text.dart';
// // // import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

// // // /// Demo avatar for edit-profile layout (matches design reference).
// // // const String _kEditProfileAvatarUrl =
// // //     'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400';

// // // class EditProfileScreen extends StatefulWidget {
// // //   const EditProfileScreen({super.key});

// // //   @override
// // //   State<EditProfileScreen> createState() => _EditProfileScreenState();
// // // }

// // // class _EditProfileScreenState extends State<EditProfileScreen> {
// // //   static const List<String> _sportOptions = [
// // //     AppText.basketball,
// // //     AppText.football,
// // //     AppText.tennis,
// // //     AppText.volleyball,
// // //   ];

// // //   static const List<String> _skillOptions = [
// // //     AppText.beginner,
// // //     AppText.intermediate,
// // //     AppText.advanced,
// // //   ];

// // //   late final TextEditingController _nameController;
// // //   late final TextEditingController _bioController;
// // //   late String _sportValue;
// // //   late String _skillValue;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _nameController = TextEditingController(text: 'Amnaa');
// // //     _bioController = TextEditingController(
// // //       text: AppText.passionateAboutSportsAndFitness,
// // //     );
// // //     _sportValue = AppText.basketball;
// // //     _skillValue = AppText.beginner;
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _nameController.dispose();
// // //     _bioController.dispose();
// // //     super.dispose();
// // //   }

// // //   InputDecoration _dropdownDecoration(BuildContext context, String label) {
// // //     final c = context.appColors;
// // //     final t = context.appText;
// // //     final radius = BorderRadius.circular(context.radius(12));
// // //     final side = BorderSide(color: c.greylight, width: 1);
// // //     return InputDecoration(
// // //       floatingLabelBehavior: FloatingLabelBehavior.auto,
// // //       labelText: label,
// // //       labelStyle: t.text16W400.copyWith(color: c.onSurface),
// // //       floatingLabelStyle: t.text12W400.copyWith(color: c.greylight),
// // //       filled: true,
// // //       fillColor: Colors.transparent,
// // //       contentPadding: context.padSym(h: 16, v: 18),
// // //       border: OutlineInputBorder(borderRadius: radius, borderSide: side),
// // //       enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: side),
// // //       focusedBorder: OutlineInputBorder(
// // //         borderRadius: radius,
// // //         borderSide: BorderSide(color: c.primary, width: 1.5),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final c = context.appColors;
// // //     final t = context.appText;
// // //     final avatarSize = context.w(104);

// // //     return Scaffold(
// // //       backgroundColor: Colors.transparent,
// // //       body: MainFrame(
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.stretch,
// // //           children: [
// // //             Padding(
// // //               padding: context.padSym(h: 20),
// // //               child: AppBarWidget(
// // //                 title: AppText.editProfile,
// // //                 onLeadingTap: () => Navigator.pop(context),
// // //               ),
// // //             ),
// // //             Expanded(
// // //               child: SingleChildScrollView(
// // //                 padding: context
// // //                     .padSym(h: 20)
// // //                     .copyWith(
// // //                       bottom:
// // //                           MediaQuery.viewInsetsOf(context).bottom +
// // //                           context.h(28),
// // //                     ),
// // //                 child: Column(
// // //                   children: [
// // //                     GestureDetector(
// // //                       onTap: () {},
// // //                       child: Stack(
// // //                         clipBehavior: Clip.none,
// // //                         alignment: Alignment.center,
// // //                         children: [
// // //                           ClipOval(
// // //                             child: SizedBox(
// // //                               width: avatarSize,
// // //                               height: avatarSize,
// // //                               child: Image.network(
// // //                                 _kEditProfileAvatarUrl,
// // //                                 fit: BoxFit.cover,
// // //                                 cacheWidth: 320,
// // //                                 filterQuality: FilterQuality.medium,
// // //                                 loadingBuilder: (ctx, child, progress) {
// // //                                   if (progress == null) return child;
// // //                                   return ColoredBox(
// // //                                     color: c.blue10,
// // //                                     child: Center(
// // //                                       child: SizedBox(
// // //                                         width: context.w(28),
// // //                                         height: context.w(28),
// // //                                         child: CircularProgressIndicator(
// // //                                           strokeWidth: 2,
// // //                                           color: c.primary,
// // //                                         ),
// // //                                       ),
// // //                                     ),
// // //                                   );
// // //                                 },
// // //                                 errorBuilder: (context, error, _) => ColoredBox(
// // //                                   color: c.blue10,
// // //                                   child: Icon(
// // //                                     Icons.person_rounded,
// // //                                     size: context.w(40),
// // //                                     color: c.primary,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           ),
// // //                           Positioned(
// // //                             right: context.w(2),
// // //                             bottom: context.w(2),
// // //                             child: Container(
// // //                               width: context.w(32),
// // //                               height: context.w(32),
// // //                               decoration: BoxDecoration(
// // //                                 color: Colors.white,
// // //                                 shape: BoxShape.circle,
// // //                                 boxShadow: [
// // //                                   BoxShadow(
// // //                                     color: Colors.black.withValues(alpha: 0.1),
// // //                                     blurRadius: 4,
// // //                                     offset: const Offset(0, 2),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                               child: Icon(
// // //                                 Icons.photo_camera_outlined,
// // //                                 size: context.w(18),
// // //                                 color: c.onSurface,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                     SizedBox(height: context.h(12)),
// // //                     Center(
// // //                       child: InkWell(
// // //                         onTap: () {},
// // //                         borderRadius: BorderRadius.circular(8),
// // //                         child: Padding(
// // //                           padding: context.padSym(h: 12, v: 6),
// // //                           child: NormalText(
// // //                             titleText: AppText.changePhoto,
// // //                             titleStyle: t.text14W600.copyWith(color: c.primary),
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     SizedBox(height: context.h(22)),
// // //                     TextFormFieldWidget(
// // //                       label: AppText.editProfileNameField,
// // //                       controller: _nameController,
// // //                       keyboardType: TextInputType.name,
// // //                     ),
// // //                     SizedBox(height: context.h(16)),
// // //                     TextFormFieldWidget(
// // //                       label: AppText.bio,
// // //                       controller: _bioController,
// // //                       maxLines: 3,
// // //                       keyboardType: TextInputType.multiline,
// // //                     ),
// // //                     SizedBox(height: context.h(16)),
// // //                     DropdownButtonFormField<String>(
// // //                       key: ValueKey<String>(_sportValue),
// // //                       isExpanded: true,
// // //                       initialValue: _sportValue,
// // //                       icon: Icon(
// // //                         Icons.keyboard_arrow_down_rounded,
// // //                         color: c.onSurface,
// // //                         size: context.w(22),
// // //                       ),
// // //                       style: t.text14W400.copyWith(color: c.greyDark),
// // //                       decoration: _dropdownDecoration(
// // //                         context,
// // //                         AppText.sportType,
// // //                       ),
// // //                       items: _sportOptions
// // //                           .map(
// // //                             (e) => DropdownMenuItem<String>(
// // //                               value: e,
// // //                               child: Text(e),
// // //                             ),
// // //                           )
// // //                           .toList(),
// // //                       onChanged: (v) {
// // //                         if (v != null) setState(() => _sportValue = v);
// // //                       },
// // //                     ),
// // //                     SizedBox(height: context.h(16)),
// // //                     DropdownButtonFormField<String>(
// // //                       key: ValueKey<String>(_skillValue),
// // //                       isExpanded: true,
// // //                       initialValue: _skillValue,
// // //                       icon: Icon(
// // //                         Icons.keyboard_arrow_down_rounded,
// // //                         color: c.onSurface,
// // //                         size: context.w(22),
// // //                       ),
// // //                       style: t.text14W400.copyWith(color: c.greyDark),
// // //                       decoration: _dropdownDecoration(
// // //                         context,
// // //                         AppText.skillLevel,
// // //                       ),
// // //                       items: _skillOptions
// // //                           .map(
// // //                             (e) => DropdownMenuItem<String>(
// // //                               value: e,
// // //                               child: Text(e),
// // //                             ),
// // //                           )
// // //                           .toList(),
// // //                       onChanged: (v) {
// // //                         if (v != null) setState(() => _skillValue = v);
// // //                       },
// // //                     ),
// // //                     SizedBox(height: context.h(28)),
// // //                     CustomButton(
// // //                       text: AppText.saveChanges,
// // //                       color: c.primary,
// // //                       colorText: c.onPrimary,
// // //                       onTap: () => Navigator.pop(context),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:sport_finding/core/Constants/app_text.dart';
// // import 'package:sport_finding/core/Constants/app_theme.dart';
// // import 'package:sport_finding/core/Constants/size_extension.dart';
// // import 'package:sport_finding/feature/widget/app_bar_widget.dart';
// // import 'package:sport_finding/feature/widget/custom_button.dart';
// // import 'package:sport_finding/feature/widget/mainframe.dart';
// // import 'package:sport_finding/feature/widget/normal_text.dart';
// // import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

// // class EditProfileScreen extends StatefulWidget {
// //   const EditProfileScreen({
// //     super.key,
// //     this.initialName,
// //     this.initialBio,
// //     this.initialAvatarUrl,
// //     this.initialSport,
// //     this.initialSkill,
// //   });

// //   final String? initialName;
// //   final String? initialBio;
// //   final String? initialAvatarUrl;
// //   final String? initialSport;
// //   final String? initialSkill;

// //   @override
// //   State<EditProfileScreen> createState() => _EditProfileScreenState();
// // }

// // class _EditProfileScreenState extends State<EditProfileScreen> {
// //   static const List<String> _sportOptions = [
// //     AppText.basketball,
// //     AppText.football,
// //     AppText.tennis,
// //     AppText.volleyball,
// //   ];

// //   static const List<String> _skillOptions = [
// //     AppText.beginner,
// //     AppText.intermediate,
// //     AppText.advanced,
// //   ];

// //   late final TextEditingController _nameController;
// //   late final TextEditingController _bioController;
// //   String? _sportValue;
// //   String? _skillValue;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _nameController = TextEditingController(text: widget.initialName ?? '');
// //     _bioController = TextEditingController(text: widget.initialBio ?? '');

// //     // Only set if the value exists in the options list
// //     _sportValue = _sportOptions.contains(widget.initialSport)
// //         ? widget.initialSport
// //         : null;
// //     _skillValue = _skillOptions.contains(widget.initialSkill)
// //         ? widget.initialSkill
// //         : null;
// //   }

// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _bioController.dispose();
// //     super.dispose();
// //   }

// //   InputDecoration _dropdownDecoration(BuildContext context, String label) {
// //     final c = context.appColors;
// //     final t = context.appText;
// //     final radius = BorderRadius.circular(context.radius(12));
// //     final side = BorderSide(color: c.greylight, width: 1);
// //     return InputDecoration(
// //       floatingLabelBehavior: FloatingLabelBehavior.auto,
// //       labelText: label,
// //       labelStyle: t.text16W400.copyWith(color: c.onSurface),
// //       floatingLabelStyle: t.text12W400.copyWith(color: c.greylight),
// //       filled: true,
// //       fillColor: Colors.transparent,
// //       contentPadding: context.padSym(h: 16, v: 18),
// //       border: OutlineInputBorder(borderRadius: radius, borderSide: side),
// //       enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: side),
// //       focusedBorder: OutlineInputBorder(
// //         borderRadius: radius,
// //         borderSide: BorderSide(color: c.primary, width: 1.5),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final c = context.appColors;
// //     final t = context.appText;
// //     final avatarSize = context.w(104);
// //     final avatarUrl = widget.initialAvatarUrl;

// //     return Scaffold(
// //       backgroundColor: Colors.transparent,
// //       body: MainFrame(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             Padding(
// //               padding: context.padSym(h: 20),
// //               child: AppBarWidget(
// //                 title: AppText.editProfile,
// //                 onLeadingTap: () => Navigator.pop(context),
// //               ),
// //             ),
// //             Expanded(
// //               child: SingleChildScrollView(
// //                 padding: context
// //                     .padSym(h: 20)
// //                     .copyWith(
// //                       bottom:
// //                           MediaQuery.viewInsetsOf(context).bottom +
// //                           context.h(28),
// //                     ),
// //                 child: Column(
// //                   children: [
// //                     GestureDetector(
// //                       onTap: () {},
// //                       child: Stack(
// //                         clipBehavior: Clip.none,
// //                         alignment: Alignment.center,
// //                         children: [
// //                           ClipOval(
// //                             child: SizedBox(
// //                               width: avatarSize,
// //                               height: avatarSize,
// //                               child: (avatarUrl != null && avatarUrl.isNotEmpty)
// //                                   ? Image.network(
// //                                       avatarUrl,
// //                                       fit: BoxFit.cover,
// //                                       cacheWidth: 320,
// //                                       filterQuality: FilterQuality.medium,
// //                                       loadingBuilder: (ctx, child, progress) {
// //                                         if (progress == null) return child;
// //                                         return ColoredBox(
// //                                           color: c.blue10,
// //                                           child: Center(
// //                                             child: SizedBox(
// //                                               width: context.w(28),
// //                                               height: context.w(28),
// //                                               child: CircularProgressIndicator(
// //                                                 strokeWidth: 2,
// //                                                 color: c.primary,
// //                                               ),
// //                                             ),
// //                                           ),
// //                                         );
// //                                       },
// //                                       errorBuilder: (context, error, _) =>
// //                                           ColoredBox(
// //                                             color: c.blue10,
// //                                             child: Icon(
// //                                               Icons.person_rounded,
// //                                               size: context.w(40),
// //                                               color: c.primary,
// //                                             ),
// //                                           ),
// //                                     )
// //                                   : ColoredBox(
// //                                       color: c.blue10,
// //                                       child: Icon(
// //                                         Icons.person_rounded,
// //                                         size: context.w(40),
// //                                         color: c.primary,
// //                                       ),
// //                                     ),
// //                             ),
// //                           ),
// //                           Positioned(
// //                             right: context.w(2),
// //                             bottom: context.w(2),
// //                             child: Container(
// //                               width: context.w(32),
// //                               height: context.w(32),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.white,
// //                                 shape: BoxShape.circle,
// //                                 boxShadow: [
// //                                   BoxShadow(
// //                                     color: Colors.black.withValues(alpha: 0.1),
// //                                     blurRadius: 4,
// //                                     offset: const Offset(0, 2),
// //                                   ),
// //                                 ],
// //                               ),
// //                               child: Icon(
// //                                 Icons.photo_camera_outlined,
// //                                 size: context.w(18),
// //                                 color: c.onSurface,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     SizedBox(height: context.h(12)),
// //                     Center(
// //                       child: InkWell(
// //                         onTap: () {},
// //                         borderRadius: BorderRadius.circular(8),
// //                         child: Padding(
// //                           padding: context.padSym(h: 12, v: 6),
// //                           child: NormalText(
// //                             titleText: AppText.changePhoto,
// //                             titleStyle: t.text14W600.copyWith(color: c.primary),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     SizedBox(height: context.h(22)),
// //                     TextFormFieldWidget(
// //                       label: AppText.editProfileNameField,
// //                       controller: _nameController,
// //                       keyboardType: TextInputType.name,
// //                     ),
// //                     SizedBox(height: context.h(16)),
// //                     TextFormFieldWidget(
// //                       label: AppText.bio,
// //                       controller: _bioController,
// //                       maxLines: 3,
// //                       keyboardType: TextInputType.multiline,
// //                     ),
// //                     SizedBox(height: context.h(16)),
// //                     DropdownButtonFormField<String>(
// //                       key: ValueKey<String?>(_sportValue),
// //                       isExpanded: true,
// //                       value: _sportValue,
// //                       icon: Icon(
// //                         Icons.keyboard_arrow_down_rounded,
// //                         color: c.onSurface,
// //                         size: context.w(22),
// //                       ),
// //                       style: t.text14W400.copyWith(color: c.greyDark),
// //                       decoration: _dropdownDecoration(
// //                         context,
// //                         AppText.sportType,
// //                       ),
// //                       items: _sportOptions
// //                           .map(
// //                             (e) => DropdownMenuItem<String>(
// //                               value: e,
// //                               child: Text(e),
// //                             ),
// //                           )
// //                           .toList(),
// //                       onChanged: (v) {
// //                         if (v != null) setState(() => _sportValue = v);
// //                       },
// //                     ),
// //                     SizedBox(height: context.h(16)),
// //                     DropdownButtonFormField<String>(
// //                       key: ValueKey<String?>(_skillValue),
// //                       isExpanded: true,
// //                       value: _skillValue,
// //                       icon: Icon(
// //                         Icons.keyboard_arrow_down_rounded,
// //                         color: c.onSurface,
// //                         size: context.w(22),
// //                       ),
// //                       style: t.text14W400.copyWith(color: c.greyDark),
// //                       decoration: _dropdownDecoration(
// //                         context,
// //                         AppText.skillLevel,
// //                       ),
// //                       items: _skillOptions
// //                           .map(
// //                             (e) => DropdownMenuItem<String>(
// //                               value: e,
// //                               child: Text(e),
// //                             ),
// //                           )
// //                           .toList(),
// //                       onChanged: (v) {
// //                         if (v != null) setState(() => _skillValue = v);
// //                       },
// //                     ),
// //                     SizedBox(height: context.h(28)),
// //                     CustomButton(
// //                       text: AppText.saveChanges,
// //                       color: c.primary,
// //                       colorText: c.onPrimary,
// //                       onTap: () => Navigator.pop(context),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/BottomBar/ViewModel/update_profile_provider.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/app_avatar.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.initialName,
    this.initialBio,
    this.initialAvatarUrl,
    this.initialSport,
    this.initialSkill,
  });

  final String? initialName;
  final String? initialBio;
  final String? initialAvatarUrl;
  final String? initialSport;
  final String? initialSkill;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const List<String> _sportOptions = [
    AppText.basketball,
    AppText.football,
    AppText.tennis,
    AppText.volleyball,
  ];

  static const List<String> _skillOptions = [
    AppText.beginner,
    AppText.intermediate,
    AppText.advanced,
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  String? _sportValue;
  String? _skillValue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _bioController = TextEditingController(text: widget.initialBio ?? '');

    _sportValue = _sportOptions.contains(widget.initialSport)
        ? widget.initialSport
        : null;
    _skillValue = _skillOptions.contains(widget.initialSkill)
        ? widget.initialSkill
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final vm = context.read<EditProfileScreenViewModel>();
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 88,
    );
    if (x == null) return;
    if (kIsWeb) {
      final b = await x.readAsBytes();
      vm.setPickedImage(bytes: b, fileName: x.name);
    } else {
      vm.setPickedImage(file: File(x.path));
    }
  }

  Future<void> _onSave() async {
    final vm = context.read<EditProfileScreenViewModel>();
    final ok = await vm.updateProfile(
      fullName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      sport: _sportValue,
      skillLevel: _skillValue,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      AppSnackBar.show('Profile updated');
    } else {
      AppSnackBar.show(vm.errorMessage ?? 'Could not update profile');
    }
  }

  String? _normalizedAvatarUrl(String? url) => normalizeImageUrl(url);

  InputDecoration _dropdownDecoration(BuildContext context, String label) {
    final c = context.appColors;
    final t = context.appText;
    final radius = BorderRadius.circular(context.radius(12));
    final side = BorderSide(color: c.greylight, width: 1);
    return InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      isDense: true,
      constraints: BoxConstraints(minHeight: context.h(64)),
      labelText: label,
      labelStyle: t.text16W400.copyWith(color: c.onSurface),
      floatingLabelStyle: t.text12W400.copyWith(color: c.greylight),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: context.padSym(h: 16, v: 12),
      border: OutlineInputBorder(borderRadius: radius, borderSide: side),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: side),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    final avatarSize = context.w(104);
    final avatarUrl = _normalizedAvatarUrl(widget.initialAvatarUrl);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MainFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: context.padSym(h: 20),
              child: AppBarWidget(
                title: AppText.editProfile,
                onLeadingTap: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: context
                    .padSym(h: 20)
                    .copyWith(
                      bottom:
                          MediaQuery.viewInsetsOf(context).bottom +
                          context.h(28),
                    ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: avatarSize,
                              height: avatarSize,
                              child: Consumer<EditProfileScreenViewModel>(
                                builder: (context, vm, _) {
                                  if (kIsWeb &&
                                      vm.pickedImageBytes != null &&
                                      vm.pickedImageBytes!.isNotEmpty) {
                                    return Image.memory(
                                      Uint8List.fromList(vm.pickedImageBytes!),
                                      fit: BoxFit.cover,
                                      width: avatarSize,
                                      height: avatarSize,
                                    );
                                  }
                                  if (!kIsWeb && vm.pickedImageFile != null) {
                                    return Image.file(
                                      vm.pickedImageFile!,
                                      fit: BoxFit.cover,
                                      width: avatarSize,
                                      height: avatarSize,
                                    );
                                  }
                                  if (avatarUrl != null && avatarUrl.isNotEmpty) {
                                    return Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      cacheWidth: 320,
                                      filterQuality: FilterQuality.medium,
                                      loadingBuilder: (ctx, child, progress) {
                                        if (progress == null) return child;
                                        return ColoredBox(
                                          color: c.blue10,
                                          child: Center(
                                            child: SizedBox(
                                              width: context.w(28),
                                              height: context.w(28),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: c.primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, _) =>
                                          ColoredBox(
                                            color: c.blue10,
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: context.w(40),
                                              color: c.primary,
                                            ),
                                          ),
                                    );
                                  }
                                  return ColoredBox(
                                    color: c.blue10,
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: context.w(40),
                                      color: c.primary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            right: context.w(2),
                            bottom: context.w(2),
                            child: Container(
                              width: context.w(32),
                              height: context.w(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.photo_camera_outlined,
                                size: context.w(18),
                                color: c.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(12)),
                    Center(
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: context.padSym(h: 12, v: 6),
                          child: NormalText(
                            titleText: AppText.changePhoto,
                            titleStyle: t.text14W600.copyWith(color: c.primary),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(22)),
                    TextFormFieldWidget(
                      label: AppText.editProfileNameField,
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: context.h(16)),
                    TextFormFieldWidget(
                      label: AppText.bio,
                      controller: _bioController,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                    ),
                    SizedBox(height: context.h(16)),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('sport_dropdown'),
                      isExpanded: true,
                      initialValue: _sportValue,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: c.onSurface,
                        size: context.w(22),
                      ),
                      style: t.text14W400.copyWith(color: c.greyDark),
                      decoration: _dropdownDecoration(
                        context,
                        AppText.sportType,
                      ),
                      items: _sportOptions
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _sportValue = v);
                      },
                    ),
                    SizedBox(height: context.h(16)),
                    DropdownButtonFormField<String>(
                      key: const ValueKey('skill_dropdown'),
                      isExpanded: true,
                      initialValue: _skillValue,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: c.onSurface,
                        size: context.w(22),
                      ),
                      style: t.text14W400.copyWith(color: c.greyDark),
                      decoration: _dropdownDecoration(
                        context,
                        AppText.skillLevel,
                      ),
                      items: _skillOptions
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _skillValue = v);
                      },
                    ),
                    SizedBox(height: context.h(28)),
                    Consumer<EditProfileScreenViewModel>(
                      builder: (context, vm, _) {
                        return CustomButton(
                          text: vm.isLoading
                              ? 'Saving...'
                              : AppText.saveChanges,
                          color: c.primary,
                          colorText: c.onPrimary,
                          onTap: vm.isLoading ? () {} : _onSave,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:sport_finding/core/Constants/app_text.dart';
// import 'package:sport_finding/core/Constants/app_theme.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';
// import 'package:sport_finding/feature/view/BottomBar/ViewModel/update_profile_provider.dart';
// import 'package:sport_finding/feature/widget/app_bar_widget.dart';
// import 'package:sport_finding/feature/widget/custom_button.dart';
// import 'package:sport_finding/feature/widget/mainframe.dart';
// import 'package:sport_finding/feature/widget/normal_text.dart';
// import 'package:sport_finding/feature/widget/text_form_field_widget.dart';
 
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({
//     super.key,
//     this.initialName,
//     this.initialBio,
//     this.initialAvatarUrl,
//     this.initialSport,
//     this.initialSkill,
//   });

//   final String? initialName;
//   final String? initialBio;
//   final String? initialAvatarUrl;
//   final String? initialSport;
//   final String? initialSkill;

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   static const List<String> _sportOptions = [
//     AppText.basketball,
//     AppText.football,
//     AppText.tennis,
//     AppText.volleyball,
//   ];

//   static const List<String> _skillOptions = [
//     AppText.beginner,
//     AppText.intermediate,
//     AppText.advanced,
//   ];

//   late final TextEditingController _nameController;
//   late final TextEditingController _bioController;
//   String? _sportValue;
//   String? _skillValue;

//   final ImagePicker _picker = ImagePicker();
//   String? _localImagePath;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.initialName ?? '');
//     _bioController = TextEditingController(text: widget.initialBio ?? '');

//     _sportValue = _sportOptions.contains(widget.initialSport)
//         ? widget.initialSport
//         : null;
//     _skillValue = _skillOptions.contains(widget.initialSkill)
//         ? widget.initialSkill
//         : null;

//     _nameController.addListener(() => setState(() {}));
//     _bioController.addListener(() => setState(() {}));
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage(BuildContext context) async {
//     final XFile? picked = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );

//     if (picked == null) return;

//     if (kIsWeb) {
//       final bytes = await picked.readAsBytes();
//       context.read<EditProfileScreenViewModel>().setPickedImage(
//             bytes: bytes,
//             fileName: picked.name,
//           );
//     } else {
//       context.read<EditProfileScreenViewModel>().setPickedImage(
//             file: File(picked.path),
//           );
//     }

//     setState(() => _localImagePath = picked.path);
//   }

//   Future<void> _onSave(BuildContext context) async {
//     final name = _nameController.text.trim();
//     final bio = _bioController.text.trim();

//     if (name.isEmpty) {
//       _showSnackBar(context, 'Name cannot be empty', isError: true);
//       return;
//     }

//     final provider =
//         Provider.of<EditProfileScreenViewModel>(context, listen: false);

//     final success = await provider.updateProfile(
//       fullName: name,
//       bio: bio,
//       sport: _sportValue,
//       skillLevel: _skillValue,
//     );

//     if (!mounted) return;

//     if (success) {
//       _showSnackBar(context, 'Profile updated successfully!');
//       await Future.delayed(const Duration(milliseconds: 800));
//       if (mounted) Navigator.pop(context, provider.updatedProfile);
//     } else {
//       _showSnackBar(
//         context,
//         provider.errorMessage ?? 'Something went wrong.',
//         isError: true,
//       );
//     }
//   }

//   void _showSnackBar(BuildContext context, String message,
//       {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.redAccent : Colors.green,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   bool _isValidUrl(String? url) =>
//       url != null && url.isNotEmpty && url.startsWith('http');

//   InputDecoration _dropdownDecoration(BuildContext context, String label) {
//     final c = context.appColors;
//     final t = context.appText;
//     final radius = BorderRadius.circular(context.radius(12));
//     final side = BorderSide(color: c.greylight, width: 1);
//     return InputDecoration(
//       floatingLabelBehavior: FloatingLabelBehavior.auto,
//       labelText: label,
//       labelStyle: t.text16W400.copyWith(color: c.onSurface),
//       floatingLabelStyle: t.text12W400.copyWith(color: c.greylight),
//       filled: true,
//       fillColor: Colors.transparent,
//       contentPadding: context.padSym(h: 16, v: 18),
//       border: OutlineInputBorder(borderRadius: radius, borderSide: side),
//       enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: side),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: radius,
//         borderSide: BorderSide(color: c.primary, width: 1.5),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = context.appColors;
//     final t = context.appText;
//     final avatarSize = context.w(104);
//     final avatarUrl = widget.initialAvatarUrl;
//     final isLoading = context.watch<EditProfileScreenViewModel>().isLoading;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: MainFrame(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Padding(
//               padding: context.padSym(h: 20),
//               child: AppBarWidget(
//                 title: AppText.editProfile,
//                 onLeadingTap: () => Navigator.pop(context),
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: context
//                     .padSym(h: 20)
//                     .copyWith(
//                       bottom:
//                           MediaQuery.viewInsetsOf(context).bottom +
//                           context.h(28),
//                     ),
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: () => _pickImage(context),
//                       child: Stack(
//                         clipBehavior: Clip.none,
//                         alignment: Alignment.center,
//                         children: [
//                           ClipOval(
//                             child: SizedBox(
//                               width: avatarSize,
//                               height: avatarSize,
//                               child: _localImagePath != null
//                                   ? Image.file(
//                                       File(_localImagePath!),
//                                       fit: BoxFit.cover,
//                                     )
//                                   : _isValidUrl(avatarUrl)
//                                       ? Image.network(
//                                           avatarUrl!,
//                                           fit: BoxFit.cover,
//                                           cacheWidth: 320,
//                                           filterQuality: FilterQuality.medium,
//                                           loadingBuilder:
//                                               (ctx, child, progress) {
//                                             if (progress == null) return child;
//                                             return ColoredBox(
//                                               color: c.blue10,
//                                               child: Center(
//                                                 child: SizedBox(
//                                                   width: context.w(28),
//                                                   height: context.w(28),
//                                                   child:
//                                                       CircularProgressIndicator(
//                                                     strokeWidth: 2,
//                                                     color: c.primary,
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                           errorBuilder: (context, error, _) =>
//                                               ColoredBox(
//                                             color: c.blue10,
//                                             child: Icon(
//                                               Icons.person_rounded,
//                                               size: context.w(40),
//                                               color: c.primary,
//                                             ),
//                                           ),
//                                         )
//                                       : ColoredBox(
//                                           color: c.blue10,
//                                           child: Icon(
//                                             Icons.person_rounded,
//                                             size: context.w(40),
//                                             color: c.primary,
//                                           ),
//                                         ),
//                             ),
//                           ),
//                           Positioned(
//                             right: context.w(2),
//                             bottom: context.w(2),
//                             child: Container(
//                               width: context.w(32),
//                               height: context.w(32),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color:
//                                         Colors.black.withValues(alpha: 0.1),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Icon(
//                                 Icons.photo_camera_outlined,
//                                 size: context.w(18),
//                                 color: c.onSurface,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: context.h(12)),
//                     Center(
//                       child: InkWell(
//                         onTap: () => _pickImage(context),
//                         borderRadius: BorderRadius.circular(8),
//                         child: Padding(
//                           padding: context.padSym(h: 12, v: 6),
//                           child: NormalText(
//                             titleText: AppText.changePhoto,
//                             titleStyle:
//                                 t.text14W600.copyWith(color: c.primary),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: context.h(22)),
//                     TextFormFieldWidget(
//                       label: AppText.editProfileNameField,
//                       controller: _nameController,
//                       keyboardType: TextInputType.name,
//                     ),
//                     SizedBox(height: context.h(16)),
//                     TextFormFieldWidget(
//                       label: AppText.bio,
//                       controller: _bioController,
//                       maxLines: 3,
//                       keyboardType: TextInputType.multiline,
//                     ),
//                     SizedBox(height: context.h(16)),
//                     DropdownButtonFormField<String>(
//                       key: const ValueKey('sport_dropdown'),
//                       isExpanded: true,
//                       value: _sportValue,
//                       icon: Icon(
//                         Icons.keyboard_arrow_down_rounded,
//                         color: c.onSurface,
//                         size: context.w(22),
//                       ),
//                       style: t.text14W400.copyWith(color: c.greyDark),
//                       decoration: _dropdownDecoration(
//                         context,
//                         AppText.sportType,
//                       ),
//                       items: _sportOptions
//                           .map(
//                             (e) => DropdownMenuItem<String>(
//                               value: e,
//                               child: Text(e),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (v) {
//                         if (v != null) setState(() => _sportValue = v);
//                       },
//                     ),
//                     SizedBox(height: context.h(16)),
//                     DropdownButtonFormField<String>(
//                       key: const ValueKey('skill_dropdown'),
//                       isExpanded: true,
//                       value: _skillValue,
//                       icon: Icon(
//                         Icons.keyboard_arrow_down_rounded,
//                         color: c.onSurface,
//                         size: context.w(22),
//                       ),
//                       style: t.text14W400.copyWith(color: c.greyDark),
//                       decoration: _dropdownDecoration(
//                         context,
//                         AppText.skillLevel,
//                       ),
//                       items: _skillOptions
//                           .map(
//                             (e) => DropdownMenuItem<String>(
//                               value: e,
//                               child: Text(e),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (v) {
//                         if (v != null) setState(() => _skillValue = v);
//                       },
//                     ),
//                     SizedBox(height: context.h(28)),
//                     isLoading
//                         ? Center(
//                             child: CircularProgressIndicator(
//                               color: c.primary,
//                             ),
//                           )
//                         : CustomButton(
//                             text: AppText.saveChanges,
//                             color: c.primary,
//                             colorText: c.onPrimary,
//                             onTap: () => _onSave(context),
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
