import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cast_listener.dart';
import 'constant.dart';

class CastSdk {
  final MethodChannel _channel = const MethodChannel(methodChannelName);

  final CastListener? castListener;

  CastSdk({this.castListener}) {
    _channel.setMethodCallHandler((call) => _handleMethodCall(call));
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint("===> handle method ${call.arguments} ${call.method}");
    switch (call.method) {
      case onConnectListener:
        castListener?.onConnect();
        break;
      case onDisConnectListener:
        castListener?.onDisconnect();
        break;
      case onFailedListener:
        castListener?.onFailed(call.arguments);
        break;

      case onLogListener:
        castListener?.onLogs(call.arguments);
        break;
      case onPositionUpdateListener:
        castListener?.onPositionUpdate(call.arguments.toDouble());
        break;

      case onDurationListener:
        castListener?.onDuration(call.arguments.toDouble());
        break;

      default:
        throw MissingPluginException();
    }
  }

  Future get startDiscovery async {
    return await _channel.invokeMethod(startDiscoverAction);
  }

  Future get startConnect async {
    return await _channel.invokeMethod(startConnectAction);
  }

  Future<bool> get checkVideoCapacity async {
    return await _channel.invokeMethod(checkVideoCapacityAction);
  }

  Future get loadVideo async {
    return await _channel.invokeMethod(loadVideoAction);
  }

  Future get playVideo async {
    return await _channel.invokeMethod(playAction);
  }

  Future get pauseVideo async {
    return await _channel.invokeMethod(pauseAction);
  }

  Future get stopVideo async {
    return await _channel.invokeMethod(stopAction);
  }

  Future get closeVideo async {
    return await _channel.invokeMethod(closeAction);
  }

  Future get fastForwardVideo async {
    return await _channel.invokeMethod(fastForwardAction);
  }

  Future seekVideo(double position) async {
    return await _channel.invokeMethod(seekAction, position);
  }
}
