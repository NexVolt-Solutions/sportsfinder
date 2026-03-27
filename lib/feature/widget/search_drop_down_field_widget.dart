import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';

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
  List<String> filteredItems = [];
  bool showList = false;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void filter(String value) {
    setState(() {
      showList = true;
      filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.radius(12)),
        border: Border.all(color: c.greylight),
      ),
      child: Column(
        children: [
          /// 🔤 TextField with Floating Label
          TextFormField(
            controller: widget.controller,
            onTap: () {
              setState(() => showList = true);
            },
            onChanged: filter,
            decoration: InputDecoration(
              labelText: widget.label, // ✅ inside label
              hintText: widget.hintText,

              floatingLabelBehavior: FloatingLabelBehavior.auto, // 👈 moves up

              border: InputBorder.none,

              contentPadding: EdgeInsets.symmetric(
                horizontal: context.w(12),
                vertical: context.h(14),
              ),
            ),
          ),

          /// Divider
          if (showList) Divider(height: 1, color: c.greylight),

          /// 📍 Dropdown List
          if (showList)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];

                return ListTile(
                  title: Text(item),
                  onTap: () {
                    widget.controller.text = item;
                    setState(() => showList = false);
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
