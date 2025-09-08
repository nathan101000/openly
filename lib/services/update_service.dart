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
      final currentVersionName = packageInfo.version;
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

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
      final latestVersionName = data['tag_name']?.replaceFirst('v', '') ?? '';
      final assets = data['assets'] as List<dynamic>;

      final apkAsset = assets.firstWhere(
        (asset) =>
            asset['name'] != null &&
            asset['name'].toString().toLowerCase().endsWith('.apk') &&
            asset['name']
                .toString()
                .contains('+'), // Ensures build number is likely in name
        orElse: () => null,
      );

      if (apkAsset == null) {
        debugPrint(
            'APK asset not found in release (or name does not contain \'+\').');
        return;
      }

      final apkUrl = apkAsset['browser_download_url'];
      final apkName = apkAsset['name'] as String;

      int latestBuildNumber = 0;
      // Expected format: prefix-vX.Y.Z+BUILD.apk or vX.Y.Z+BUILD.apk
      final apkNamePattern =
          RegExp(r'v?\d+\.\d+\.\d+\+(\d+)\.apk$', caseSensitive: false);
      final match = apkNamePattern.firstMatch(apkName);
      if (match != null && match.groupCount >= 1) {
        latestBuildNumber = int.tryParse(match.group(1)!) ?? 0;
      } else {
        debugPrint(
            'Could not parse build number from APK name: $apkName. Update check may rely on version name only.');
      }

      if (_isNewer(latestVersionName, currentVersionName, latestBuildNumber,
          currentBuildNumber)) {
        _showUpdateSheet(context, apkUrl, latestVersionName, apkName);
      } else {
        debugPrint(
            'App is up to date. Current: v$currentVersionName ($currentBuildNumber), Latest: v$latestVersionName ($latestBuildNumber)');
        if (showNoUpdateDialog) {
          _showNoUpdateDialog(context, currentVersionName);
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static bool _isNewer(
    String latestVersionName,
    String currentVersionName,
    int latestBuildNum,
    int currentBuildNum,
  ) {
    // If we have a valid build number from the release, use it for comparison
    if (latestBuildNum > 0) {
      if (latestBuildNum > currentBuildNum) return true;
      if (latestBuildNum < currentBuildNum) return false;
      // If build numbers are the same, proceed to version name comparison (e.g. for different release channels with same build number but different patch)
    }

    // Fallback to version name semantic compare if latestBuildNum is not usable or build numbers are identical
    final latestParts = latestVersionName
        .split('.')
        .map(int.tryParse)
        .whereType<int>()
        .toList();
    final currentParts = currentVersionName
        .split('.')
        .map(int.tryParse)
        .whereType<int>()
        .toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
        return true;
      }
      if (latestParts[i] < currentParts[i]) {
        return false;
      }
    }
    return false; // Version names are also identical or current is newer/same
  }

  static void _showUpdateSheet(
    BuildContext context,
    String apkUrl,
    String version, // This is latestVersionName
    String filename, {
    String? changelog,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.dialogBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 20),
                Icon(
                  Icons.system_update_alt_rounded,
                  size: 56,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'New Update Available',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version $version is ready to install.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (changelog != null && changelog.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'What’s new:',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    changelog,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ensure a stable internet connection and sufficient storage before updating.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
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
                          Navigator.pop(ctx); // Close bottom sheet
                          await _requestPermissions();

                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            OtaUpdate()
                                .execute(apkUrl, destinationFilename: filename)
                                .listen((event) {
                              debugPrint(
                                  'OTA status: ${event.status} => ${event.value}');
                              if (event.status == OtaStatus.INSTALLING) {
                                if (Navigator.of(context, rootNavigator: true)
                                    .canPop()) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                }
                              }
                            });
                          } catch (e) {
                            if (Navigator.of(context, rootNavigator: true)
                                .canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Update Failed'),
                                content: Text(e.toString()),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
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
          ),
        );
      },
    );
  }

  static Future<void> _requestPermissions() async {
    final status = await Permission.requestInstallPackages.status;
    if (!status.isGranted) {
      await Permission.requestInstallPackages.request();
    }
  }

  static Future<void> _showNoUpdateDialog(
      BuildContext context, String currentVersion) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = packageInfo.buildNumber;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('App is Up to Date'),
        content: Text(
            'You are running the latest version ($currentVersion+$buildNumber).'),
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
