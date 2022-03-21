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
  String deviceName = '';
  double? totalDuration;
  double? position;

  CastSdk? castSdk;
  List<String> logList = [];

  String url1 =
      "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/genesis/video-genesis-l07-ch6-ch7.mp4";
  String url2 =
      "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/esther/video-esther-l05-ch3-ch4.mp4";
  String url3 =
      "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/daniel/video-daniel-l01-intro.mp4";
  String url4 =
      "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/ruth/video-ruth-l08-ch4.mp4";

  String selectedVideo =
      "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/genesis/video-genesis-l07-ch6-ch7.mp4";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    castSdk = CastSdk(castListener: this);
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
              ],
            ),
            const Divider(
              color: Colors.grey,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () {
                        setState(() {
                          selectedVideo = url1;
                        });
                      },
                      child: Text(
                        "genesis",
                        style: TextStyle(
                            color: selectedVideo == url1
                                ? Colors.blue
                                : Colors.grey),
                      )),
                  InkWell(
                      onTap: () {
                        setState(() {
                          selectedVideo = url2;
                        });
                      },
                      child: Text(
                        "esther",
                        style: TextStyle(
                            color: selectedVideo == url2
                                ? Colors.blue
                                : Colors.grey),
                      )),
                  InkWell(
                      onTap: () {
                        setState(() {
                          selectedVideo = url3;
                        });
                      },
                      child: Text(
                        "daniel",
                        style: TextStyle(
                            color: selectedVideo == url3
                                ? Colors.blue
                                : Colors.grey),
                      )),
                  InkWell(
                      onTap: () {
                        setState(() {
                          selectedVideo = url4;
                        });
                      },
                      child: Text(
                        "ruth",
                        style: TextStyle(
                            color: selectedVideo == url4
                                ? Colors.blue
                                : Colors.grey),
                      )),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: isConnected()
                          ? () async {
                              // if (await castSdk?.checkVideoCapacity == true) {
                              //   addLog("video capable");
                              castSdk?.loadVideo(selectedVideo);
                              // } else {
                              //   addLog("video not capable");
                              // }
                            }
                          : null,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Video"),
                      ),
                    )),
                Text(deviceName)
              ],
            ),
            const Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: isConnected()
                          ? () {
                              castSdk?.playVideo;
                            }
                          : null,
                      child: const Text("Play"),
                    )),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: isConnected()
                          ? () {
                              castSdk?.pauseVideo;
                            }
                          : null,
                      child: const Text("pause"),
                    )),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: isConnected()
                          ? () {
                              castSdk?.stopVideo;
                            }
                          : null,
                      child: const Text("stop"),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: isConnected()
                          ? () {
                              castSdk?.seekVideo(10000);
                            }
                          : null,
                      child: const Text("seek"),
                    )),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: isConnected()
                          ? () {
                              castSdk?.forward;
                            }
                          : null,
                      child: const Text("FastForward"),
                    )),
                SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: isConnected()
                          ? () {
                              castSdk?.backward;
                            }
                          : null,
                      child: const Text("Backward"),
                    )),
                // SizedBox(
                //     width: 100,
                //     child: ElevatedButton(
                //       onPressed: () {
                //         castSdk?.closeVideo;
                //       },
                //       child: const Text("close"),
                //     )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Position - $position"),
                Text("Total Duration - $totalDuration"),
              ],
            ),
            const Divider(
              color: Colors.grey,
            ),
            SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      logList.clear();
                    });
                  },
                  child: const Text("Clear Log"),
                )),
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

  bool isConnected() => _status == "Disconnect";

  @override
  void onConnect(String? name) {
    addLog("OnConnect");

    setState(() {
      deviceName = name ?? "";
      _status = "Disconnect";
    });
  }

  @override
  void onDisconnect() {
    addLog("OnDisconnect");

    setState(() {
      deviceName = "";
      _status = "Connect";
    });
  }

  @override
  void onFailed(String? error) {
    addLog(error ?? "");
    setState(() {
      deviceName = "";
      _status = "Connect";
    });
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

  @override
  void onVideoPlayFailed() {
    addLog("onVideoPlayFailed ");
  }

  @override
  void onVideoPlayCompleted() {
    addLog("onVideoPlayCompleted ");
  }
}
