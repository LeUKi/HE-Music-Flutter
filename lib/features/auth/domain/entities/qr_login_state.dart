enum QrLoginWorkflowStatus {
  idle,
  creating,
  pending,
  scanned,
  confirmed,
  success,
  expired,
  cancelled,
  failure,
}

class QrLoginState {
  const QrLoginState({
    required this.status,
    required this.isBusy,
    required this.sessionId,
    required this.challenge,
    required this.resultToken,
    required this.qrContent,
    required this.clientName,
    required this.scene,
    required this.userHint,
    required this.checkInterval,
    required this.expireAt,
    this.successToken,
    this.errorMessage,
  });

  final QrLoginWorkflowStatus status;
  final bool isBusy;
  final String sessionId;
  final String challenge;
  final String resultToken;
  final String qrContent;
  final String clientName;
  final String scene;
  final String userHint;
  final int checkInterval;
  final int expireAt;
  final String? successToken;
  final String? errorMessage;

  bool get hasPendingMobileSession =>
      sessionId.isNotEmpty &&
      challenge.isNotEmpty &&
      status == QrLoginWorkflowStatus.scanned;

  QrLoginState copyWith({
    QrLoginWorkflowStatus? status,
    bool? isBusy,
    String? sessionId,
    String? challenge,
    String? resultToken,
    String? qrContent,
    String? clientName,
    String? scene,
    String? userHint,
    int? checkInterval,
    int? expireAt,
    String? successToken,
    String? errorMessage,
    bool clearSuccessToken = false,
    bool clearErrorMessage = false,
  }) {
    return QrLoginState(
      status: status ?? this.status,
      isBusy: isBusy ?? this.isBusy,
      sessionId: sessionId ?? this.sessionId,
      challenge: challenge ?? this.challenge,
      resultToken: resultToken ?? this.resultToken,
      qrContent: qrContent ?? this.qrContent,
      clientName: clientName ?? this.clientName,
      scene: scene ?? this.scene,
      userHint: userHint ?? this.userHint,
      checkInterval: checkInterval ?? this.checkInterval,
      expireAt: expireAt ?? this.expireAt,
      successToken: clearSuccessToken
          ? null
          : successToken ?? this.successToken,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  static const initial = QrLoginState(
    status: QrLoginWorkflowStatus.idle,
    isBusy: false,
    sessionId: '',
    challenge: '',
    resultToken: '',
    qrContent: '',
    clientName: '',
    scene: '',
    userHint: '',
    checkInterval: 0,
    expireAt: 0,
  );
}
