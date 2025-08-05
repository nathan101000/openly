import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateService {
  static const String githubRepo = 'nathan101000/openly';

  static Future<void> checkForUpdates(BuildContext context,
      {bool showNoUpdateDialog = false}) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest'),
        headers: {
          'Accept': 'application/vnd.github+json',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('GitHub API failed: ${response.statusCode}');
        return;
      }

      final data = json.decode(response.body);
      final latestVersion = data['tag_name']?.replaceFirst('v', '') ?? '';
      final assets = data['assets'] as List<dynamic>;

      final apkAsset = assets.firstWhere(
        (asset) =>
            asset['name'] != null &&
            asset['name'].toString().toLowerCase().endsWith('.apk'),
        orElse: () => null,
      );

      if (apkAsset == null) {
        debugPrint('APK asset not found in release.');
        return;
      }

      final apkUrl = apkAsset['browser_download_url'];
      final apkName = apkAsset['name'];

      if (_isNewer(latestVersion, currentVersion)) {
        _showUpdateSheet(context, apkUrl, latestVersion, apkName);
      } else {
        debugPrint('App is up to date.');
        if (showNoUpdateDialog) {
          _showNoUpdateDialog(context, currentVersion);
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static bool _isNewer(String latest, String current) {
    final latestParts =
        latest.split('.').map(int.tryParse).whereType<int>().toList();
    final currentParts =
        current.split('.').map(int.tryParse).whereType<int>().toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      }
      if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false;
  }

  static void _showUpdateSheet(
    BuildContext context,
    String apkUrl,
    String version,
    String filename, {
    String? changelog,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
            top:
                false, // keep top spacing off since we want the modal to be flush at the top
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  24, 24, 24, 32), // still keep internal padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.system_update_alt_rounded,
                      size: 56, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  Text(
                    'New Update Available',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version $version is ready to install.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  if (changelog != null && changelog.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'What’s new:',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      changelog,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black87),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ensure a stable internet connection and sufficient storage before updating.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.blue[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Later'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await _requestPermissions();

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            try {
                              OtaUpdate()
                                  .execute(apkUrl,
                                      destinationFilename: filename)
                                  .listen((event) {
                                debugPrint(
                                    'OTA status: ${event.status} => ${event.value}');
                                // You could also update a progress bar here
                              });
                            } catch (e) {
                              Navigator.pop(context); // Close progress
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Update Failed'),
                                  content: Text(e.toString()),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK')),
                                  ],
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Update Now'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }

  static Future<void> _requestPermissions() async {
    final status = await Permission.requestInstallPackages.status;
    if (!status.isGranted) {
      await Permission.requestInstallPackages.request();
    }
  }

  static void _showNoUpdateDialog(BuildContext context, String currentVersion) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('App is Up to Date'),
        content: Text('You are running the latest version ($currentVersion).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
