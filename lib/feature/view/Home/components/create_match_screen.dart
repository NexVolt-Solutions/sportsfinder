import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:sport_finding/core/Network/location_selection_result.dart';
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
import 'package:sport_finding/feature/webwidget/web_create_match_content.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  bool _didPopulateEditState = false;
  bool _scheduledOptions = false;
  /// Captured synchronously; never read [ModalRoute] after an async gap.
  Object? _routeArgs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeArgs ??= ModalRoute.of(context)?.settings.arguments;
    if (_scheduledOptions) return;
    _scheduledOptions = true;
    final model = context.read<CreateMatchViewModel>();
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

  void _applyRouteAfterOptions(CreateMatchViewModel model) {
    if (!context.mounted || _didPopulateEditState) return;
    final args = _routeArgs;
    if (args is UpdateMatchModel) {
      model.populateForEdit(args, context);
      _didPopulateEditState = true;
      return;
    }
    if (args is DiscoveryMatch) {
      model.populateForEditFromDiscoveryMatch(args, context);
      _didPopulateEditState = true;
      return;
    }
    // New match: sport/skill describe this match for other players — not the host's profile.
    _didPopulateEditState = true;
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
    final formBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Selector<CreateMatchViewModel, (bool, String?)>(
          selector: (_, m) => (m.optionsLoading, m.optionsError),
          builder: (context, state, _) {
             final err = state.$2;
           
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
                        final m = context.read<CreateMatchViewModel>();
                        m.ensureOptionsLoaded().then((_) {
                          if (!context.mounted) return;
                          if (m.optionsLoaded) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
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
        SectionHeaderWidget(title: AppText.basicInfo),
        SizedBox(height: context.h(10)),
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
        SizedBox(height: context.h(10)),
        TextFormFieldWidget(
          label: AppText.description,
          hintText: AppText.descriptionHit,
          controller: model.descriptionController,
          maxLines: 5,
        ),
        SizedBox(height: context.h(10)),
        SectionHeaderWidget(title: AppText.schedule),
        SizedBox(height: context.h(10)),
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
              child: SvgPicture.asset(AppAssets.calendarIcon, fit: BoxFit.contain),
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
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null && context.mounted) {
              model.setDate(date);
            }
          },
        ),
        SizedBox(height: context.h(10)),
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
              child: SvgPicture.asset(AppAssets.homeTimeIcon, fit: BoxFit.contain),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppText.selectMatchTimeRequired;
            }
            return null;
          },
          onTap: () async {
            final vm = context.read<CreateMatchViewModel>();
            final time = await showTimePicker(
              context: context,
              initialTime: vm.pickerInitialTime,
            );
            if (time != null && context.mounted) {
              vm.setTime(time, context);
            }
          },
        ),
        SizedBox(height: context.h(10)),
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
            if (selectedLocation is LocationSelectionResult &&
                selectedLocation.location.trim().isNotEmpty) {
              model.setSelectedLocation(selectedLocation);
            } else if (selectedLocation is String &&
                selectedLocation.trim().isNotEmpty) {
              model.locationController.text = selectedLocation.trim();
            }
          },
        ),
        SizedBox(height: context.h(10)),
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
        SizedBox(height: context.h(10)),
        Selector<CreateMatchViewModel, (String?, List<String>, bool)>(
          selector: (_, m) => (
            m.selectedSportType,
            m.sportTypes,
            m.optionsLoading,
          ),
          builder: (context, state, _) {
            final selectedSport = state.$1;
            final sportTypes = state.$2;
            final optionsLoading = state.$3;
            final vm = context.read<CreateMatchViewModel>();
            final hasSportOptions = sportTypes.isNotEmpty;
            return DropdownFormFieldWidget(
              label: AppText.sportType,
              hintText: optionsLoading
                  ? 'Loading sports...'
                  : hasSportOptions
                  ? AppText.selectSportType
                  : 'No sports available',
              items: sportTypes,
              value: selectedSport,
              onChanged: hasSportOptions ? vm.setSportType : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppText.sportTypeValidation;
                }
                return null;
              },
            );
          },
        ),
        SizedBox(height: context.h(10)),
        Selector<CreateMatchViewModel, (String?, List<String>, bool)>(
          selector: (_, m) => (
            m.selectedSkillLevel,
            m.skillLevels,
            m.optionsLoading,
          ),
          builder: (context, state, _) {
            final selectedSkill = state.$1;
            final skillLevels = state.$2;
            final optionsLoading = state.$3;
            final vm = context.read<CreateMatchViewModel>();
            final hasSkillOptions = skillLevels.isNotEmpty;
            return DropdownFormFieldWidget(
              label: AppText.skillLevel,
              hintText: optionsLoading
                  ? 'Loading skills...'
                  : hasSkillOptions
                  ? AppText.selectYourSkill
                  : 'No skill levels available',
              items: skillLevels,
              value: selectedSkill,
              onChanged: hasSkillOptions ? vm.setSkillLevel : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppText.skillLevelValidation;
                }
                return null;
              },
            );
          },
        ),
        SizedBox(height: context.h(10)),
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
      ],
    );

    return Scaffold(
      backgroundColor: context.appColors.surface,
      resizeToAvoidBottomInset: true,
      body: kIsWeb
          ? Form(
              key: model.formKey,
              child: WebCreateMatchContent(
                header: Selector<CreateMatchViewModel, bool>(
                  selector: (_, m) => m.isEditMode,
                  builder: (context, isEditMode, _) {
                    return WebDashboardTitle(
                      title: isEditMode ? 'Edit Match' : 'Create Match',
                      subtitle: isEditMode
                          ? 'Update match details'
                          : 'Add new match details',
                    );
                  },
                ),
                formBody: formBody,
                submitButton: Selector<CreateMatchViewModel, (bool, bool)>(
                  selector: (_, m) => (m.isEditMode, m.isLoading),
                  builder: (context, state, _) {
                    final isSubmitting = state.$2;
                    return CustomButton(
                      text: 'Save Changes',
                      color: context.appColors.primary,
                      isLoading: isSubmitting,
                      onTap: () async {
                        final vm = context.read<CreateMatchViewModel>();
                        if (vm.isLoading) return;
                        final success = await vm.submitMatch();

                        if (!context.mounted) return;
                        if (success) {
                          if (vm.isEditMode) {
                            Navigator.pop(context, vm.updatedMatch);
                          } else {
                            final createdMatch = vm.createdMatch;
                            if (createdMatch == null) {
                              AppSnackBar.show(
                                'Match created but details are unavailable',
                              );
                              return;
                            }
                            Navigator.pushReplacementNamed(
                              context,
                              RoutesName.matchCreatedDoneScreen,
                              arguments: createdMatch,
                            );
                          }
                        } else {
                          AppSnackBar.show(vm.error ?? 'Operation failed');
                        }
                      },
                    );
                  },
                ),
              ),
            )
          : MainFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: context.w(20),
                      right: context.w(20),
                     ),
                    child: AppBarWidget(
                      onTapFirst: () => Navigator.pop(context),
                      title: AppText.sportFinding,
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: model.formKey,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: RepaintBoundary(
                          child: Padding(
                            padding: context.padonly(
                              left: context.w(20),
                              right: context.w(20),
                             ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Selector<CreateMatchViewModel, bool>(
                                  selector: (_, m) => m.isEditMode,
                                  builder: (context, isEditMode, _) {
                                    return NormalText(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      titleText: isEditMode
                                          ? 'Edit Match'
                                          : AppText.createMatch,
                                      titleStyle:
                                          context.appText.text18W600.copyWith(
                                            color: context.appColors.onSurface,
                                          ),
                                      subText: isEditMode
                                          ? 'Update your match details and save changes.'
                                          : AppText
                                              .setUpANewGameForOthersToJoin,
                                      subStyle: context.appText.text14W400
                                          .copyWith(
                                            color: context.appColors.greyDark,
                                          ),
                                    );
                                  },
                                ),
                    SizedBox(height: context.h(8)),
                    Selector<CreateMatchViewModel, (bool, String?)>(
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
                                    final m =
                                        context.read<CreateMatchViewModel>();
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
                    SizedBox(height: context.h(10)),
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
                    SizedBox(height: context.h(10)),
                    TextFormFieldWidget(
                      label: AppText.description,
                      hintText: AppText.descriptionHit,
                      controller: model.descriptionController,
                      maxLines: 5,
                    ),
                    SizedBox(height: context.h(10)),
                    Selector<CreateMatchViewModel, (String?, List<String>, bool)>(
                      selector: (_, m) => (
                        m.selectedSportType,
                        m.sportTypes,
                        m.optionsLoading,
                      ),
                      builder: (context, state, _) {
                        final selectedSport = state.$1;
                        final sportTypes = state.$2;
                        final optionsLoading = state.$3;
                        final vm = context.read<CreateMatchViewModel>();
                        final hasSportOptions = sportTypes.isNotEmpty;
                        return DropdownFormFieldWidget(
                          label: AppText.sportType,
                          hintText: optionsLoading
                              ? 'Loading sports...'
                              : hasSportOptions
                              ? AppText.selectSportType
                              : 'No sports available',
                          items: sportTypes,
                          value: selectedSport,
                          onChanged: hasSportOptions ? vm.setSportType : null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppText.sportTypeValidation;
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: context.h(10)),
                    Selector<CreateMatchViewModel, (String?, List<String>, bool)>(
                      selector: (_, m) => (
                        m.selectedSkillLevel,
                        m.skillLevels,
                        m.optionsLoading,
                      ),
                      builder: (context, state, _) {
                        final selectedSkill = state.$1;
                        final skillLevels = state.$2;
                        final optionsLoading = state.$3;
                        final vm = context.read<CreateMatchViewModel>();
                        final hasSkillOptions = skillLevels.isNotEmpty;
                        return DropdownFormFieldWidget(
                          label: AppText.skillLevel,
                          hintText: optionsLoading
                              ? 'Loading skills...'
                              : hasSkillOptions
                              ? AppText.selectYourSkill
                              : 'No skill levels available',
                          items: skillLevels,
                          value: selectedSkill,
                          onChanged: hasSkillOptions ? vm.setSkillLevel : null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppText.skillLevelValidation;
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: context.h(10)),
                    SectionHeaderWidget(title: AppText.schedule),
                    SizedBox(height: context.h(10)),
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
                    SizedBox(height: context.h(10)),
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
                        final vm = context.read<CreateMatchViewModel>();
                        final time = await showTimePicker(
                          context: context,
                          initialTime: vm.pickerInitialTime,
                        );
                        if (time != null && context.mounted) {
                          vm.setTime(time, context);
                        }
                      },
                    ),
                    SizedBox(height: context.h(10)),
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
                        if (selectedLocation is LocationSelectionResult &&
                            selectedLocation.location.trim().isNotEmpty) {
                          model.setSelectedLocation(selectedLocation);
                        } else if (selectedLocation is String &&
                            selectedLocation.trim().isNotEmpty) {
                          model.locationController.text = selectedLocation.trim();
                        }
                      },
                    ),
                    SizedBox(height: context.h(10)),
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
                    SizedBox(height: context.h(10)),
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
                    SizedBox(height: context.h(10)),
                    Selector<CreateMatchViewModel, (bool, bool)>(
                      selector: (_, m) => (m.isEditMode, m.isLoading),
                      builder: (context, state, _) {
                        final isEditMode = state.$1;
                        final isSubmitting = state.$2;
                        return CustomButton(
                          text: isEditMode ? 'Save' : AppText.createMatch,
                          color: context.appColors.primary,
                          isLoading: isSubmitting,
                          onTap: () async {
                            final vm = context.read<CreateMatchViewModel>();
                            if (vm.isLoading) return;
                            final success = await vm.submitMatch();

                            if (!context.mounted) return;
                            if (success) {
                              if (vm.isEditMode) {
                                Navigator.pop(context, vm.updatedMatch);
                              } else {
                                final createdMatch = vm.createdMatch;
                                if (createdMatch == null) {
                                  AppSnackBar.show('Match created but details are unavailable');
                                  return;
                                }
                                Navigator.pushReplacementNamed(
                                  context,
                                  RoutesName.matchCreatedDoneScreen,
                                  arguments: createdMatch,
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
                ],
              ),
            ),
    );
  }
}
