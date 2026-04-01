import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:he_music_flutter/features/video/data/datasources/video_plaza_api_client.dart';
import 'package:he_music_flutter/features/video/domain/entities/video_plaza_page_result.dart';
import 'package:he_music_flutter/features/video/presentation/providers/video_plaza_providers.dart';
import 'package:he_music_flutter/shared/models/he_music_models.dart';

void main() {
  test('initialize loads filters and first video page', () async {
    final client = _FakeVideoPlazaApiClient();
    final container = ProviderContainer(
      overrides: <Override>[
        videoPlazaApiClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(videoPlazaControllerProvider.notifier)
        .initialize('qq');
    final state = container.read(videoPlazaControllerProvider);

    expect(client.fetchFiltersCalls, 1);
    expect(client.fetchVideosCalls, 1);
    expect(state.selectedPlatformId, 'qq');
    expect(state.selectedFilters['area'], 'all');
    expect(state.videos.map((item) => item.name), contains('今日 MV'));
    expect(state.pageIndex, 2);
    expect(state.hasMore, true);
  });

  test('loadMore appends videos from next page', () async {
    final client = _FakeVideoPlazaApiClient();
    final container = ProviderContainer(
      overrides: <Override>[
        videoPlazaApiClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(videoPlazaControllerProvider.notifier)
        .initialize('qq');
    await container.read(videoPlazaControllerProvider.notifier).loadMore();
    final state = container.read(videoPlazaControllerProvider);

    expect(client.fetchVideosCalls, 2);
    expect(state.videos.map((item) => item.name), <String>['今日 MV', '继续播放']);
    expect(state.pageIndex, 3);
    expect(state.hasMore, false);
  });
}

class _FakeVideoPlazaApiClient extends VideoPlazaApiClient {
  _FakeVideoPlazaApiClient() : super(Dio());

  int fetchFiltersCalls = 0;
  int fetchVideosCalls = 0;

  @override
  Future<List<FilterInfo>> fetchFilters({required String platform}) async {
    fetchFiltersCalls += 1;
    return const <FilterInfo>[
      FilterInfo(
        id: 'area',
        platform: 'qq',
        options: <FilterOptionInfo>[
          FilterOptionInfo(value: 'all', label: '全部'),
          FilterOptionInfo(value: 'cn', label: '华语'),
        ],
      ),
    ];
  }

  @override
  Future<VideoPlazaPageResult> fetchVideos({
    required String platform,
    required Map<String, String> filters,
    int pageIndex = 1,
    int pageSize = 50,
  }) async {
    fetchVideosCalls += 1;
    if (pageIndex == 1) {
      return VideoPlazaPageResult(
        list: <MvInfo>[
          MvInfo(
            platform: platform,
            links: const <LinkInfo>[],
            id: 'mv-1',
            name: '今日 MV',
            cover: '',
            type: 0,
            playCount: '10',
            creator: '测试作者',
            duration: 120,
            description: '',
          ),
        ],
        hasMore: true,
      );
    }
    return VideoPlazaPageResult(
      list: <MvInfo>[
        MvInfo(
          platform: platform,
          links: const <LinkInfo>[],
          id: 'mv-2',
          name: '继续播放',
          cover: '',
          type: 0,
          playCount: '20',
          creator: '测试作者',
          duration: 150,
          description: '',
        ),
      ],
      hasMore: false,
    );
  }
}
