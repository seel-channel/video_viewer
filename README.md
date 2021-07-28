









# video_viewer

<br>

## My other APIs

- [Scroll Navigation](https://pub.dev/packages/scroll_navigation)
- [Helpers](https://pub.dev/packages/helpers)

<br>

## Features

- Amazing UI / UX.
- Fancy animations.
- Streaming Chat
- Custom Ads Support.
- Fully customizable.
- HLS (m3u8) format support.
- Captions (Subtitles) support.
- Cut the video (It just will show a specific time of the video)
- Easy and powerful implementation! :)

<br><br>

## **PREVIEW**
View the full source code in the [example](https://pub.dev/packages/video_viewer/example)

![video_viewer_preview](https://user-images.githubusercontent.com/65832922/125378278-4ed79f80-e343-11eb-992d-b7baeae0b06f.jpg)

High-Quality Video Demo: https://user-images.githubusercontent.com/65832922/125377927-acb7b780-e342-11eb-950d-b80707e96341.mp4

<br><br>

## **INSTALLATION**
### Android

Add _android.permission.INTERNET_ and _usesCleartextTraffic_ in your **Android Manifest** file, located in `<project_root>/android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <application android:usesCleartextTraffic="true"></aplication>
</manifest>
```

### iOS

Add the following entry to your **Info.plist** file, located in `<project_root>/ios/Runner/Info.plist`

```xml
<key>NSAppTransportSecurity</key>
<dict>
   <key>NSAllowsArbitraryLoads</key>
   <true/>
</dict>
```

**Warning:** The video player is not functional on **iOS simulators.** An iOS device must be used during development/testing.

<br><br>

## **GLOBAL GESTURES**

- **One Tap:** Show or hide the overlay that contains the PlayAndPauseWidget and the ProgressBar
- **Double tap:**
  - Left: Double tapping on the left side of the VideoViewer will do the **rewind**. Default 10 seconds.
  - Right: Double-tapping on the right side of the VideoViewer will **forward**. Default 10 seconds.
- **Horizontal Drag:**
  - Left: Making a horizontal movement to the left will make a **rewind** proportional to the distance traveled.
  - Right: Making a horizontal movement to the right will make a **forward** proportional to the distance traveled.
- **Vertical Drag:**
  - Up: **Increase** video **volume** proportional to the distance traveled.
  - Down: **Decrease** video **volume** proportional to the distance traveled.
- **Scale Drag:** When the VideoViewer is on fullscreen and landscape mode you can zoom to video for completing the screen width.

<br><br>

## **SCREENSHOTS**

|                Playing                 |                Paused                 |
| :------------------------------------: | :-----------------------------------: |
| ![](./assets/readme/movil/playing.jpg) | ![](./assets/readme/movil/paused.jpg) |

<br><br>

#### Rewind and Forward

|           Double Tap Rewind           |           Double Tap Forward           |
| :-----------------------------------: | :------------------------------------: |
| ![](./assets/readme/movil/rewind.jpg) | ![](./assets/readme/movil/forward.jpg) |

<br><br>

### Fullscreen

|                      Portrait                      |                      Landscape                      |
| :------------------------------------------------: | :-------------------------------------------------: |
| ![](./assets/readme/movil/fullscreen_portrait.jpg) | ![](./assets/readme/movil/fullscreen_landscape.jpg) |

<br><br>

### Settings Menu

|                Principal Menu                |                Quality Menu                 |
| :------------------------------------------: | :-----------------------------------------: |
| ![](./assets/readme/movil/settings_menu.jpg) | ![](./assets/readme/movil/quality_menu.jpg) |

<br><br>

### Volume Bar

![](./assets/readme/movil/volume_bar.jpg)

<br><br>
<!-- 
<br><br>

## **WEB**

|               Playing                |               Paused                |
| :----------------------------------: | :---------------------------------: |
| ![](./assets/readme/web/playing.jpg) | ![](./assets/readme/web/paused.jpg) |

<br><br>

### Rewind and Forward

| Double Tap and Keyboard.arrowLeft Rewind | Double Tap and Keyboard.arrowRight Forward |
| :--------------------------------------: | :----------------------------------------: |
|   ![](./assets/readme/web/rewind.jpg)    |    ![](./assets/readme/web/forward.jpg)    |

<br><br>

### Settings Menu

|               Principal Menu               |               Speed Menu                |
| :----------------------------------------: | :-------------------------------------: |
| ![](./assets/readme/web/settings_menu.jpg) | ![](./assets/readme/web/speed_menu.jpg) |

<br><br>

### FullScreen

![](./assets/readme/web/fullscreen.jpg)

<br><br>

### Volume Bar

![](./assets/readme/web/volume_bar.jpg)
<br><br> -->

---

<br><br>

## **EXAMPLES**
<!-- 
### **Serie Example** with 2 episodes

![](./assets/readme/SerieExample.gif)

SerieExample works to change an episode directly from VideoViewer without leaving VideoViewer.
It has different sources because some videos have different qualities.

**Note:** The episodes selector is fully customizable.

```dart
class SerieExample extends StatefulWidget {
  SerieExample({Key key}) : super(key: key);

  @override
  _SerieExampleState createState() => _SerieExampleState();
}

class _SerieExampleState extends State<SerieExample> {
  final VideoViewerController controller = VideoViewerController();
  final Map<String, Map<String, String>> database = {
    "第1集": {
      "超清":
          "https://ks-xpc4.xpccdn.com/ff6c8b38-79a6-4040-b220-899e579a5c28.mp4",
    },
    "第2集": {
      "超清":
          "https://hls.syrme.top/hls/5ac73019-c1bc-4f5b-b295-52ff6a29a9e7/playlist.m3u8"
    },
    "第3集": {
      "超清":
          "https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8"
    },
    "第4集": {
      "超清":
          "https://ks-xpc4.xpccdn.com/ff6c8b38-79a6-4040-b220-899e579a5c28.mp4"
    },
    "第5集": {
      "超清":
          "https://ks-xpc4.xpccdn.com/3368e540-b1f9-4832-8167-a2334da19b5c.mp4"
    },
  };

  final Map<String, String> thumbnails = {
    "第1集":
        "https://cloudfront-us-east-1.images.arcpublishing.com/semana/FUM2RCCVW5EL5LQYCDVC6VRO2U.jpg",
    "第2集":
        "https://www.elcomercio.com/files/article_main/uploads/2019/03/29/5c9e3ddfc85ca.jpeg",
    "第3集":
        "https://cloudfront-us-east-1.images.arcpublishing.com/semana/FUM2RCCVW5EL5LQYCDVC6VRO2U.jpg",
    "第4集":
        "https://www.elcomercio.com/files/article_main/uploads/2019/03/29/5c9e3ddfc85ca.jpeg",
    "第5集":
        "https://cloudfront-us-east-1.images.arcpublishing.com/semana/FUM2RCCVW5EL5LQYCDVC6VRO2U.jpg",
  };

  String episode = "";
  MapEntry<String, Map<String, String>> initial;

  @override
  void initState() {
    initial = database.entries.first;
    episode = initial.key;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: VideoViewer(
          source: VideoSource.fromNetworkVideoSources(initial.value),
          controller: controller,
          language: VideoViewerLanguage.es,
          style: VideoViewerStyle(
            header: Builder(
              builder: (innerContext) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Game of Thrones: $episode",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            settingsStyle: SettingsMenuStyle(
              paddingBetween: 10,
              items: [
                SettingsMenuItem(
                  themed: SettingsMenuItemThemed(
                    title: "Episodes",
                    subtitle: episode,
                    icon: Icon(
                      Icons.view_module_outlined,
                      color: Colors.white,
                    ),
                  ),
                  secondaryMenuWidth: 300,
                  secondaryMenu: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Center(
                      child: Container(
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 10,
                          children: [
                            for (var entry in database.entries)
                              episodeImage(entry)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget episodeImage(MapEntry<String, Map<String, String>> entry) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: Material(
        child: InkWell(
          onTap: () async {
            final episodeName = entry.key;
            final qualities = entry.value;

            Map<String, VideoSource> sources;
            String url = qualities.entries.first.value;

            if (url.contains("m3u8")) {
              sources = await VideoSource.fromM3u8PlaylistUrl(
                url,
                formatter: (size) => "${size.height}p",
              );
            } else {
              sources = VideoSource.fromNetworkVideoSources(qualities);
            }

            final video = sources.entries.first;

            await controller.changeSource(
              inheritValues: false, //RESET SPEED TO NORMAL AND POSITION TO ZERO
              source: video.value,
              name: video.key,
            );

            controller.closeAllSecondarySettingsMenus();
            controller.source = sources;
            episode = episodeName;
            setState(() {});
          },
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                width: 80,
                height: 80,
                color: Colors.white,
                child: Image.network(thumbnails[entry.key], fit: BoxFit.cover),
              ),
              Text(
                entry.key,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
```

<br><br> -->

### Using **VideoViewerController**

```dart
class UsingVideoControllerExample extends StatefulWidget {
  UsingVideoControllerExample({Key key}) : super(key: key);

  @override
  _UsingVideoControllerExampleState createState() =>  _UsingVideoControllerExampleState();
}

class _UsingVideoControllerExampleState extends State<UsingVideoControllerExample> {
  final VideoViewerController controller = VideoViewerController();

  @override
  Widget build(BuildContext context) {
    return VideoViewer(
      controller: controller,
      source: {
        "SubRip Text": VideoSource(
          video: VideoPlayerController.network(
              "https://www.speechpad.com/proxy/get/marketing/samples/standard-captions-example.mp4"),
          subtitle: {
            "English": VideoViewerSubtitle.network(
              "https://felipemurguia.com/assets/txt/WEBVTT_English.txt",
              type: SubtitleType.webvtt,
            ),
          },
        )
      },
    );
  }

  VideoPlayerController getVideoPlayer() => controller.controller;
  String getactiveSourceNameName() => controller.activeSourceName;
  String getActiveCaption() => controller.activeCaption;
  bool isFullScreen() => controller.isFullScreen;
  bool isBuffering() => controller.isBuffering;
  bool isPlaying() => controller.isPlaying;
}
```

<!-- <br><br>

### Portrait Videos Example

```dart
class PortraitVideoExample extends StatelessWidget {
  const PortraitVideoExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> src = {
      "1":
          "https://assets.mixkit.co/videos/preview/mixkit-mysterious-pale-looking-fashion-woman-at-winter-39878-large.mp4",
      "2":
          "https://assets.mixkit.co/videos/preview/mixkit-winter-fashion-cold-looking-woman-concept-video-39874-large.mp4",
    };

    return VideoViewer(
      language: VideoViewerLanguage.es,
      source: VideoSource.getNetworkVideoSources(src),
      style: VideoViewerStyle(
        settingsStyle: SettingsMenuStyle(paddingBetween: 10),
      ),
    );
  }
}
``` -->

<br><br>

### HLS Network Video **(This example only works on Android and iOS)**

```dart
class HLSVideoExample extends StatelessWidget {
  const HLSVideoExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, VideoSource>>(
      future: VideoSource.fromM3u8PlaylistUrl(
        "https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8",
        formatter: (quality) => quality == "Auto" ? "Automatic" : "${quality.split("x").last}p",
      ),
      builder: (_, data) {
        return data.hasData
            ? VideoViewer(
                source: data.data,
                onFullscreenFixLandscape: true,
                style: VideoViewerStyle(
                  thumbnail: Image.network(
                    "https://play-lh.googleusercontent.com/aA2iky4PH0REWCcPs9Qym2X7e9koaa1RtY-nKkXQsDVU6Ph25_9GkvVuyhS72bwKhN1P",
                  ),
                ),
              )
            : CircularProgressIndicator();
      },
    );
  }
}
```

<br><br>

### Network Video with WebVTT Subtitles

```dart
class WebVTTSubtitleVideoExample extends StatelessWidget {
  const WebVTTSubtitleVideoExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoViewer(
      source: {
        "WebVTT Caption": VideoSource(
          video: VideoPlayerController.network(
            //This video has a problem when end
            "https://www.speechpad.com/proxy/get/marketing/samples/standard-captions-example.mp4",
          ),
          subtitle: {
            "English": VideoViewerSubtitle.network(
              "https://felipemurguia.com/assets/txt/WEBVTT_English.txt",
            ),
            "Spanish": VideoViewerSubtitle.network(
              "https://felipemurguia.com/assets/txt/WEBVTT_Spanish.txt",
            ),
          },
        )
      },
    );
  }
}
```

<br><br>

### Network Video with SubRip Subtitles

```dart
class SubRipSubtitleVideoExample extends StatelessWidget {
  const SubRipSubtitleVideoExample({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String content = '''
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
      ''';

    return VideoViewer(
      source: {
        "SubRip Caption": VideoSource(
          video: VideoPlayerController.network(
              "https://www.speechpad.com/proxy/get/marketing/samples/standard-captions-example.mp4"),
          subtitle: {
            "English": VideoViewerSubtitle.content(
              content,
              type: SubtitleType.srt,
            ),
          },
        )
      },
    );
  }
}
```
