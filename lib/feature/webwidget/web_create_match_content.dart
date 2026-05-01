import 'package:flutter/material.dart';
import 'package:sport_finding/core/Constants/size_extension.dart';
import 'package:sport_finding/feature/widget/mainframe.dart';
import 'package:sport_finding/feature/webwidget/web_dashboard_widgets.dart';

class WebCreateMatchContent extends StatelessWidget {
  const WebCreateMatchContent({
    super.key,
    required this.header,
    required this.formBody,
    required this.submitButton,
  });

  final Widget header;
  final Widget formBody;
  final Widget submitButton;

  @override
  Widget build(BuildContext context) {
    return MainFrame(
      child: SingleChildScrollView(
        padding: context.padSym(h: 20, v: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            SizedBox(height: context.h(16)),
            WebDashboardPanel(
              padding: context.padSym(h: 18, v: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  formBody,
                  SizedBox(height: context.h(20)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(width: context.w(180), child: submitButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
