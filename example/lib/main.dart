import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_viewer/video_viewer.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light));
    return MaterialApp(
      home: HomePage(),
      title: 'Video Viewer Example',
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(child: WebVTTSubtitleVideoExample()),
    );
  }
}

class UsingVideoControllerExample extends StatefulWidget {
  UsingVideoControllerExample({Key key}) : super(key: key);

  @override
  _UsingVideoControllerExampleState createState() =>
      _UsingVideoControllerExampleState();
}

class _UsingVideoControllerExampleState
    extends State<UsingVideoControllerExample> {
  final GlobalKey<VideoViewerState> key = GlobalKey<VideoViewerState>();

  @override
  Widget build(BuildContext context) {
    return VideoViewer(
      key: key,
      source: {
        "SubRip Text": VideoSource(
          video: VideoPlayerController.network(
              "https://www.speechpad.com/proxy/get/marketing/samples/standard-captions-example.mp4"),
          subtitle: VideoViewerSubtitle.network(
            "https://pastebin.com/raw/h9cP6N5N",
            type: SubtitleType.webvtt,
          ),
        )
      },
    );
  }

  SubtitleData getActiveSubtitle() =>
      key.currentState.controller.activeSubtitle;
  VideoPlayerController getVideoPlayer() =>
      key.currentState.controller.controller;
  String getActiveSourceName() => key.currentState.controller.activeSource;
  bool isFullScreen() => key.currentState.controller.isFullScreen;
  bool isBuffering() => key.currentState.controller.isBuffering;
  bool isPlaying() => key.currentState.controller.isPlaying;
}

class NetworkVideoExample extends StatelessWidget {
  const NetworkVideoExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> src = {
      "1080p":
          "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "720p":
          "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_480_1_5MG.mp4",
    };

    return VideoViewer(
      onFullscreenFixLandscape: false,
      language: VideoViewerLanguage.es,
      source: VideoSource.getNetworkVideoSources(src),
      style: VideoViewerStyle(
        thumbnail: Image.network(
            "https://rockcontent.com/es/wp-content/uploads/2019/02/thumbnail.png"),
        header: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("MY AMAZING VIDEO",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text("YES!", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      settingsMenuItems: [
        SettingsMenuItem(
          mainMenu: Text("OTHERS",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          secondaryMenu: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("CHANGE ROTATION", style: TextStyle(color: Colors.white)),
              Text("SCREENSHOT", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

class HLSVideoExample extends StatelessWidget {
  const HLSVideoExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: createHLSFiles(
          "https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8"),
      builder: (_, data) {
        if (data.hasData)
          return VideoViewer(source: data.data);
        else
          return CircularProgressIndicator();
      },
    );
  }

  ///USE [path_provider] AND [dart.io] **(Only available on Android and iOS)**
  Future<Map<String, VideoSource>> createHLSFiles(String url) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final Map<String, String> files =
        await VideoSource.getm3u8VideoFileData(url);
    Map<String, VideoSource> sources = {
      "Auto": VideoSource(video: VideoPlayerController.network(url)),
    };

    for (String quality in files.keys) {
      final File file = File('${directory.path}/hls$quality.m3u8');
      await file.writeAsString(files[quality]);
      sources["${quality.split("x").last}p"] =
          VideoSource(video: VideoPlayerController.file(file));
    }

    return sources;
  }
}

class WebVTTSubtitleVideoExample extends StatelessWidget {
  const WebVTTSubtitleVideoExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoViewer(
      source: {
        "SubRip Text": VideoSource(
          video: VideoPlayerController.network(
              "https://www.speechpad.com/proxy/get/marketing/samples/standard-captions-example.mp4"),
          subtitle: VideoViewerSubtitle.network(
            "https://pastebin.com/raw/h9cP6N5N",
            type: SubtitleType.webvtt,
          ),
        )
      },
    );
  }
}

class SubRipSubtitleVideoExample extends StatelessWidget {
  const SubRipSubtitleVideoExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtitle = VideoViewerSubtitle.content(
      '''
      1
      00:00:03,400 --> 00:00:06,177
      In this lesson, we're going to
      be talking about finance. And

      2
      00:00:06,177 --> 00:00:10,009
      one of the most important aspects
      of finance is interest.

      3
      00:00:10,009 --> 00:00:13,655
      When I go to a bank or some
      other lending institution

      4
      00:00:13,655 --> 00:00:17,720
      to borrow money, the bank is happy
      to give me that money. But then I'm

      5
      00:00:17,900 --> 00:00:21,480
      going to be paying the bank for the
      privilege of using their money. And that

      6
      00:00:21,660 --> 00:00:26,440
      amount of money that I pay the bank is
      called interest. Likewise, if I put money

      7
      00:00:26,620 --> 00:00:31,220
      in a savings account or I purchase a
      certificate of deposit, the bank just

      8
      00:00:31,300 --> 00:00:35,800
      doesn't put my money in a little box
      and leave it there until later. They take

      9
      00:00:35,800 --> 00:00:40,822
      my money and lend it to someone
      else. So they are using my money.

      10
      00:00:40,822 --> 00:00:44,400
      The bank has to pay me for the privilege
      of using my money.

      11
      00:00:44,400 --> 00:00:48,700
      Now what makes banks
      profitable is the rate

      12
      00:00:48,700 --> 00:00:53,330
      that they charge people to use the bank's
      money is higher than the rate that they

      13
      00:00:53,510 --> 00:01:00,720
      pay people like me to use my money. The
      amount of interest that a person pays or

      14
      00:01:00,800 --> 00:01:06,640
      earns is dependent on three things. It's
      dependent on how much money is involved.

      15
      00:01:06,820 --> 00:01:11,300
      It's dependent upon the rate of interest
      being paid or the rate of interest being

      16
      00:01:11,480 --> 00:01:17,898
      charged. And it's also dependent upon
      how much time is involved. If I have

      17
      00:01:17,898 --> 00:01:22,730
      a loan and I want to decrease the amount
      of interest that I'm going to pay, then

      18
      00:01:22,800 --> 00:01:28,040
      I'm either going to have to decrease how
      much money I borrow, I'm going to have

      19
      00:01:28,220 --> 00:01:32,420
      to borrow the money over a shorter period
      of time, or I'm going to have to find a

      20
      00:01:32,600 --> 00:01:37,279
      lending institution that charges a lower
      interest rate. On the other hand, if I

      21
      00:01:37,279 --> 00:01:41,480
      want to earn more interest on my
      investment, I'm going to have to invest

      22
      00:01:41,480 --> 00:01:46,860
      more money, leave the money in the
      account for a longer period of time, or

      23
      00:01:46,860 --> 00:01:49,970
      find an institution that will pay
      me a higher interest rate.
      ''',
      type: SubtitleType.srt,
    );
    return VideoViewer(
      source: {
        "SubRip Text": VideoSource(
          video: VideoPlayerController.network(
              "https://www.speechpad.com/proxy/get/marketing/samples/standard-captions-example.mp4"),
          subtitle: subtitle,
        )
      },
    );
  }
}
