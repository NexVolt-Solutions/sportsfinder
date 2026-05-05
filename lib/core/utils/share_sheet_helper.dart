import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_finding/core/utils/app_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareSheetHelper {
  ShareSheetHelper._();

  static Future<void> showShareSheet(
    BuildContext context, {
    required String title,
    required String text,
  }) async {
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(title),
                subtitle: const Text('Share using the apps on your phone'),
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('WhatsApp'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _launchUri(
                    Uri.parse(
                      'https://wa.me/?text=${Uri.encodeComponent(text)}',
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sms_outlined),
                title: const Text('SMS'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _launchUri(
                    Uri(
                      scheme: 'sms',
                      queryParameters: <String, String>{'body': text},
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _launchUri(
                    Uri(
                      scheme: 'mailto',
                      queryParameters: <String, String>{
                        'subject': title,
                        'body': text,
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy Text'),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                  AppSnackBar.show('Copied to clipboard');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _launchUri(Uri uri) async {
    final mode =
        kIsWeb || uri.scheme == 'mailto' || uri.scheme == 'sms'
        ? LaunchMode.platformDefault
        : LaunchMode.externalApplication;
    final launched = await launchUrl(uri, mode: mode);
    if (!launched) {
      AppSnackBar.show('No app found to share this');
    }
  }
}
