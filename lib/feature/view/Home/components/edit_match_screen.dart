import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/Data/model/DeleteMAtch/delete_match_Model.dart';
import 'package:sport_finding/Data/model/UpdateMatch/update_match_model.dart';
import 'package:sport_finding/Data/model/discovery_match.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_text.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:sport_finding/feature/view/Home/viewModel/edit_match_view_model.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/custom_bottom_sheet_widget.dart';
import 'package:sport_finding/feature/widget/custom_button.dart';
import 'package:sport_finding/feature/widget/drop_down_from_field_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/match_duration_picker_sheet.dart';
import 'package:sport_finding/feature/widget/max_players_stepper_field.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_drop_down_field_widget.dart';
import 'package:sport_finding/feature/widget/section_header_widget.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class EditMatchScreen extends StatefulWidget {
  const EditMatchScreen({super.key});

  @override
  State<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends State<EditMatchScreen> {
  bool _didPopulateEditState = false;
  bool _scheduledOptions = false;
  Object? _routeArgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeArgs ??= ModalRoute.of(context)?.settings.arguments;
    if (_scheduledOptions) return;
    _scheduledOptions = true;
    final model = context.read<EditMatchViewModel>();
    model.ensureOptionsLoaded().then((_) {
      if (!context.mounted) return;
      if (model.optionsLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          _applyRouteAfterOptions(model);
        });
      }
    });
  }

  void _applyRouteAfterOptions(EditMatchViewModel model) {
    if (!context.mounted || _didPopulateEditState) return;
    final args = _routeArgs;
    if (args is UpdateMatchModel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        model.populateForEdit(args, context);
      });
      _didPopulateEditState = true;
      return;
    }
    if (args is DiscoveryMatch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        model.populateForEditFromDiscoveryMatch(args, context);
      });
      _didPopulateEditState = true;
      return;
    }
    _didPopulateEditState = true;
  }

  Future<void> _showDurationPicker(
    BuildContext context,
    EditMatchViewModel model,
  ) {
    return showMatchDurationPickerSheet(
      context,
      initialTotalMinutes: model.duration,
      onConfirm: model.setDurationFromHms,
    );
  }

  Future<void> _confirmDeleteMatch(
    BuildContext context,
    EditMatchViewModel model,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppText.deleteMatchConfirmationTitle),
        content: const Text(AppText.deleteMatchConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(AppText.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(AppText.deleteMatch),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    final success = await model.deleteMatch();
    if (!context.mounted) return;

    if (success && model.deletedMatch != null) {
      Navigator.pop<DeleteMatchModel>(context, model.deletedMatch);
      return;
    }

    AppSnackBar.show(
      model.error ?? 'Failed to delete match',
      backgroundColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<EditMatchViewModel>();

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
                        NormalText(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          titleText: 'Edit Match',
                          titleStyle: context.appText.text18W600.copyWith(
                            color: context.appColors.onSurface,
                          ),
                          subText:
                              'Update your match details and save changes.',
                          subStyle: context.appText.text14W400.copyWith(
                            color: context.appColors.greyDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(8)),
                    Selector<EditMatchViewModel, (bool, String?)>(
                      selector: (_, m) => (m.optionsLoading, m.optionsError),
                      builder: (context, state, _) {
                        final loading = state.$1;
                        final err = state.$2;
                        if (loading) {
                          return LinearProgressIndicator(
                            minHeight: 2,
                            color: context.appColors.primary,
                            backgroundColor: context.appColors.greylight
                                .withValues(alpha: 0.3),
                          );
                        }
                        if (err != null) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: context.h(8)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    err,
                                    style: context.appText.text12W400.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final m = context
                                        .read<EditMatchViewModel>();
                                    m.ensureOptionsLoaded().then((_) {
                                      if (!context.mounted) return;
                                      if (m.optionsLoaded) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (!context.mounted) return;
                                          _applyRouteAfterOptions(m);
                                        });
                                      }
                                    });
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: context.h(8)),
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
                    Selector<EditMatchViewModel, String?>(
                      selector: (_, m) => m.selectedSportType,
                      builder: (context, selectedSport, _) {
                        debugPrint(
                          '🎾 [EditMatchScreen] Selector rebuild - selectedSport: $selectedSport',
                        );
                        final vm = context.read<EditMatchViewModel>();
                        return DropdownFormFieldWidget(
                          label: AppText.sportType,
                          hintText: AppText.chooseYourSports,
                          items: vm.sportTypes,
                          value: selectedSport,
                          onChanged: (newValue) {
                            debugPrint(
                              '🎾 [EditMatchScreen] Sport changed to: $newValue',
                            );
                            vm.setSportType(newValue);
                          },
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
                    Selector<EditMatchViewModel, String?>(
                      selector: (_, m) => m.selectedSkillLevel,
                      builder: (context, selectedSkill, _) {
                        final vm = context.read<EditMatchViewModel>();
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppText.selectMatchDateRequired;
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppText.selectMatchTimeRequired;
                        }
                        return null;
                      },
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
                    SearchDropdownField(
                      label: AppText.location,
                      hintText: 'Search location...',
                      controller: model.locationController,
                      items: const <String>[],
                      asyncPlacesSearch: model.searchLocationSuggestions,
                    ),
                    SizedBox(height: context.h(12)),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: context.w(8)),
                        child: GestureDetector(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) => CustomBottomSheetWidget(
                                isCenter: true,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
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
                                                      .withValues(alpha: 0.8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.fullscreen,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {},
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
                    Selector<EditMatchViewModel, int>(
                      selector: (_, m) => m.maxPlayers,
                      builder: (context, maxPlayers, _) {
                        final vm = context.read<EditMatchViewModel>();
                        return MaxPlayersStepperField(
                          value: maxPlayers,
                          onChanged: vm.setMaxPlayers,
                        );
                      },
                    ),
                    SizedBox(height: context.h(16)),
                    Selector<
                      EditMatchViewModel,
                      ({bool isLoading, bool isDeleting})
                    >(
                      selector: (_, m) => (
                        isLoading: m.isLoading,
                        isDeleting: m.isDeleting,
                      ),
                      builder: (context, state, _) {
                        final vm = context.read<EditMatchViewModel>();
                        final busy = state.isLoading || state.isDeleting;
                        return Column(
                          children: [
                            CustomButton(
                              text: state.isLoading
                                  ? 'Saving...'
                                  : AppText.saveChanges,
                              color: context.appColors.primary,
                              isLoading: state.isLoading,
                              onTap: busy
                                  ? null
                                  : () async {
                                      final success = await vm.saveChanges();

                                      if (!context.mounted) return;

                                      if (success) {
                                        Navigator.pop(context, vm.updatedMatch);
                                      } else {
                                        AppSnackBar.show(
                                          vm.error ?? 'Failed to save changes',
                                          backgroundColor: Colors.red,
                                          duration: const Duration(
                                            seconds: 3,
                                          ),
                                        );
                                      }
                                    },
                            ),
                            SizedBox(height: context.h(12)),
                            CustomButton(
                              text: state.isDeleting
                                  ? AppText.deleting
                                  : AppText.deleteMatch,
                              color: context.appColors.transparent,
                              colorText: context.appColors.error,
                              borderColor: context.appColors.error,
                              outlined: true,
                              isLoading: state.isDeleting,
                              onTap: busy
                                  ? null
                                  : () => _confirmDeleteMatch(context, vm),
                            ),
                          ],
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
