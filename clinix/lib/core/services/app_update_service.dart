import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final bool isForced;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    required this.isForced,
  });
}

class AppUpdateService {
  static const String _latestReleaseUrl =
      'https://api.github.com/repos/sajalchaulagain/clinix/releases/latest';
  static const String _apkDownloadUrl =
      'https://github.com/sajalchaulagain/clinix/releases/latest/download/CliniX.apk';
  static const String _lastCheckKey = 'last_update_check_ms';
  static const int _checkIntervalMs = 6 * 60 * 60 * 1000; // 6 hours

  final Dio _dio;

  AppUpdateService({Dio? dio}) : _dio = dio ?? Dio();

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (now - lastCheck < _checkIntervalMs) {
        return null;
      }

      final response = await _dio.get<Map<String, dynamic>>(
        _latestReleaseUrl,
        options: Options(
          headers: {'Accept': 'application/vnd.github+json'},
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      await prefs.setInt(_lastCheckKey, now);

      final data = response.data!;
      final tagName = (data['tag_name'] as String? ?? '').replaceAll(RegExp(r'^v'), '');
      final body = data['body'] as String? ?? '';

      if (tagName.isEmpty) {
        return null;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version.split('+').first;

      if (!_isVersionGreater(tagName, currentVersion)) {
        return null;
      }

      String? minVersion;
      final lines = body.split('\n');
      final cleanLines = <String>[];

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('MIN_APP_VERSION:')) {
          minVersion = trimmed.substring('MIN_APP_VERSION:'.length).trim();
        } else {
          cleanLines.add(line);
        }
      }

      final isForced = minVersion != null && _isVersionGreater(minVersion, currentVersion);
      var releaseNotes = cleanLines.join('\n').trim();
      if (releaseNotes.length > 300) {
        releaseNotes = '${releaseNotes.substring(0, 300)}...';
      }

      return AppUpdateInfo(
        currentVersion: currentVersion,
        latestVersion: tagName,
        releaseNotes: releaseNotes,
        isForced: isForced,
      );
    } catch (_) {
      // Any failure must be a silent no-op
      return null;
    }
  }

  Future<void> launchDownloadUrl() async {
    try {
      final uri = Uri.parse(_apkDownloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  static bool _isVersionGreater(String v1, String v2) {
    try {
      final p1 = v1.split('.').map((e) => int.parse(RegExp(r'\d+').stringMatch(e) ?? '0')).toList();
      final p2 = v2.split('.').map((e) => int.parse(RegExp(r'\d+').stringMatch(e) ?? '0')).toList();

      while (p1.length < 3) {
        p1.add(0);
      }
      while (p2.length < 3) {
        p2.add(0);
      }

      for (var i = 0; i < 3; i++) {
        if (p1[i] > p2[i]) return true;
        if (p1[i] < p2[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});

Future<void> checkAndShowUpdateDialog(BuildContext context, WidgetRef ref) async {
  final service = ref.read(appUpdateServiceProvider);
  final updateInfo = await service.checkForUpdate();

  if (updateInfo == null || !context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: !updateInfo.isForced,
    builder: (context) {
      return PopScope(
        canPop: !updateInfo.isForced,
        child: AlertDialog(
          title: const Text('Update available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'current v${updateInfo.currentVersion} → new v${updateInfo.latestVersion}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (updateInfo.releaseNotes.isNotEmpty)
                Text(updateInfo.releaseNotes),
            ],
          ),
          actions: [
            if (!updateInfo.isForced)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later'),
              ),
            FilledButton(
              onPressed: () {
                service.launchDownloadUrl();
                if (!updateInfo.isForced) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Download update'),
            ),
          ],
        ),
      );
    },
  );
}
