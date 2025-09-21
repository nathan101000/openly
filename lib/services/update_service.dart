import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateService {
  static const String githubRepo = 'nathan101000/openly';

  static Future<void> checkForUpdates(BuildContext context,
      {bool showNoUpdateDialog = false,}) async {
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
      final changelog = (data['body'] as String?)?.trim();

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
            'APK asset not found in release (or name does not contain \'+\').',);
        return;
      }

      final apkUrl = apkAsset['browser_download_url'];
      final apkName = apkAsset['name'] as String;
      final int? apkSizeBytes = (apkAsset['size'] is int)
          ? (apkAsset['size'] as int)
          : int.tryParse('${apkAsset['size']}');

      int latestBuildNumber = 0;
      // Expected format: prefix-vX.Y.Z+BUILD.apk or vX.Y.Z+BUILD.apk
      final apkNamePattern =
          RegExp(r'v?\d+\.\d+\.\d+\+(\d+)\.apk$', caseSensitive: false);
      final match = apkNamePattern.firstMatch(apkName);
      if (match != null && match.groupCount >= 1) {
        latestBuildNumber = int.tryParse(match.group(1)!) ?? 0;
      } else {
        debugPrint(
            'Could not parse build number from APK name: $apkName. Update check may rely on version name only.',);
      }

      if (_isNewer(latestVersionName, currentVersionName, latestBuildNumber,
          currentBuildNumber,)) {
        _showUpdateSheet(context, apkUrl, latestVersionName, apkName,
            changelog: changelog, totalBytes: apkSizeBytes,);
      } else {
        debugPrint(
            'App is up to date. Current: v$currentVersionName ($currentBuildNumber), Latest: v$latestVersionName ($latestBuildNumber)',);
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
    int? totalBytes,
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
                      'What’s new',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        data: changelog,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(theme).copyWith(
                          p: theme.textTheme.bodyMedium,
                          h1: theme.textTheme.titleLarge,
                          h2: theme.textTheme.titleMedium,
                          h3: theme.textTheme.titleSmall,
                          code: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
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
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        child: const Text('Later'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx); // Close bottom sheet
                          final proceed =
                              await _ensureInstallPermission(context);
                          if (!proceed) return;

                          await _showUpdateProgressDialog(
                            context: context,
                            apkUrl: apkUrl,
                            filename: filename,
                            totalBytes: totalBytes,
                          );
                        },
                        icon:
                            Icon(Icons.download, color: colorScheme.onPrimary),
                        label: Text('Update Now',
                            style: TextStyle(color: colorScheme.onPrimary),),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
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

  static Future<bool> _ensureInstallPermission(BuildContext context) async {
    final status = await Permission.requestInstallPackages.status;
    if (status.isGranted) return true;

    final theme = Theme.of(context);
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Install Permission Needed'),
        content: Text(
          'We need install permission so the app can update itself without the Play Store. This lets us safely download and install the latest version.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );

    if (proceed != true) return false;

    final req = await Permission.requestInstallPackages.request();
    if (req.isGranted) return true;

    // If permanently denied, guide to settings
    if (req.isPermanentlyDenied) {
      final goSettings = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Please enable install permissions in Settings to proceed with the update.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      if (goSettings == true) {
        await openAppSettings();
      }
    }
    return false;
  }

  static Future<void> _showUpdateProgressDialog({
    required BuildContext context,
    required String apkUrl,
    required String filename,
    int? totalBytes,
  }) async {
    double progress = 0.0; // 0..1
    String statusText = 'Preparing download…';
    bool installing = false;
    StreamSubscription<OtaEvent>? sub;
    bool dismissedToBackground = false;

    String _formatBytes(int bytes) {
      const units = ['B', 'KB', 'MB', 'GB'];
      double size = bytes.toDouble();
      int unit = 0;
      while (size >= 1024 && unit < units.length - 1) {
        size /= 1024;
        unit++;
      }
      return '${size.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
    }

    Future<void> startDownload(void Function(void Function()) setState) async {
      try {
        sub = OtaUpdate()
            .execute(apkUrl, destinationFilename: filename)
            .listen((event) async {
          debugPrint('OTA status: ${event.status} => ${event.value}');
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              final pct = double.tryParse('${event.value}') ?? 0.0;
              setState(() {
                progress = (pct.clamp(0, 100)) / 100.0;
                final percentStr = (progress * 100).toStringAsFixed(0);
                statusText = 'Downloading update ($percentStr%)';
              });
              break;
            case OtaStatus.INSTALLING:
              setState(() {
                installing = true;
                statusText = 'Installing update…';
              });
              if (!dismissedToBackground) {
                // Let the installer take over; close dialog if still open
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              }
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              if (!dismissedToBackground) {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              }
              _showFriendlyError(context,
                  message:
                      'Install permission is required to complete the update.',
                  offerRetry: false,);
              break;
            case OtaStatus.ALREADY_RUNNING_ERROR:
            case OtaStatus.DOWNLOAD_ERROR:
            case OtaStatus.INTERNAL_ERROR:
            case OtaStatus.CHECKSUM_ERROR:
              if (!dismissedToBackground) {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              }
              _showFriendlyError(context);
              break;
            default:
              break;
          }
        });
      } catch (e) {
        _showFriendlyError(context, message: e.toString());
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (ctx, setState) {
          // Start the download once when dialog builds
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (sub == null) {
              await startDownload(setState);
            }
          });

          final theme = Theme.of(ctx);
          final totalStr = totalBytes != null ? _formatBytes(totalBytes) : null;
          final downloadedBytes =
              totalBytes != null ? (totalBytes * progress).toInt() : null;
          final downloadedStr =
              downloadedBytes != null ? _formatBytes(downloadedBytes) : null;

          return AlertDialog(
            title: const Text('Updating App'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusText, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                if (!installing) ...[
                  LinearProgressIndicator(
                      value: progress == 0 ? null : progress,),
                  const SizedBox(height: 8),
                  if (totalStr != null && downloadedStr != null)
                    Text('$downloadedStr of $totalStr downloaded',
                        style: theme.textTheme.bodySmall,),
                ] else ...[
                  const SizedBox(height: 8),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: installing
                    ? null
                    : () {
                        dismissedToBackground = true;
                        Navigator.of(dialogContext).pop();
                      },
                child: const Text('Background'),
              ),
              TextButton(
                onPressed: installing
                    ? null
                    : () async {
                        try {
                          await OtaUpdate().cancel();
                          await sub?.cancel();
                        } catch (_) {}
                        if (Navigator.of(dialogContext).canPop()) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                child: const Text('Cancel'),
              ),
            ],
          );
        },);
      },
    );

    try {
      if (!dismissedToBackground) {
        await sub?.cancel();
      }
    } catch (_) {}
  }

  static void _showFriendlyError(BuildContext context,
      {String? message, bool offerRetry = true,}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Problem'),
        content: Text(
          message ??
              'Oops! Something went wrong while updating. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          if (offerRetry)
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx), // Let caller reopen
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  static Future<void> _showNoUpdateDialog(
      BuildContext context, String currentVersion,) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = packageInfo.buildNumber;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('App is Up to Date'),
        content: Text(
            'You are running the latest version ($currentVersion+$buildNumber).',),
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
