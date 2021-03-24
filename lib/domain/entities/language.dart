class VideoViewerLanguage {
  final String quality;
  final String speed;
  final String caption;
  final String settings;
  final String captionNone;
  final String normalSpeed;
  final String seconds;

  ///CUSTOM LANGUAGE FOR VIDEO VIEWER
  const VideoViewerLanguage({
    this.settings = "Settings",
    this.quality = "Quality",
    this.speed = "Speed",
    this.caption = "Caption",
    this.captionNone = "None",
    this.normalSpeed = "Normal",
    this.seconds = "Seconds",
  });

  ///ENTER A STRING AND RETURN THE LANGUAGE OBJECT
  /// - "es" = Spanish Language
  /// - "en" = English Language
  /// - "as" = Arabic Language
  static VideoViewerLanguage fromString(String language) {
    if (language == "es") return es;
    if (language == "ar") return ar;
    return en;
  }

  ///**SPANISH LANGUAGE**
  static const VideoViewerLanguage es = VideoViewerLanguage(
      settings: "Regresar",
      quality: "Calidad",
      speed: "Velocidad",
      caption: "Subtítulos",
      captionNone: "Ninguno",
      normalSpeed: "Normal",
      seconds: "Segundos");

  ///**ENGLISH LANGUAGE**
  static const VideoViewerLanguage en = VideoViewerLanguage();

  ///**ARABIC LANGUAGE**
  static const VideoViewerLanguage ar = VideoViewerLanguage(
    settings: "إعدادات",
    quality: "الجودة",
    speed: "السرعة",
    caption: "التسميات التوضيحية",
    normalSpeed: "طبيعي",
    captionNone: "لا شيء",
    seconds: "ثواني",
  );
}
