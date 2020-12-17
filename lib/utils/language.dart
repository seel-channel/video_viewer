class VideoViewerLanguage {
  final String quality;
  final String speed;
  final String settings;
  final String normalSpeed;

  ///CUSTOM LANGUAGE FOR VIDEO VIEWER
  const VideoViewerLanguage({
    this.settings = "Settings",
    this.quality = "Quality",
    this.speed = "Speed",
    this.normalSpeed = "Normal",
  });

  ///ENTER A STRING AND RETURN THE LANGUAGE OBJECT
  /// - "es" = Spanish Language
  /// - "en" = English Language
  static VideoViewerLanguage fromString(String language) {
    if (language == "es") return es;
    return en;
  }

  ///**SPANISH LANGUAGE**
  static const VideoViewerLanguage es = VideoViewerLanguage(
    settings: "Regresar",
    quality: "Calidad",
    speed: "Velocidad",
  );

  ///**ENGLISH LANGUAGE**
  static const VideoViewerLanguage en = VideoViewerLanguage(
    settings: "Settings",
    quality: "Quality",
    speed: "Speed",
  );
}
