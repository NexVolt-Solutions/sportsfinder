// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:sport_finding/core/Constants/app_assets.dart';
// import 'package:sport_finding/core/Constants/app_theme.dart';
// import 'package:sport_finding/core/Constants/size_extension.dart';

// class SearchBarWidget extends StatelessWidget {
//   final bool isShow;

//   const SearchBarWidget({super.key, this.isShow = false});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.appColors;

//     return Row(
//       children: [
//         Expanded(
//           // optional but recommended
//           child: Container(
//             padding: context.padSym(h: 12),
//             decoration: BoxDecoration(
//               color: c.blue10,
//               borderRadius: BorderRadius.circular(context.radius(12)),
//               border: Border.all(color: c.primary, width: 1.2),
//             ),
//             child: TextField(
//               decoration: InputDecoration(
//                 icon: Icon(Icons.search, color: c.greyDark),
//                 hintText: "Search sports or locations...",
//                 hintStyle: context.appText.text14W400.copyWith(
//                   color: c.greyDark,
//                 ),
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: context.w(12)),

//         /// ✅ Show only when isShow = true
//         if (isShow) SvgPicture.asset(AppAssets.filterIcon),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sport_finding/core/Constants/app_assets.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

/// Search field with a tappable search icon.
/// Tapping the magnifier submits the search by calling [onChanged].
class SearchBarWidget extends StatefulWidget {
  final bool isShow;
  final ValueChanged<String>? onChanged; // callback for search text
  final VoidCallback? onFilterTap; // callback for filter icon tap

  const SearchBarWidget({
    super.key,
    this.isShow = false,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: context.padSym(h: 12),
            decoration: BoxDecoration(
              color: c.blue10,
              borderRadius: BorderRadius.circular(context.radius(12)),
              border: Border.all(color: c.primary, width: 1.2),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => widget.onChanged?.call(_controller.text),
              decoration: InputDecoration(
                // Use suffixIcon so tapping it can submit search.
                hintText: "Search sports or locations...",
                hintStyle: context.appText.text14W400.copyWith(
                  color: c.greyDark,
                ),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: c.greyDark),
                  onPressed: () {
                    _focusNode.requestFocus();
                    widget.onChanged?.call(_controller.text);
                  },
                ),
              ),
            ),
          ),
        ),
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
