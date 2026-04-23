import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/UpdateMatch/update_match_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Routes/routes_name.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Home/viewModel/create_match_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/drop_down_from_field_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/match_duration_picker_sheet.dart';
import 'package:sport_finding/feature/widget/max_players_stepper_field.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  bool _didPopulateEditState = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPopulateEditState) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    final model = context.read<CreateMatchViewModel>();

    if (args is UpdateMatchModel) {
      model.populateForEdit(args, context);
      _didPopulateEditState = true;
      return;
    }

    if (args is DiscoveryMatch) {
      model.populateForEditFromDiscoveryMatch(args, context);
      _didPopulateEditState = true;
    }
  }

  Future<void> _showDurationPicker(
    BuildContext context,
    CreateMatchViewModel model,
  ) {
    return showMatchDurationPickerSheet(
      context,
      initialTotalMinutes: model.duration,
      onConfirm: model.setDurationFromHms,
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<CreateMatchViewModel>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      resizeToAvoidBottomInset: true,
      body: MainFrame(
        child: Form(
          key: model.formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: RepaintBoundary(
              child: Padding(
                padding: context.padonly(
                  left: context.w(20),
                  right: context.w(20),
                  bottom: context.h(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.h(20)),
                        AppBarWidget(
                          onTapFirst: () => Navigator.pop(context),
                          title: AppText.sportFinding,
                        ),
                        SizedBox(height: context.h(20)),
                        Selector<CreateMatchViewModel, bool>(
                          selector: (_, m) => m.isEditMode,
                          builder: (context, isEditMode, _) {
                            return NormalText(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              titleText: isEditMode
                                  ? 'Edit Match'
                                  : AppText.createMatch,
                              titleStyle: context.appText.text18W600.copyWith(
                                color: context.appColors.onSurface,
                              ),
                              subText: isEditMode
                                  ? 'Update your match details and save changes.'
                                  : AppText.setUpANewGameForOthersToJoin,
                              subStyle: context.appText.text14W400.copyWith(
                                color: context.appColors.greyDark,
                              ),
                            );
                          },
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
                    Selector<CreateMatchViewModel, String?>(
                      selector: (_, m) => m.selectedSportType,
                      builder: (context, selectedSport, _) {
                        final vm = context.read<CreateMatchViewModel>();
                        return DropdownFormFieldWidget(
                          label: AppText.sportType,
                          hintText: AppText.chooseYourSports,
                          items: vm.sportTypes,
                          value: selectedSport,
                          onChanged: vm.setSportType,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppText.sportTypeValidation;
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: context.h(16)),
                    Selector<CreateMatchViewModel, String?>(
                      selector: (_, m) => m.selectedSkillLevel,
                      builder: (context, selectedSkill, _) {
                        final vm = context.read<CreateMatchViewModel>();
                        return DropdownFormFieldWidget(
                          label: AppText.skillLevel,
                          hintText: AppText.skillLevelHint,
                          items: vm.skillLevels,
                          value: selectedSkill,
                          onChanged: vm.setSkillLevel,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppText.skillLevelValidation;
                            }
                            return null;
                          },
                        );
                      },
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
                        if (date != null && context.mounted) {
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
                        if (time != null && context.mounted) {
                          model.setTime(time, context);
                        }
                      },
                    ),
                    SizedBox(height: context.h(16)),
                    TextFormFieldWidget(
                      label: AppText.location,
                      hintText: 'Tap to search location...',
                      controller: model.locationController,
                      readOnly: true,
                      customSuffix: Padding(
                        padding: EdgeInsets.all(context.w(12)),
                        child: Icon(
                          Icons.search,
                          size: context.w(20),
                          color: context.appColors.greyDark,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                      onTap: () async {
                        final selectedLocation = await Navigator.pushNamed(
                          context,
                          RoutesName.locationSearchScreen,
                        );
                        if (!context.mounted) return;
                        if (selectedLocation is String &&
                            selectedLocation.trim().isNotEmpty) {
                          model.locationController.text =
                              selectedLocation.trim();
                        }
                      },
                    ),
                    SizedBox(height: context.h(16)),
                    TextFormFieldWidget(
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
                    SizedBox(height: context.h(16)),
                    Selector<CreateMatchViewModel, int>(
                      selector: (_, m) => m.maxPlayers,
                      builder: (context, maxPlayers, _) {
                        final vm = context.read<CreateMatchViewModel>();
                        return MaxPlayersStepperField(
                          value: maxPlayers,
                          onChanged: vm.setMaxPlayers,
                        );
                      },
                    ),
                    SizedBox(height: context.h(16)),
                    Selector<CreateMatchViewModel, bool>(
                      selector: (_, m) => m.isEditMode,
                      builder: (context, isEditMode, _) {
                        return CustomButton(
                          text: isEditMode ? 'Save' : AppText.createMatch,
                          color: context.appColors.primary,
                          onTap: () async {
                            final vm = context.read<CreateMatchViewModel>();
                            final success = await vm.submitMatch();

                            if (!context.mounted) return;
                            if (success) {
                              if (vm.isEditMode) {
                                Navigator.pop(context, vm.updatedMatch);
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  RoutesName.matchCreatedDoneScreen,
                                  arguments: vm.createdMatch,
                                );
                              }
                            } else {
                              AppSnackBar.show(vm.error ?? 'Operation failed');
                            }
                          },
                        );
                      },
                    ),
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
