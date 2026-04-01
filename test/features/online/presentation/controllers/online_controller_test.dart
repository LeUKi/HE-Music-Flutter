import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:he_music_flutter/app/config/app_config_controller.dart';
import 'package:he_music_flutter/app/config/app_config_state.dart';
import 'package:he_music_flutter/features/my/domain/entities/my_favorite_type.dart';
import 'package:he_music_flutter/features/my/presentation/providers/favorite_collection_status_providers.dart';
import 'package:he_music_flutter/features/online/data/online_api_client.dart';
import 'package:he_music_flutter/features/online/presentation/providers/online_providers.dart';
import 'package:he_music_flutter/shared/utils/id_platform_key.dart';

void main() {
  test(
    'togglePlaylistFavorite adds playlist key and success message',
    () async {
      final client = _FakeOnlineApiClient();
      final container = ProviderContainer(
        overrides: <Override>[
          appConfigProvider.overrideWith(_TestAppConfigController.new),
          onlineApiClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(onlineControllerProvider.notifier)
          .togglePlaylistFavorite(
            playlistId: 'playlist-1',
            platform: 'kuwo',
            like: true,
          );

      final onlineState = container.read(onlineControllerProvider);
      final favoriteState = container.read(favoriteCollectionStatusProvider);

      expect(client.favoritePlaylistCalls, 1);
      expect(onlineState.message, 'Playlist favorited.');
      expect(
        favoriteState.playlistKeys,
        contains(buildIdPlatformKey(id: 'playlist-1', platform: 'kuwo')),
      );
    },
  );

  test(
    'togglePlaylistFavorite removes playlist key when unfavoriting',
    () async {
      final client = _FakeOnlineApiClient();
      final container = ProviderContainer(
        overrides: <Override>[
          appConfigProvider.overrideWith(_TestAppConfigController.new),
          onlineApiClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(container.dispose);

      final statusController = container.read(
        favoriteCollectionStatusProvider.notifier,
      );
      statusController.add(
        type: MyFavoriteType.playlists,
        id: 'playlist-1',
        platform: 'kuwo',
      );

      await container
          .read(onlineControllerProvider.notifier)
          .togglePlaylistFavorite(
            playlistId: 'playlist-1',
            platform: 'kuwo',
            like: false,
          );

      final onlineState = container.read(onlineControllerProvider);
      final favoriteState = container.read(favoriteCollectionStatusProvider);

      expect(client.unfavoritePlaylistCalls, 1);
      expect(onlineState.message, 'Playlist unfavorited.');
      expect(
        favoriteState.playlistKeys,
        isNot(contains(buildIdPlatformKey(id: 'playlist-1', platform: 'kuwo'))),
      );
    },
  );
}

class _TestAppConfigController extends AppConfigController {
  @override
  AppConfigState build() {
    return AppConfigState.initial.copyWith(authToken: 'token');
  }
}

class _FakeOnlineApiClient extends OnlineApiClient {
  _FakeOnlineApiClient() : super(Dio());

  int favoritePlaylistCalls = 0;
  int unfavoritePlaylistCalls = 0;

  @override
  Future<Map<String, dynamic>> togglePlaylistFavorite({
    required String playlistId,
    required String platform,
    required bool like,
    String? name,
    String? cover,
    String? creator,
  }) async {
    if (like) {
      favoritePlaylistCalls += 1;
      return <String, dynamic>{'status': 'ok'};
    }
    unfavoritePlaylistCalls += 1;
    return <String, dynamic>{'status': 'ok'};
  }
}
