# video_viewer

## My other APIs

- [Scroll Navigation](https://pub.dev/packages/scroll_navigation)
- [Helpers](https://pub.dev/packages/helpers)

<br>

## Features

- Amazing UI / UX
- Fully customizable
- Fancy animations
- Cached Videos Support (beta)
- Easy and powerful implementation! :)

<br>

---

<br>

## Controls

|             Playing              |             Paused              |
| :------------------------------: | :-----------------------------: |
| ![](./assets/readme/playing.jpg) | ![](./assets/readme/paused.jpg) |

<br><br>

## Rewind and Forward

|        Double Tap Rewind        |        Double Tap Forward        |
| :-----------------------------: | :------------------------------: |
| ![](./assets/readme/rewind.jpg) | ![](./assets/readme/forward.jpg) |

<br><br>

## Fullscreen

|                   Portrait                   |                   Landscape                   |
| :------------------------------------------: | :-------------------------------------------: |
| ![](./assets/readme/fullscreen_portrait.jpg) | ![](./assets/readme/fullscreen_landscape.jpg) |

<br><br>

## Extras

|             Settings Menu              |  Volume Bar (Only Android Support)  |
| :------------------------------------: | :---------------------------------: |
| ![](./assets/readme/settings_menu.jpg) | ![](./assets/readme/volume_bar.jpg) |

<br>

---

<br>

## Global Gestures

- **One Tap:** Show or hide the overlay that contains the PlayAndPauseWidget and the ProgressBar
- **Double tap:**
  - Left: Double tapping on the left side of the VideoViewer will do the **rewind**. Default 10 seconds.
  - Right: Double-tapping on the right side of the VideoViewer will **forward**. Default 10 seconds.
- **Horizontal Drag:**
  - Left: Making a horizontal movement to the left will make a **rewind** proportional to the distance traveled.
  - Right: Making a horizontal movement to the right will make a **forward** proportional to the distance traveled.
- **Vertical Drag:** Scrolling vertically will activate the VolumeBar and change the **volume** of the device. **Only available on Android**
