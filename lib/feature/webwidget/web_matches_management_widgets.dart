import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/app_theme.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';
import 'package:sport_finding/feature/widget/normal_text.dart';
import 'package:sport_finding/feature/widget/search_bar_widget.dart';

class WebMatchesToolbar extends StatelessWidget {
  const WebMatchesToolbar({
    super.key,
    required this.onSearchChanged,
    this.onFilterTap,
    this.onSportsTap,
    this.onDateTap,
    this.onLocationTap,
    this.searchHint = 'Search matches by name or address...',
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSportsTap;
  final VoidCallback? onDateTap;
  final VoidCallback? onLocationTap;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBarWidget(
            hintText: searchHint,
            onChanged: onSearchChanged,
            isShow: onFilterTap != null,
            onFilterTap: onFilterTap,
          ),
        ),
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
    this.editEnabled = true,
    this.deleteEnabled = true,
  });

  final String title;
  final String sport;
  final String players;
  final String location;
  final String status;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  /// When false, "Edit match" appears in the actions menu but is non-interactive (e.g. completed match).
  final bool editEnabled;
  /// When false, "Delete match" appears but is non-interactive.
  final bool deleteEnabled;
}

class WebMatchesManagementSection extends StatelessWidget {
  const WebMatchesManagementSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSearchChanged,
    required this.rows,
    this.onFilterTap,
    this.onSportsTap,
    this.onDateTap,
    this.onLocationTap,
    this.headerTrailing,
    this.emptyLabel = 'No matches found',
    this.emptyDescription = 'Try changing your search or filters.',
    this.emptyIcon = Icons.search_off_rounded,
  });

  final String title;
  final String subtitle;
  final ValueChanged<String> onSearchChanged;
  final List<WebMatchTableRowData> rows;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSportsTap;
  final VoidCallback? onDateTap;
  final VoidCallback? onLocationTap;
  final Widget? headerTrailing;
  final String emptyLabel;
  final String emptyDescription;
  final IconData emptyIcon;

  Widget _emptyState(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.w(420)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.w(64),
              height: context.w(64),
              decoration: BoxDecoration(
                color: context.appColors.blue20.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(context.radius(18)),
                border: Border.all(
                  color: context.appColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                emptyIcon,
                color: context.appColors.primary,
                size: 30,
              ),
            ),
            SizedBox(height: context.h(14)),
            Text(
              emptyLabel,
              textAlign: TextAlign.center,
              style: context.appText.text16W600.copyWith(
                color: context.appColors.onSurface,
              ),
            ),
            if (emptyDescription.trim().isNotEmpty) ...[
              SizedBox(height: context.h(6)),
              Text(
                emptyDescription,
                textAlign: TextAlign.center,
                style: context.appText.text14W400.copyWith(
                  color: context.appColors.greyDark,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep filter access even when the current list is empty after filtering.
    // Parent screens can still disable by passing null callbacks.
    final effectiveOnFilterTap = onFilterTap;
    final effectiveOnSportsTap = onSportsTap;
    final effectiveOnDateTap = onDateTap;
    final effectiveOnLocationTap = onLocationTap;

    return MainFrame(
      showDecorationLayer: false,
      child: Padding(
        padding: context.padSym(h: 20, v: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WebDashboardTitle(
              title: title,
              subtitle: subtitle,
              trailing: headerTrailing,
            ),
            SizedBox(height: context.h(16)),
            WebMatchesToolbar(
              onSearchChanged: onSearchChanged,
              onFilterTap: effectiveOnFilterTap,
              onSportsTap: effectiveOnSportsTap,
              onDateTap: effectiveOnDateTap,
              onLocationTap: effectiveOnLocationTap,
            ),
            SizedBox(height: context.h(16)),
            Expanded(
              child: Card(
                  child: Container(
                  decoration: BoxDecoration(
                    color: context.appColors.blue10,
                    borderRadius: BorderRadius.circular(context.radius(14)),
                  
                  ),
                  padding: context.padSym(h: 22, v: 20),
                  child: rows.isEmpty
                      ? _emptyState(context)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor:
                                        context.appColors.greylight.withValues(
                                      alpha: 0.16,
                                    ),
                                  ),
                                  child: DataTable(
                                    headingRowHeight: context.h(44),
                                    dataRowMinHeight: context.h(64),
                                    dataRowMaxHeight: context.h(74),
                                    dividerThickness: 0.6,
                                    columnSpacing: context.w(34),
                                    horizontalMargin: 0,
                                    headingTextStyle:
                                        context.appText.text12W500.copyWith(
                                      color: context.appColors.greyDark,
                                    ),
                                    dataTextStyle:
                                        context.appText.text12W400.copyWith(
                                      color: context.appColors.onSurface,
                                    ),
                                    columns:   [
                                      DataColumn(label: NormalText(titleText: 'Matches',
                                      titleStyle: context.appText.text14Bold.copyWith(
                                      color: context.appColors.onSurface,
                                    ),
                                      )),
                                      DataColumn(label: NormalText(titleText: 'Sports Type',
                                      titleStyle: context.appText.text14Bold.copyWith(
                                      color: context.appColors.onSurface,
                                    ),
                                        )),
                                      DataColumn(label: NormalText(titleText: 'Players',
                                      titleStyle: context.appText.text14Bold.copyWith(
                                      color: context.appColors.onSurface,
                                    ),
                                      )),
                                      DataColumn(label: NormalText(titleText: 'Location')),
                                      DataColumn(label: NormalText(titleText: "Match's Status",
                                      titleStyle: context.appText.text14Bold.copyWith(
                                      color: context.appColors.onSurface,
                                    ),
                                      )),
                                      DataColumn(label: NormalText(titleText: 'Actions',
                                      titleStyle: context.appText.text14Bold.copyWith(
                                      color: context.appColors.onSurface,
                                    ),
                                      )),
                                    ],
                                    rows: rows.map((row) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            SizedBox(
                                              width: context.w(130),
                                              child: Text(
                                                row.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            SizedBox(
                                              width: context.w(110),
                                              child: Text(
                                                row.sport,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(row.players)),
                                          DataCell(
                                            SizedBox(
                                            width: context.w(220),
                                              child: Text(
                                                row.location,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding: context.padSym(h: 8, v: 4),
                                              decoration: BoxDecoration(
                                                color: context.appColors.primary.withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  context.radius(24),
                                                ),
                                              ),
                                              child: Text(
                                                row.status,
                                                style: context.appText.text12W600
                                                    .copyWith(
                                                  color: context.appColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: _ActionsMenuButton(row: row),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            );
                          },
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

class _ActionsMenuButton extends StatelessWidget {
  const _ActionsMenuButton({required this.row});

  final WebMatchTableRowData row;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    PopupMenuItem<String> item({
      required String value,
      required IconData icon,
      required String label,
      Color? color,
      bool enabled = true,
    }) {
      final base = color ?? c.onSurface;
      // Explicit muted fg: PopupMenuItem does not dim [child] icon/text when enabled is false.
      final fg = enabled ? base : c.greylight;
      return PopupMenuItem<String>(
        value: value,
        enabled: enabled,
        height: 40,
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 10),
            Text(
              label,
              style: context.appText.text12W500.copyWith(color: fg),
            ),
          ],
        ),
      );
    }

    final hasItems =
        row.onView != null || row.onEdit != null || row.onDelete != null;
    if (!hasItems) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'Actions',
      elevation: 14,
      color: c.onPrimary,
      shadowColor: c.blue20.withValues(alpha: 0.35),
      surfaceTintColor: Colors.transparent,
      offset: const Offset(0, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.greylight.withValues(alpha: 0.18)),
      ),
      itemBuilder: (_) => [
        if (row.onView != null)
          item(
            value: 'view',
            icon: Icons.visibility_outlined,
            label: 'View match',
          ),
        if (row.onEdit != null)
          item(
            value: 'edit',
            icon: Icons.edit_outlined,
            label: 'Edit match',
            enabled: row.editEnabled,
          ),
        if (row.onDelete != null)
          item(
            value: 'delete',
            icon: Icons.delete_outline_rounded,
            label: 'Delete match',
            color: c.error,
            enabled: row.deleteEnabled,
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: c.primary.withValues(alpha: 0.06),
          splashColor: c.primary.withValues(alpha: 0.10),
          highlightColor: c.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.more_horiz_rounded,
              color: c.greyDark,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
