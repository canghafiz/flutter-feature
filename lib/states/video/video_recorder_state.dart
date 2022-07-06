part of 'video_recorder_cubit.dart';

class VideoRecorderState {
  Duration duration;
  Timer? timer;
  bool isPlaying;

  VideoRecorderState({
    required this.duration,
    required this.timer,
    required this.isPlaying,
  });
}
