import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:he_music_flutter/app/config/app_config_controller.dart';
import 'package:he_music_flutter/app/config/app_config_state.dart';
import 'package:he_music_flutter/features/auth/domain/entities/qr_login_state.dart';
import 'package:he_music_flutter/features/auth/presentation/providers/qr_login_providers.dart';
import 'package:he_music_flutter/features/online/data/online_api_client.dart';
import 'package:he_music_flutter/features/online/presentation/providers/online_providers.dart';

void main() {
  test('desktop qr login flow creates session and exchanges token', () async {
    final client = _FakeOnlineApiClient.desktop();
    final container = ProviderContainer(
      overrides: <Override>[
        onlineApiClientProvider.overrideWithValue(client),
        appConfigProvider.overrideWith(() => _TestAppConfigController()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(qrLoginControllerProvider.notifier);
    await controller.createDesktopSession(
      clientType: 'flutter_desktop',
      clientName: 'HE Music macOS',
      scene: 'desktop_login',
    );
    await controller.pollDesktopSessionStatus();

    final state = container.read(qrLoginControllerProvider);
    expect(state.status, QrLoginWorkflowStatus.success);
    expect(state.sessionId, 'qls_desktop');
    expect(state.qrContent, contains('hemusic://auth/qr'));
    expect(state.successToken, 'desktop-token');
    expect(client.exchangeCalled, isTrue);
  });

  test('mobile qr login flow parses content and confirms session', () async {
    final client = _FakeOnlineApiClient.mobile();
    final container = ProviderContainer(
      overrides: <Override>[
        onlineApiClientProvider.overrideWithValue(client),
        appConfigProvider.overrideWith(
          () => _TestAppConfigController(authToken: 'mobile-token'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(qrLoginControllerProvider.notifier);
    await controller.handleScannedContent(
      'hemusic://auth/qr?sid=qls_mobile&c=challenge_mobile',
    );
    await controller.confirmPendingSession();

    final state = container.read(qrLoginControllerProvider);
    expect(state.status, QrLoginWorkflowStatus.confirmed);
    expect(state.sessionId, 'qls_mobile');
    expect(state.clientName, 'HE Music macOS');
    expect(state.scene, 'desktop_login');
    expect(client.confirmCalled, isTrue);
  });
}

class _TestAppConfigController extends AppConfigController {
  _TestAppConfigController({this.authToken});

  final String? authToken;

  @override
  AppConfigState build() {
    return AppConfigState.initial.copyWith(authToken: authToken);
  }
}

class _FakeOnlineApiClient extends OnlineApiClient {
  _FakeOnlineApiClient._({
    required this.createResult,
    required this.statusResult,
    required this.scanResult,
    required this.confirmResult,
    required this.exchangeResult,
  }) : super(Dio());

  final QrLoginSessionResult createResult;
  final QrLoginSessionStatusResult statusResult;
  final QrLoginScanResult scanResult;
  final QrLoginConfirmResult confirmResult;
  final QrLoginExchangeResult exchangeResult;

  bool exchangeCalled = false;
  bool confirmCalled = false;

  factory _FakeOnlineApiClient.desktop() {
    return _FakeOnlineApiClient._(
      createResult: const QrLoginSessionResult(
        sessionId: 'qls_desktop',
        qrContent: 'hemusic://auth/qr?sid=qls_desktop&c=challenge_desktop',
        resultToken: 'result_desktop',
        status: 'pending',
        checkInterval: 2,
        expireAt: 1774593600,
      ),
      statusResult: const QrLoginSessionStatusResult(
        sessionId: 'qls_desktop',
        status: 'confirmed',
        checkInterval: 2,
        expireAt: 1774593600,
        clientName: 'HE Music macOS',
        userHint: '已确认，桌面端可拉取结果',
      ),
      scanResult: const QrLoginScanResult(
        sessionId: '',
        status: '',
        clientName: '',
        scene: '',
        expireAt: 0,
      ),
      confirmResult: const QrLoginConfirmResult(
        sessionId: '',
        status: '',
        expireAt: 0,
      ),
      exchangeResult: const QrLoginExchangeResult(
        sessionId: 'qls_desktop',
        status: 'success',
        token: 'desktop-token',
        expireAt: 1774593600,
      ),
    );
  }

  factory _FakeOnlineApiClient.mobile() {
    return _FakeOnlineApiClient._(
      createResult: const QrLoginSessionResult(
        sessionId: '',
        qrContent: '',
        resultToken: '',
        status: '',
        checkInterval: 0,
        expireAt: 0,
      ),
      statusResult: const QrLoginSessionStatusResult(
        sessionId: '',
        status: '',
        checkInterval: 0,
        expireAt: 0,
        clientName: '',
        userHint: '',
      ),
      scanResult: const QrLoginScanResult(
        sessionId: 'qls_mobile',
        status: 'scanned',
        clientName: 'HE Music macOS',
        scene: 'desktop_login',
        expireAt: 1774593600,
      ),
      confirmResult: const QrLoginConfirmResult(
        sessionId: 'qls_mobile',
        status: 'confirmed',
        expireAt: 1774593600,
      ),
      exchangeResult: const QrLoginExchangeResult(
        sessionId: '',
        status: '',
        token: '',
        expireAt: 0,
      ),
    );
  }

  @override
  Future<QrLoginSessionResult> createQrLoginSession({
    required String clientType,
    required String clientName,
    required String scene,
  }) async {
    return createResult;
  }

  @override
  Future<QrLoginSessionStatusResult> getQrLoginSessionStatus({
    required String sessionId,
  }) async {
    return statusResult;
  }

  @override
  Future<QrLoginScanResult> scanQrLoginSession({
    required String sessionId,
    required String challenge,
  }) async {
    return scanResult;
  }

  @override
  Future<QrLoginConfirmResult> confirmQrLoginSession({
    required String sessionId,
    required String challenge,
  }) async {
    confirmCalled = true;
    return confirmResult;
  }

  @override
  Future<QrLoginExchangeResult> exchangeQrLoginResult({
    required String sessionId,
    required String resultToken,
  }) async {
    exchangeCalled = true;
    return exchangeResult;
  }
}
