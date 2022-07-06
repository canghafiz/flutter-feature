part of 'video_trimmer_cubit.dart';

class VideoTrimmerState {
  bool isPlaying;
  double startValue, endValue;
  int selectedDuration;
  int? minute, second, allDuration;

  VideoTrimmerState({
    required this.endValue,
    required this.isPlaying,
    required this.startValue,
    required this.selectedDuration,
    required this.minute,
    required this.second,
    required this.allDuration,
  });
}
