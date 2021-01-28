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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final subtitle =
        VideoViewerSubtitle.network("https://pastebin.com/raw/ZWWAL7fK");
    await subtitle.initialized();
    subtitle.subtitles.listen((event) {
      print(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(child: networkVideo()),
    );
  }

  //-------------//
  //NETWORK VIDEO//
  //-------------//
  Widget networkVideo() {
    final Map<String, String> src = {
      "1080p":
          "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "720p":
          "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_480_1_5MG.mp4",
    };
    return video(VideoSource.getNetworkVideoSources(src));
  }

  Widget video(source) {
    final String image =
        "https://rockcontent.com/es/wp-content/uploads/2019/02/thumbnail.png";
    return VideoViewer(
      onFullscreenFixLandscape: false,
      language: VideoViewerLanguage.es,
      source: source,
      style: VideoViewerStyle(
        thumbnail: Image.network(image),
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

  //----------------//
  //HLS VIDEO (m3u8)//
  //----------------//
  Widget hlsVideo() {
    final String src =
        "https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8";
    return FutureBuilder(
      future: createFiles(src),
      builder: (_, data) {
        if (data.hasData)
          return video(data.data);
        else
          return CircularProgressIndicator();
      },
    );
  }

  ///USE [path_provider] AND [dart.io] (Only available on Android and iOS)
  Future<Map<String, VideoPlayerController>> createFiles(String url) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final Map<String, String> files =
        await VideoSource.getm3u8VideoFileData(url);
    Map<String, VideoPlayerController> sources = {
      "Auto": VideoPlayerController.network(url)
    };

    for (String quality in files.keys) {
      final File file = File('${directory.path}/hls$quality.m3u8');
      await file.writeAsString(files[quality]);
      sources["${quality.split("x").last}p"] = VideoPlayerController.file(file);
    }

    return sources;
  }

  //--------------------//
  //SERIE EPISODES VIDEO//
  //--------------------//
  Widget serieEpisodesVideo() {
    final Map<String, String> source = {
      "Episode 1":
          "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "Episode1":
          "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_480_1_5MG.mp4",
    };

    return VideoViewer(
      onFullscreenFixLandscape: false,
      language: VideoViewerLanguage.es,
      source: VideoSource.getNetworkVideoSources(source),
      style: VideoViewerStyle(
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
    );
  }
}
