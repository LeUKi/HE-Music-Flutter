import 'package:flutter_test/flutter_test.dart';
import 'package:he_music_flutter/app/config/app_config_data_source.dart';
import 'package:he_music_flutter/app/config/app_environment.dart';
import 'package:he_music_flutter/app/config/app_online_audio_quality.dart';
import 'package:he_music_flutter/core/audio/audio_track.dart';
import 'package:he_music_flutter/core/audio/he_audio_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'loadHeAudioHandlerRuntimeConfig should restore persisted playback config',
    () async {
      const dataSource = AppConfigDataSource();
      await dataSource.save(
        (await dataSource.load()).copyWith(
          apiBaseUrl: 'https://example.com/',
          authToken: 'token-123',
          onlineAudioQualityPreference: AppOnlineAudioQuality.flac,
          lastSelectedOnlineAudioQualityName: 'FLAC',
        ),
      );

      final config = await loadHeAudioHandlerRuntimeConfig(
        dataSource: dataSource,
      );

      expect(config.apiBaseUrl, AppEnvironment.apiBaseUrl);
      expect(config.authToken, 'token-123');
      expect(config.qualityPreference, AppOnlineAudioQuality.flac);
      expect(config.lastSelectedQualityName, 'FLAC');
    },
  );

  test('shouldRefreshRemotePlaybackUrl returns true for remote tracks', () {
    const track = AudioTrack(
      id: '1',
      title: 'Remote',
      url: 'https://cdn.example.com/audio.mp3',
      platform: 'netease',
    );

    expect(shouldRefreshRemotePlaybackUrl(track), isTrue);
  });

  test('shouldRefreshRemotePlaybackUrl returns false for local file path', () {
    const track = AudioTrack(
      id: '2',
      title: 'Local',
      url: '',
      path: '/tmp/demo.mp3',
      platform: 'local',
    );

    expect(shouldRefreshRemotePlaybackUrl(track), isFalse);
  });

  test('shouldRefreshRemotePlaybackUrl returns false for file scheme url', () {
    const track = AudioTrack(
      id: '3',
      title: 'LocalUrl',
      url: 'file:///tmp/demo.mp3',
    );

    expect(shouldRefreshRemotePlaybackUrl(track), isFalse);
  });
}
