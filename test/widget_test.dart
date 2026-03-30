import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:he_music_flutter/app/config/app_config_controller.dart';
import 'package:he_music_flutter/app/config/app_config_state.dart';
import 'package:he_music_flutter/features/home/data/datasources/home_discover_api_client.dart';
import 'package:he_music_flutter/features/home/domain/entities/home_discover_section.dart';
import 'package:he_music_flutter/features/home/domain/entities/home_platform.dart';
import 'package:he_music_flutter/features/home/presentation/providers/home_discover_providers.dart';
import 'package:he_music_flutter/features/home/presentation/pages/home_page.dart';
import 'package:he_music_flutter/features/online/domain/entities/online_platform.dart';
import 'package:he_music_flutter/features/online/presentation/providers/online_providers.dart';
import 'package:he_music_flutter/features/player/domain/entities/player_playback_state.dart';
import 'package:he_music_flutter/features/player/domain/entities/player_track.dart';
import 'package:he_music_flutter/features/player/presentation/controllers/player_controller.dart';
import 'package:he_music_flutter/features/player/presentation/providers/player_providers.dart';

void main() {
  testWidgets('home shell renders with two tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildHomeTestApp(apiClient: _TestHomeDiscoverApiClient()),
    );
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsWidgets);
    expect(find.text('我的'), findsOneWidget);
    expect(find.text('排行榜'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets('home discover uses preloaded global platforms', (
    WidgetTester tester,
  ) async {
    final apiClient = _TrackingHomeDiscoverApiClient();

    await tester.pumpWidget(_buildHomeTestApp(apiClient: apiClient));

    await tester.pumpAndSettle();

    expect(apiClient.fetchPlatformsCallCount, 0);
    expect(find.text('排行榜'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });
}

Widget _buildHomeTestApp({required HomeDiscoverApiClient apiClient}) {
  return ProviderScope(
    overrides: <Override>[
      appConfigProvider.overrideWith(_TestAppConfigController.new),
      playerControllerProvider.overrideWith(_TestPlayerController.new),
      onlinePlatformsProvider.overrideWith(_TestOnlinePlatformsController.new),
      homeDiscoverApiClientProvider.overrideWithValue(apiClient),
      searchDefaultPlaceholderProvider.overrideWith(
        _TestSearchDefaultPlaceholderController.new,
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android),
      home: const HomePage(),
    ),
  );
}

final List<OnlinePlatform> _fakeOnlinePlatforms = <OnlinePlatform>[
  OnlinePlatform(
    id: 'qq',
    name: 'QQ音乐',
    shortName: 'QQ',
    status: 1,
    featureSupportFlag: PlatformFeatureSupportFlag.getDiscoverPage,
  ),
  OnlinePlatform(
    id: 'disabled',
    name: 'Disabled',
    shortName: 'OFF',
    status: 2,
    featureSupportFlag: PlatformFeatureSupportFlag.getDiscoverPage,
  ),
];

class _TestAppConfigController extends AppConfigController {
  @override
  AppConfigState build() {
    return AppConfigState.initial.copyWith(localeCode: 'zh');
  }
}

class _TestPlayerController extends PlayerController {
  @override
  PlayerPlaybackState build() {
    return PlayerPlaybackState.initial(const <PlayerTrack>[]);
  }

  @override
  Future<void> initialize() async {}
}

class _TestOnlinePlatformsController extends OnlinePlatformsController {
  @override
  Future<List<OnlinePlatform>> build() async {
    return _fakeOnlinePlatforms;
  }
}

class _TestSearchDefaultPlaceholderController
    extends SearchDefaultPlaceholderController {
  @override
  SearchDefaultPlaceholderState build() {
    return const SearchDefaultPlaceholderState();
  }
}

class _TestHomeDiscoverApiClient extends HomeDiscoverApiClient {
  _TestHomeDiscoverApiClient() : super(Dio());

  @override
  Future<List<HomePlatform>> fetchPlatforms() async {
    return <HomePlatform>[
      HomePlatform(
        id: 'qq',
        name: 'QQ',
        shortName: 'QQ',
        status: 1,
        featureSupportFlag: PlatformFeatureSupportFlag.getDiscoverPage,
      ),
    ];
  }

  @override
  Future<List<HomeDiscoverSection>> fetchDiscoverSections(
    String platformId,
  ) async {
    return const <HomeDiscoverSection>[];
  }
}

class _TrackingHomeDiscoverApiClient extends _TestHomeDiscoverApiClient {
  int fetchPlatformsCallCount = 0;

  @override
  Future<List<HomePlatform>> fetchPlatforms() {
    fetchPlatformsCallCount += 1;
    return super.fetchPlatforms();
  }
}
