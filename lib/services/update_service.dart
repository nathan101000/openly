import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static const String releasesUrl =
      'https://raw.githubusercontent.com/nathan101000/openly/main/releases.json';

  static final ReceivePort _port = ReceivePort();

  static void initialize() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      // Handle download progress and status updates
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(releasesUrl));
      if (response.statusCode != 200) {
        // Handle error
        return;
      }

      final releases = json.decode(response.body) as List<dynamic>;
      if (releases.isEmpty) {
        return;
      }

      final latestRelease = releases.first;
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.parse(packageInfo.buildNumber);

      debugPrint('TELEMETRY: update_check_success');
      if (latestRelease['buildNumber'] > currentBuildNumber) {
        final prefs = await SharedPreferences.getInstance();
        int userId = prefs.getInt('userId') ?? DateTime.now().millisecondsSinceEpoch;
        prefs.setInt('userId', userId);

        if (userId % 100 < latestRelease['rolloutPercentage']) {
          _showUpdateSheet(context, latestRelease);
        }
      }
    } catch (e) {
      debugPrint('TELEMETRY: update_failed - $e');
    }
  }

  static void _showUpdateSheet(
      BuildContext context, Map<String, dynamic> release) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return UpdateDialog(release: release);
          },
        );
      },
    );
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }
}

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> release;

  const UpdateDialog({Key? key, required this.release}) : super(key: key);

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  double _progress = 0.0;
  bool _isDownloading = false;
  String? _taskId;

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
  }

  void _bindBackgroundIsolate() {
    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.listen((dynamic data) {
      final String id = data[0];
      final int status = data[1];
      final int progress = data[2];

      if (_taskId == id) {
        setState(() {
          if (status == DownloadTaskStatus.running.value) {
            _progress = progress / 100.0;
          } else if (status == DownloadTaskStatus.complete.value) {
            _isDownloading = false;
            _verifyAndInstall();
          } else if (status == DownloadTaskStatus.failed.value) {
            _isDownloading = false;
            // Handle download failure
          }
        });
      }
    });
  }

  Future<void> _downloadUpdate() async {
    final localPath =
        (await getExternalStorageDirectory())!.path + '/Download';
    final savedDir = Directory(localPath);
    if (!savedDir.existsSync()) {
      savedDir.createSync(recursive: true);
    }

    debugPrint('TELEMETRY: update_download_start');
    _taskId = await FlutterDownloader.enqueue(
      url: widget.release['url'],
      savedDir: localPath,
      showNotification: true,
      openFileFromNotification: false, // We will open it manually after verification
    );
    setState(() {
      _isDownloading = true;
    });
  }

  Future<void> _verifyAndInstall() async {
    final localPath =
        (await getExternalStorageDirectory())!.path + '/Download';
    final downloadedFilePath = '$localPath/${widget.release['url'].split('/').last}';
    final file = File(downloadedFilePath);

    if (await file.exists()) {
      final fileBytes = await file.readAsBytes();
      final digest = sha256.convert(fileBytes);

      if (digest.toString() == widget.release['signature']) {
        debugPrint('TELEMETRY: update_download_complete');
        debugPrint('TELEMETRY: update_install_success');
        FlutterDownloader.open(taskId: _taskId!);
      } else {
        debugPrint('TELEMETRY: update_failed - Signature mismatch');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update verification failed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Update Available',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 20),
          Text('Version ${widget.release['versionName']} is available.'),
          SizedBox(height: 10),
          Text('Changelog:\n${widget.release['changelog']}'),
          SizedBox(height: 20),
          if (_isDownloading)
            LinearProgressIndicator(value: _progress > 0 ? _progress : null)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!widget.release['isForced'])
                  TextButton(
                    child: Text('Later'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ElevatedButton(
                  child: Text('Download & Install'),
                  onPressed: _downloadUpdate,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
