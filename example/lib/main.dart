import 'package:flutter/material.dart';
import 'package:video_viewer/video_viewer.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
  String image =
      "https://rockcontent.com/es/wp-content/uploads/2019/02/thumbnail.png";
  Map<String, String> src = {
    "1080p":
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    "720p":
        "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_480_1_5MG.mp4",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(children: [
          VideoViewer(
            onFullscreenFixLandscape: false,
            language: VideoViewerLanguage.es,
            source: getNetworkVideoSources(src),
            style: VideoViewerStyle(
              thumbnail: Image.network(image),
              header: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
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
          ),
        ]),
      ),
    );
  }
}
