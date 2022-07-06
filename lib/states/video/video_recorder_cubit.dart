import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'video_recorder_state.dart';

class VideoRecorderCubitHandle {
  static VideoRecorderCubit read(BuildContext context) {
    return context.read<VideoRecorderCubit>();
  }

  static VideoRecorderCubit watch(BuildContext context) {
    return context.watch<VideoRecorderCubit>();
  }
}

class VideoRecorderCubit extends Cubit<VideoRecorderState> {
  VideoRecorderCubit() : super(_default);

  static final VideoRecorderState _default = VideoRecorderState(
    duration: const Duration(),
    timer: null,
    isPlaying: false,
  );

  // Function
  void clear() {
    emit(_default);
  }

  void _addTime() {
    const addSeconds = 1;

    emit(
      VideoRecorderState(
        duration: Duration(
          seconds: state.duration.inSeconds + addSeconds,
        ),
        timer: state.timer,
        isPlaying: state.isPlaying,
      ),
    );
  }

  void startTime() {
    emit(
      VideoRecorderState(
        duration: state.duration,
        timer: Timer.periodic(
          const Duration(seconds: 1),
          (_) => _addTime(),
        ),
        isPlaying: state.isPlaying,
      ),
    );
  }

  void reset() {
    state.timer?.cancel();
    emit(
      VideoRecorderState(
        duration: const Duration(),
        timer: state.timer,
        isPlaying: state.isPlaying,
      ),
    );
  }

  void updatePlaying(bool value) {
    emit(
      VideoRecorderState(
        duration: state.duration,
        timer: state.timer,
        isPlaying: value,
      ),
    );
  }
}
