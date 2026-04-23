import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/google_places_service.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final GooglePlacesService _googlePlacesService = GooglePlacesService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<String> _results = <String>[];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleQueryListener);
  }

  void _handleQueryListener() {
    _onQueryChanged(_searchController.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_handleQueryListener);
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = <String>[];
        _error = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _googlePlacesService.searchPlaceSuggestions(
        trimmed,
      );
      if (!mounted) return;
      setState(() {
        _results = result.suggestions;
        if (result.suggestions.isNotEmpty) {
          _error = null;
        } else if (result.missingApiKey) {
          _error = result.userMessage;
        } else if (result.userMessage != null &&
            result.userMessage!.trim().isNotEmpty) {
          _error = result.userMessage;
        } else {
          _error = 'No locations found for "$trimmed".';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not search locations. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectLocation(String location) {
    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      resizeToAvoidBottomInset: true,
      body: MainFrame(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: context.padonly(
                left: context.w(20),
                right: context.w(20),
                bottom: context.h(20),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: context.h(20)),
                    AppBarWidget(
                      onTapFirst: () => Navigator.pop(context),
                      title: 'Search Location',
                    ),
                    SizedBox(height: context.h(20)),
                    TextFormFieldWidget(
                      label: 'Location',
                      hintText: 'Search city e.g. Peshawar',
                      controller: _searchController,
                    ),
                    SizedBox(height: context.h(8)),
                    if (hasQuery)
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxHeight: context.h(280)),
                        decoration: BoxDecoration(
                          color: context.appColors.onPrimary,
                          borderRadius:
                              BorderRadius.circular(context.radiusR(12)),
                          border: Border.all(
                            color: context.appColors.greylight,
                          ),
                        ),
                        child: _isLoading
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.h(16),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _error != null
                            ? SingleChildScrollView(
                                padding: EdgeInsets.all(context.w(12)),
                                child: Text(
                                  _error!,
                                  style: context.appText.text14W400.copyWith(
                                    color: context.appColors.greyDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : _results.isEmpty
                            ? Padding(
                                padding: EdgeInsets.all(context.w(12)),
                                child: Text(
                                  'No matching location found.',
                                  style: context.appText.text14W400.copyWith(
                                    color: context.appColors.greyDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _results.length,
                                separatorBuilder: (_, _) => Divider(
                                  color: context.appColors.greylight,
                                  height: 1,
                                ),
                                itemBuilder: (_, index) {
                                  final item = _results[index];
                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: context.w(12),
                                      vertical: context.h(2),
                                    ),
                                    title: Text(
                                      item,
                                      style: context.appText.text14W500
                                          .copyWith(
                                        color: context.appColors.onSurface,
                                      ),
                                    ),
                                    onTap: () => _selectLocation(item),
                                  );
                                },
                              ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
