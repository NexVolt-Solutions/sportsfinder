import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_colors.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';

class WebMatchesToolbar extends StatelessWidget {
  const WebMatchesToolbar({
    super.key,
    required this.onSearchChanged,
    this.onSportsTap,
    this.onDateTap,
    this.onLocationTap,
    this.searchHint = 'Search matches by name or address...',
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onSportsTap;
  final VoidCallback? onDateTap;
  final VoidCallback? onLocationTap;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: context.h(44),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F8FF),
              borderRadius: BorderRadius.circular(context.radius(12)),
              border: Border.all(color: const Color(0xFF6BB5FF)),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: searchHint,
                hintStyle: context.appText.text12W400.copyWith(
                  color: context.appColors.greylight,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.appColors.greylight,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: context.padSym(h: 12, v: 10),
              ),
            ),
          ),
        ),
        SizedBox(width: context.w(12)),
        _ToolbarFilterChip(label: 'All', isSelected: true),
        SizedBox(width: context.w(8)),
        _ToolbarFilterChip(label: 'Sports', onTap: onSportsTap),
        SizedBox(width: context.w(8)),
        _ToolbarFilterChip(label: 'Date', onTap: onDateTap),
        SizedBox(width: context.w(8)),
        _ToolbarFilterChip(label: 'Location', onTap: onLocationTap),
      ],
    );
  }
}

class WebMatchTableRowData {
  const WebMatchTableRowData({
    required this.title,
    required this.sport,
    required this.players,
    required this.location,
    required this.status,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final String sport;
  final String players;
  final String location;
  final String status;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
}

class WebMatchesManagementSection extends StatelessWidget {
  const WebMatchesManagementSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSearchChanged,
    required this.rows,
    this.onSportsTap,
    this.onDateTap,
    this.onLocationTap,
    this.emptyLabel = 'No matches found',
  });

  final String title;
  final String subtitle;
  final ValueChanged<String> onSearchChanged;
  final List<WebMatchTableRowData> rows;
  final VoidCallback? onSportsTap;
  final VoidCallback? onDateTap;
  final VoidCallback? onLocationTap;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return MainFrame(
      showDecorationLayer: false,
      child: Padding(
        padding: context.padSym(h: 20, v: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WebDashboardTitle(title: title, subtitle: subtitle),
            SizedBox(height: context.h(16)),
            WebMatchesToolbar(
              onSearchChanged: onSearchChanged,
              onSportsTap: onSportsTap,
              onDateTap: onDateTap,
              onLocationTap: onLocationTap,
            ),
            SizedBox(height: context.h(18)),
            Expanded(
              child: WebDashboardPanel(
                backgroundColor: context.appColors.blue10,
                padding: context.padSym(h: 18, v: 18),
                child: rows.isEmpty
                    ? Center(
                        child: Text(
                          emptyLabel,
                          style: context.appText.text14W400.copyWith(
                            color: context.appColors.greyDark,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                // // headingRowHeight: context.h(44),
                                // dataRowMinHeight: context.h(64),
                                // dataRowMaxHeight: context.h(78),
                                dividerThickness: 1.0,
                                columnSpacing: context.w(24),
                                horizontalMargin: 0,
                                border: TableBorder(
                                  horizontalInside: BorderSide(
                                    color: AppColors.whitecolor,
                                  ),
                                  // top: BorderSide(
                                  //   color: tableDividerColor,
                                  //   width: 1,
                                  // ),
                                ),
                                headingTextStyle: context.appText.text12W500
                                    .copyWith(
                                      color: context.appColors.greyDark,
                                    ),
                                dataTextStyle: context.appText.text12W400
                                    .copyWith(
                                      color: context.appColors.onSurface,
                                    ),
                                columns: const [
                                  DataColumn(label: Text('Matches')),
                                  DataColumn(label: Text('Sports Type')),
                                  DataColumn(label: Text('Players')),
                                  DataColumn(label: Text('Location')),
                                  DataColumn(label: Text("Match's Status")),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: rows.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        SizedBox(child: Text(row.title)),
                                      ),
                                      DataCell(Text(row.sport)),
                                      DataCell(Text(row.players)),
                                      DataCell(
                                        SizedBox(
                                          width: context.w(90),
                                          child: Text(
                                            row.location,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: context.padSym(h: 12, v: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.bluecolor,
                                            borderRadius: BorderRadius.circular(
                                              context.radius(12),
                                            ),
                                          ),
                                          child: Text(
                                            row.status,
                                            style: context.appText.text12W500
                                                .copyWith(
                                                  color: AppColors.whitecolor,
                                                ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        PopupMenuButton<String>(
                                          tooltip: 'Actions',
                                          itemBuilder: (_) => [
                                            if (row.onView != null)
                                              const PopupMenuItem(
                                                value: 'view',
                                                child: Text('View Match'),
                                              ),
                                            if (row.onEdit != null)
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit Match'),
                                              ),
                                            if (row.onDelete != null)
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete Match'),
                                              ),
                                          ],
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'view':
                                                row.onView?.call();
                                                break;
                                              case 'edit':
                                                row.onEdit?.call();
                                                break;
                                              case 'delete':
                                                row.onDelete?.call();
                                                break;
                                            }
                                          },
                                          child: const Icon(
                                            Icons.more_horiz_rounded,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarFilterChip extends StatelessWidget {
  const _ToolbarFilterChip({
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? context.appColors.primary
        : const Color(0xFF6BB5FF);
    final textColor = isSelected ? Colors.white : color;
    return InkWell(
      borderRadius: BorderRadius.circular(context.radius(10)),
      onTap: onTap,
      child: Container(
        height: context.h(36),
        padding: context.padSym(h: 14, v: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(context.radius(10)),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.appText.text12W500.copyWith(color: textColor),
            ),
            if (!isSelected) ...[
              SizedBox(width: context.w(4)),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: textColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
