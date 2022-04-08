import 'dart:async';

import 'package:cast_sdk/cast_listener.dart';
import 'package:cast_sdk/cast_sdk.dart';
import 'package:flutter/material.dart';

import 'progress_bar.dart';

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

  List<double> durationList = [
    // 5665200,
    // 5682000,
    2796000,
    3050000,
    3462000
  ];

  List<String> urlNames = [
    // "genesis",
    "esther", "daniel", "ruth"];

  List<String> urlList = [
    // "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/genesis/video-genesis-l07-ch6-ch7.mp4",
    "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/esther/video-esther-l05-ch3-ch4.mp4",
    "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/daniel/video-daniel-l01-intro.mp4",
    "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/ruth/video-ruth-l08-ch4.mp4"
  ];

  // String url1 =
  //     "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/genesis/video-genesis-l07-ch6-ch7.mp4";
  //
  // /// 94.42
  // String url2 =
  //     "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/esther/video-esther-l05-ch3-ch4.mp4";
  //
  // /// 50.31
  // String url3 =
  //     "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/daniel/video-daniel-l01-intro.mp4";
  //
  // /// 50.50
  // String url4 =
  //     "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/ruth/video-ruth-l08-ch4.mp4";
  //
  // ///  57.42

  int selectedIndex = 0;

  // String selectedVideo =
  //     "http://d1fb1b55vzzqwl.cloudfront.net/en-us/torahclass/video/ot/genesis/video-genesis-l07-ch6-ch7.mp4";

  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

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

                        // totalDuration = durationList[selectedIndex];
                        // progressNotifier.value = ProgressBarState(
                        //     current: progressNotifier.value.current,
                        //     buffered: Duration.zero,
                        //     total: Duration(milliseconds: totalDuration?.toInt() ?? 0));

                        setState(() {

                        });
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
                  ...List.generate(
                    urlList.length,
                    (index) => InkWell(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                            // selectedVideo = urlList[selectedIndex];
                          });
                        },
                        child: Text(
                          urlNames[index],
                          style: TextStyle(
                              color: selectedIndex == index
                                  ? Colors.blue
                                  : Colors.grey),
                        )),
                  ),

                  // InkWell(
                  //     onTap: () {
                  //       setState(() {
                  //         selectedVideo = url2;
                  //       });
                  //     },
                  //     child: Text(
                  //       "esther",
                  //       style: TextStyle(
                  //           color: selectedVideo == url2
                  //               ? Colors.blue
                  //               : Colors.grey),
                  //     )),
                  // InkWell(
                  //     onTap: () {
                  //       setState(() {
                  //         selectedVideo = url3;
                  //       });
                  //     },
                  //     child: Text(
                  //       "daniel",
                  //       style: TextStyle(
                  //           color: selectedVideo == url3
                  //               ? Colors.blue
                  //               : Colors.grey),
                  //     )),
                  // InkWell(
                  //     onTap: () {
                  //       setState(() {
                  //         selectedVideo = url4;
                  //       });
                  //     },
                  //     child: Text(
                  //       "ruth",
                  //       style: TextStyle(
                  //           color: selectedVideo == url4
                  //               ? Colors.blue
                  //               : Colors.grey),
                  //     )),
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
                              castSdk?.loadVideo(urlList[selectedIndex]);
                              // } else {
                              //   addLog("video not capable");
                              // }
                            }
                          : null,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Cast Video"),
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
                // SizedBox(
                //     width: 100,
                //     child: ElevatedButton(
                //       onPressed: isConnected()
                //           ? () {
                //               castSdk?.seekVideo(10000);
                //             }
                //           : null,
                //       child: const Text("seek"),
                //     )),
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
            progressBar(),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Text("Position - $position"),
            //     Text("Total Duration - $totalDuration"),
            //   ],
            // ),
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

  Widget progressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      child: ValueListenableBuilder<ProgressBarState>(
        valueListenable: progressNotifier,
        builder: (_, value, __) {
          return ProgressBar(
            // key: ValueKey(reCreateProgressBar),
            timeLabelLocation: TimeLabelLocation.above,
            timeLabelPadding: 4.0,
            timeLabelTextStyle: TextStyle(color: Colors.black),
            thumbGlowRadius: 6.0,
            thumbRadius: 4,
            bufferedBarColor: Colors.grey,
            thumbGlowColor: Colors.grey,
            baseBarColor: Colors.grey,
            progressBarColor: Colors.grey,
            thumbColor: Colors.black,
            progress: value.current,
            buffered: value.buffered,
            total: value.total,
            onSeek: (duration) {
              seekCall(duration);
            },
          );
        },
      ),
    );
  }

  void seekCall(Duration position) {
    addLog("Seek ${position.inMilliseconds?.toString()}");
    castSdk?.seekVideo(position.inMilliseconds * 1.0);

    progressNotifier.value = ProgressBarState(
        current: position,
        buffered: Duration.zero,
        total: progressNotifier.value.total);
  }

  bool isConnected() => _status == "Disconnect";

  @override
  void onConnect(String? name) {
    addLog("OnConnect");

    totalDuration = durationList[selectedIndex];
    progressNotifier.value = ProgressBarState(
        current: progressNotifier.value.current,
        buffered: Duration.zero,
        total: Duration(milliseconds: totalDuration?.toInt() ?? 0));

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
      totalDuration = 0;
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

    // setState(() {
    //   totalDuration = value;
    // });
    // progressNotifier.value = ProgressBarState(
    //     current: progressNotifier.value.current,
    //     buffered: Duration.zero,
    //     total: Duration(milliseconds: totalDuration?.toInt() ?? 0));
  }

  @override
  void onPositionUpdate(double? value) {
    addLog("onPositionUpdate $value");

    setState(() {
      position = value;
    });

    progressNotifier.value = ProgressBarState(
        current: Duration(milliseconds: value?.toInt() ?? 0),
        buffered: Duration.zero,
        total: progressNotifier.value.total);
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
