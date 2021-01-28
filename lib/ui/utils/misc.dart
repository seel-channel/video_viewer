String secondsFormatter(int seconds) {
  final Duration duration = Duration(seconds: seconds);
  final int hours = duration.inHours;
  final String formatter = [if (hours != 0) hours, duration.inMinutes, seconds]
      .map((seg) => seg.abs().remainder(60).toString().padLeft(2, '0'))
      .join(':');
  return seconds < 0 ? "-$formatter" : formatter;
}
