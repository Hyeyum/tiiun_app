// lib/services/remote_config_service.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.setDefaults({
        'openai_api_key': '', // Set a default empty string
      });
      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config initialized and fetched.');
    } catch (e) {
      debugPrint('Error initializing or fetching Remote Config: $e');
    }
  }

  String getOpenAIApiKey() {
    return _remoteConfig.getString('openai_api_key');
  }

  // Add more methods for other remote config parameters if needed
}