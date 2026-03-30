import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

/// Searchable single-select: looks and behaves like [DropdownFormFieldWidget]
/// (tap to open, no keyboard on the field). Search/filter only inside the sheet.
class SearchDropdownField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController controller;
  final List<String> items;

  const SearchDropdownField({
    super.key,
    this.label,
    this.hintText,
    required this.controller,
    required this.items,
  });

  @override
  State<SearchDropdownField> createState() => _SearchDropdownFieldState();
}

class _SearchDropdownFieldState extends State<SearchDropdownField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void didUpdateWidget(SearchDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onController);
      widget.controller.addListener(_onController);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (mounted) setState(() {});
  }

  Iterable<String> _optionsForQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items
        .where((e) => e.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Future<void> _openSheet() async {
    final searchController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final c = sheetContext.appColors;
        return StatefulBuilder(
          builder: (context, setModalState) {
            void bump() => setModalState(() {});

            final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
            final listMaxHeight = MediaQuery.sizeOf(sheetContext).height * 0.5;
            final filtered = _optionsForQuery(searchController.text).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(context.radiusR(16)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: context.h(8)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => bump(),
                        autofocus: true,
                        style: context.appText.text14W400.copyWith(
                          color: c.greyDark,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: context.appText.text14W400.copyWith(
                            color: c.greylight,
                          ),
                          prefixIcon: Icon(Icons.search, color: c.greyDark),
                          filled: true,
                          fillColor: c.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              context.radius(12),
                            ),
                            borderSide: BorderSide(
                              color: c.greylight,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              context.radius(12),
                            ),
                            borderSide: BorderSide(
                              color: c.greylight,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              context.radius(12),
                            ),
                            borderSide: BorderSide(
                              color: c.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: context.w(12),
                            vertical: context.h(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(8)),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: listMaxHeight),
                      child: filtered.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(context.h(24)),
                              child: Center(
                                child: Text(
                                  'No matches',
                                  style: context.appText.text14W400.copyWith(
                                    color: c.greylight,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(
                                horizontal: context.w(8),
                              ),
                              physics: const ClampingScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                color: c.greylight,
                              ),
                              itemBuilder: (ctx, i) {
                                final item = filtered[i];
                                return ListTile(
                                  title: Text(
                                    item,
                                    style: context.appText.text14W400.copyWith(
                                      color: c.greyDark,
                                    ),
                                  ),
                                  onTap: () {
                                    widget.controller.text = item;
                                    widget.controller.selection =
                                        TextSelection.collapsed(
                                          offset: item.length,
                                        );
                                    Navigator.pop(sheetContext);
                                  },
                                );
                              },
                            ),
                    ),
                    SizedBox(height: context.h(16)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    searchController.dispose();
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
        onTap: _openSheet,
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
