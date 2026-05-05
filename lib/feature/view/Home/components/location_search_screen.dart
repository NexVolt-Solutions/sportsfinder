import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/google_places_service.dart';
import 'package:sport_finding/core/Network/location_selection_result.dart';
import 'package:sport_finding/core/Storage/app_preferences.dart';
import 'package:sport_finding/feature/widget/app_bar_widget.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';

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
  List<String> _history = <String>[];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleQueryListener);
    unawaited(_loadHistory());
  }

  void _handleQueryListener() {
    setState(() {});
    _onQueryChanged(_searchController.text);
  }

  Future<void> _loadHistory() async {
    final list = await AppPreferences.getLocationSearchHistory();
    if (!mounted) return;
    setState(() => _history = list);
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
      if (!mounted) return;
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
      final result = await _googlePlacesService.searchPlaceSuggestions(trimmed);
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

  Future<void> _selectLocation(String location) async {
    final coords = await _googlePlacesService.geocodeAddress(location);
    await AppPreferences.addLocationSearchHistoryItem(location);
    if (!mounted) return;
    await _loadHistory();
    if (!mounted) return;
    Navigator.pop(
      context,
      LocationSelectionResult(
        location: location,
        latitude: coords?.$1,
        longitude: coords?.$2,
      ),
    );
  }

  Future<void> _removeHistoryItem(String item) async {
    await AppPreferences.removeLocationSearchHistoryItem(item);
    if (!mounted) return;
    setState(() {
      _history = List<String>.from(_history)..remove(item);
    });
  }

  Future<void> _clearHistory() async {
    await AppPreferences.clearLocationSearchHistory();
    if (!mounted) return;
    setState(() => _history = <String>[]);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final query = _searchController.text;

    return Scaffold(
      backgroundColor: c.surface,
      resizeToAvoidBottomInset: true,
      body: MainFrame(
        child: Padding(
          padding: context.padonly(
            left: context.w(20),
            right: context.w(20),
            bottom: context.h(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: context.h(8)),
              AppBarWidget(
                onTapFirst: () => Navigator.pop(context),
                title: 'Search location',
              ),
              SizedBox(height: context.h(16)),
              _LocationSearchField(
                controller: _searchController,
                query: query,
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    _results = <String>[];
                    _error = null;
                    _isLoading = false;
                  });
                },
              ),
              SizedBox(height: context.h(12)),
              Expanded(
                child: hasQuery
                    ? _LocationSuggestionsBody(
                        isLoading: _isLoading,
                        error: _error,
                        results: _results,
                        onSelectLocation: _selectLocation,
                      )
                    : _LocationHistoryBody(
                        history: _history,
                        onClearHistory: _clearHistory,
                        onSelectLocation: _selectLocation,
                        onRemoveHistoryItem: _removeHistoryItem,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSearchField extends StatelessWidget {
  const _LocationSearchField({
    required this.controller,
    required this.query,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    return TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.sentences,
      style: t.text16W400.copyWith(color: c.onSurface, height: 1.3),
      cursorColor: c.primary,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search city or area',
        hintStyle: t.text16W400.copyWith(color: c.greylight),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: context.w(22),
          color: c.greylight,
        ),
        suffixIcon: query.trim().isNotEmpty
            ? IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  size: context.w(20),
                  color: c.greyDark,
                ),
                style: IconButton.styleFrom(foregroundColor: c.greyDark),
                tooltip: 'Clear',
              )
            : null,
        filled: true,
        fillColor: c.blue10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius(14)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius(14)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius(14)),
          borderSide: BorderSide(color: c.primary, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: context.h(14),
          horizontal: context.w(4),
        ),
      ),
    );
  }
}

class _LocationSuggestionsBody extends StatelessWidget {
  const _LocationSuggestionsBody({
    required this.isLoading,
    required this.error,
    required this.results,
    required this.onSelectLocation,
  });

  final bool isLoading;
  final String? error;
  final List<String> results;
  final ValueChanged<String> onSelectLocation;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2, color: c.primary),
        ),
      );
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(8)),
          child: Text(
            error!,
            textAlign: TextAlign.center,
            style: t.text14W400.copyWith(color: c.greyDark, height: 1.45),
          ),
        ),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No matches for your search.',
          style: t.text14W400.copyWith(color: c.greylight),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.only(top: context.h(4), bottom: context.h(24)),
      itemCount: results.length,
      separatorBuilder: (context, _) => SizedBox(height: context.h(2)),
      itemBuilder: (context, index) {
        final item = results[index];
        return _LocationTile(
          title: item,
          leading: Icons.place_outlined,
          onTap: () => onSelectLocation(item),
        );
      },
    );
  }
}

class _LocationHistoryBody extends StatelessWidget {
  const _LocationHistoryBody({
    required this.history,
    required this.onClearHistory,
    required this.onSelectLocation,
    required this.onRemoveHistoryItem,
  });

  final List<String> history;
  final VoidCallback onClearHistory;
  final ValueChanged<String> onSelectLocation;
  final ValueChanged<String> onRemoveHistoryItem;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: context.w(40),
              color: c.greylight,
            ),
            SizedBox(height: context.h(12)),
            Text(
              'Start typing to find a place',
              style: t.text16W500.copyWith(color: c.greyDark),
            ),
            SizedBox(height: context.h(6)),
            Text(
              'Your recent searches will appear here.',
              textAlign: TextAlign.center,
              style: t.text14W400.copyWith(color: c.greylight),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Recent',
              style: t.text12W600.copyWith(
                color: c.greyDark,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onClearHistory,
              style: TextButton.styleFrom(
                foregroundColor: c.primary,
                padding: EdgeInsets.symmetric(horizontal: context.w(8)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Clear all', style: t.text12W600),
            ),
          ],
        ),
        SizedBox(height: context.h(8)),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(bottom: context.h(24)),
            itemCount: history.length,
            separatorBuilder: (context, _) => SizedBox(height: context.h(2)),
            itemBuilder: (context, index) {
              final item = history[index];
              return _LocationTile(
                title: item,
                leading: Icons.history_rounded,
                onTap: () => onSelectLocation(item),
                onRemove: () => onRemoveHistoryItem(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.title,
    required this.leading,
    required this.onTap,
    this.onRemove,
  });

  final String title;
  final IconData leading;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final t = context.appText;
    return Material(
      color: c.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.radius(12)),
        splashColor: c.primary.withValues(alpha: 0.08),
        highlightColor: c.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: context.h(12),
            horizontal: context.w(4),
          ),
          child: Row(
            children: [
              Icon(leading, size: context.w(22), color: c.greyDark),
              SizedBox(width: context.w(12)),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.text16W500.copyWith(color: c.onSurface, height: 1.3),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.close,
                    size: context.w(18),
                    color: c.greylight,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: Size(context.w(36), context.h(36)),
                    padding: EdgeInsets.zero,
                  ),
                  tooltip: 'Remove from recent',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
