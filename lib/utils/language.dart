class VideoViewerLanguage {
  final String quality;
  final String speed;
  final String settings;
  final String normalSpeed;

  const VideoViewerLanguage({
    this.settings = "Settings",
    this.quality = "Quality",
    this.speed = "Speed",
    this.normalSpeed = "Normal",
  });

  static fromString(String language) {
    if (language == "es") return es;
    if (language == "en") return en;
  }

  static const VideoViewerLanguage es = VideoViewerLanguage(
    settings: "Configuración",
    quality: "Calidad",
    speed: "Velocidad",
    normalSpeed: "Normal",
  );

  static const VideoViewerLanguage en = VideoViewerLanguage(
    settings: "Settings",
    quality: "Quality",
    speed: "Speed",
    normalSpeed: "Normal",
  );
}
