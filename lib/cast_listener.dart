abstract class CastListener {
  void onConnect(String? name);

  void onFailed(String? error);

  void onDisconnect();

  void onLogs(String? log);

  void onDuration(double? value);

  void onPositionUpdate(double? value);

  void onVideoPlayCompleted();

  void onVideoPlayFailed();
}
