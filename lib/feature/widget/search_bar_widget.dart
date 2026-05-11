
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/text_form_field_widget.dart';

/// Search field with a tappable search icon.
/// Tapping the magnifier submits the search by calling [onChanged].
class SearchBarWidget extends StatefulWidget {
  final bool isShow;
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged; // callback for search text
  final VoidCallback? onFilterTap; // callback for filter icon tap

  const SearchBarWidget({
    super.key,
    this.isShow = false,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Row(
      children: [
        Expanded(
          child: TextFormFieldWidget(
            fillColor: c.blue10,
            controller: _controller,
            hintText: widget.hintText ?? "Search matches, sports or locations...",
            onChanged: widget.onChanged,
            textInputAction: TextInputAction.search,
            preffixIcon: Icons.search_rounded,
            controlHeight: context.h(48),
          ),
        ),   if (widget.isShow)
        SizedBox(width: context.w(12)),
        if (widget.isShow)
          GestureDetector(
            onTap: widget.onFilterTap,
            child: SvgPicture.asset(AppAssets.filterIcon),
          ),
      ],
    );
  }
}
