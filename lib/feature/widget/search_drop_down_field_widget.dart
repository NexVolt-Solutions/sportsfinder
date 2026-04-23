import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/core/Network/places_search_result.dart';

/// Searchable dropdown field - FIXED VERSION
/// Eliminates all lifecycle, layout, and color issues
class SearchDropdownField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController controller;
  final List<String> items;
  /// When set, queries Google Places Autocomplete (or your app’s search) for each query.
  final Future<PlacesSearchResult> Function(String query)? asyncPlacesSearch;

  const SearchDropdownField({
    super.key,
    this.label,
    this.hintText,
    required this.controller,
    required this.items,
    this.asyncPlacesSearch,
  });

  @override
  State<SearchDropdownField> createState() => _SearchDropdownFieldState();
}

class _SearchDropdownFieldState extends State<SearchDropdownField> {
  late TextEditingController _internalSearchController;

  @override
  void initState() {
    super.initState();
    _internalSearchController = TextEditingController();
    widget.controller.addListener(_notifyChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_notifyChange);
    _internalSearchController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    setState(() {});
  }

  void _openDropdown() async {
    _internalSearchController.clear();

    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DropdownSheet(
        searchController: _internalSearchController,
        items: widget.items,
        asyncPlacesSearch: widget.asyncPlacesSearch,
      ),
    );

    if (result != null && mounted) {
      widget.controller.text = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final hasValue = widget.controller.text.trim().isNotEmpty;

    return InputDecorator(
      decoration: InputDecoration(
        alignLabelWithHint: true,
        label: widget.label != null
            ? Text(
                widget.label!,
                style: context.appText.text16W400.copyWith(color: c.onSurface),
              )
            : null,
        filled: true,
        fillColor: c.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius(12)),
          borderSide: BorderSide(color: c.greylight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius(12)),
          borderSide: BorderSide(color: c.greylight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.radius(12)),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.w(12),
          vertical: context.h(8),
        ),
      ),
      child: InkWell(
        onTap: _openDropdown,
        borderRadius: BorderRadius.circular(context.radius(12)),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  hasValue ? widget.controller.text : (widget.hintText ?? ''),
                  style: context.appText.text14W400.copyWith(
                    color: hasValue ? c.greyDark : c.greylight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: c.greyDark),
          ],
        ),
      ),
    );
  }
}

/// Separate stateful widget for the dropdown sheet
/// Prevents lifecycle issues with the main widget
class _DropdownSheet extends StatefulWidget {
  final TextEditingController searchController;
  final List<String> items;
  final Future<PlacesSearchResult> Function(String query)? asyncPlacesSearch;

  const _DropdownSheet({
    required this.searchController,
    required this.items,
    this.asyncPlacesSearch,
  });

  @override
  State<_DropdownSheet> createState() => _DropdownSheetState();
}

class _DropdownSheetState extends State<_DropdownSheet> {
  late List<String> _filtered;
  bool _isLoading = false;
  int _activeRequest = 0;
  String? _asyncMessage;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    final raw = widget.searchController.text.trim();
    final qLower = raw.toLowerCase();
    if (widget.asyncPlacesSearch != null) {
      _loadAsyncItems(raw);
      return;
    }
    setState(() {
      _filtered = qLower.isEmpty
          ? widget.items
          : widget.items
                .where((item) => item.toLowerCase().contains(qLower))
                .toList();
    });
  }

  Future<void> _loadAsyncItems(String queryTrimmed) async {
    final requestId = ++_activeRequest;
    if (queryTrimmed.isEmpty) {
      setState(() {
        _isLoading = false;
        _filtered = widget.items;
        _asyncMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _asyncMessage = null;
    });

    try {
      final result = await widget.asyncPlacesSearch!(queryTrimmed);
      if (!mounted || requestId != _activeRequest) return;
      setState(() {
        _filtered = result.suggestions;
        if (result.suggestions.isEmpty) {
          if (result.missingApiKey) {
            _asyncMessage = result.userMessage;
          } else if (result.userMessage != null &&
              result.userMessage!.trim().isNotEmpty) {
            _asyncMessage = result.userMessage;
          } else {
            _asyncMessage = 'No locations found.';
          }
        } else {
          _asyncMessage = null;
        }
      });
    } catch (_) {
      if (!mounted || requestId != _activeRequest) return;
      setState(() {
        _filtered = const <String>[];
        _asyncMessage = 'Could not search locations. Please try again.';
      });
    } finally {
      if (mounted && requestId == _activeRequest) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Material(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search field
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    controller: widget.searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: Icon(Icons.search, color: c.greyDark),
                      filled: true,
                      fillColor: c.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.greylight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.greylight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.primary, width: 1.5),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // List or empty state
                Flexible(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              _asyncMessage ?? 'No items found',
                              style: context.appText.text14W400.copyWith(
                                color: c.greylight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            thickness: 0.5,
                            color: c.greylight,
                          ),
                          itemBuilder: (context, index) {
                            final item = _filtered[index];
                            return Material(
                              color: c.surface,
                              child: ListTile(
                                tileColor: c.surface,
                                title: Text(
                                  item,
                                  style: context.appText.text14W400.copyWith(
                                    color: c.greyDark,
                                  ),
                                ),
                                onTap: () => Navigator.pop(context, item),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
