import 'dart:async';

import 'package:cast_sdk/cast_listener.dart';
import 'package:cast_sdk/cast_sdk.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> implements CastListener {
  String _status = 'connect';
  double? totalDuration;
  double? position;

  CastSdk? castSdk;
  List<String> logList = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    castSdk = CastSdk(castListener: this);
    // castSdk?.startDiscovery;
    // logList.add("Start Discovery");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () {
                        castSdk?.startDiscovery;
                      },
                      child: const Text("Start Discovery")),
                ),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        castSdk?.startConnect;
                      },
                      child: Text(_status),
                    )),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (await castSdk?.checkVideoCapacity == true) {
                          addLog("video capable");
                          castSdk?.loadVideo;
                        } else {
                          addLog("video not capable");
                        }
                      },
                      child: Text("Video"),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        castSdk?.playVideo;
                      },
                      child: Text("Play"),
                    )),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        castSdk?.pauseVideo;
                      },
                      child: Text("pause"),
                    )),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        castSdk?.stopVideo;
                      },
                      child: Text("stop"),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        castSdk?.seekVideo(1000);
                      },
                      child: Text("seek"),
                    )),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        castSdk?.fastForwardVideo;
                      },
                      child: Text("FastForward"),
                    )),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        castSdk?.closeVideo;
                      },
                      child: Text("close"),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Total - $totalDuration"),
                Text("Duration - $position"),
              ],
            ),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 38.0),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Text("- " + logList[index]),
                      );
                    },
                    itemCount: logList.length,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  @override
  void onConnect() {
    addLog("OnConnect");
    _status = "Connect";
  }

  @override
  void onDisconnect() {
    addLog("OnDisconnect");
    _status = "Disconnect";
  }

  @override
  void onFailed(String? error) {
    _status = "Connect";
    addLog(error ?? "");
  }

  @override
  void onLogs(String? log) {
    addLog(log ?? "");
  }

  void addLog(String log) {
    setState(() {
      logList.add(log);
    });
  }

  @override
  void onDuration(double? value) {
    addLog("onDuration $value");

    setState(() {
      totalDuration = value;
    });
  }

  @override
  void onPositionUpdate(double? value) {
    addLog("onPositionUpdate $value");
    setState(() {
      position = value;
    });
  }
}
