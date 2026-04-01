import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:he_music_flutter/features/download/domain/repositories/download_repository.dart';
import 'package:he_music_flutter/features/download/presentation/providers/download_providers.dart';

void main() {
  test('enqueue completes queued task and stores file path', () async {
    final repository = _FakeDownloadRepository();
    final container = ProviderContainer(
      overrides: <Override>[
        downloadRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(downloadControllerProvider.notifier)
        .enqueue(title: '测试下载', url: 'https://example.com/song.mp3');
    final state = container.read(downloadControllerProvider);

    expect(repository.resolveSavePathCalls, 1);
    expect(repository.downloadFileCalls, 1);
    expect(state.isProcessing, false);
    expect(state.tasks, hasLength(1));
    expect(state.tasks.first.status.name, 'completed');
    expect(state.tasks.first.filePath, '/tmp/测试下载.mp3');
  });
}

class _FakeDownloadRepository implements DownloadRepository {
  int resolveSavePathCalls = 0;
  int downloadFileCalls = 0;

  @override
  Future<String> resolveSavePath({
    required String title,
    required String url,
  }) async {
    resolveSavePathCalls += 1;
    return '/tmp/$title.mp3';
  }

  @override
  Future<void> downloadFile({
    required String url,
    required String savePath,
    required DownloadProgressCallback onProgress,
  }) async {
    downloadFileCalls += 1;
    onProgress(0.4);
    onProgress(1);
  }
}
