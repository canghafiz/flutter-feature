import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'video_trimmer_state.dart';

class VideoTrimmerCubitHandle {
  static VideoTrimmerCubit read(BuildContext context) {
    return context.read<VideoTrimmerCubit>();
  }

  static VideoTrimmerCubit watch(BuildContext context) {
    return context.watch<VideoTrimmerCubit>();
  }
}

class VideoTrimmerCubit extends Cubit<VideoTrimmerState> {
  VideoTrimmerCubit() : super(_default);

  // Data
  static final VideoTrimmerState _default = VideoTrimmerState(
    isPlaying: false,
    startValue: 0,
    endValue: 0,
    selectedDuration: 0,
    minute: null,
    second: null,
    allDuration: null,
  );

  static final List<int> durations = [15, 30, 45, 60];

  // Function
  void clear() {
    emit(
      VideoTrimmerState(
        isPlaying: _default.isPlaying,
        startValue: _default.startValue,
        endValue: _default.endValue,
        selectedDuration: state.selectedDuration,
        minute: state.minute,
        second: state.second,
        allDuration: state.allDuration,
      ),
    );
  }

  void updateIsPlaying(bool value) {
    emit(
      VideoTrimmerState(
        endValue: state.endValue,
        isPlaying: value,
        startValue: state.startValue,
        selectedDuration: 0,
        minute: state.minute,
        second: state.second,
        allDuration: state.allDuration,
      ),
    );
  }

  void udpateStart(double value) {
    emit(
      VideoTrimmerState(
        endValue: state.endValue,
        isPlaying: state.isPlaying,
        startValue: value,
        selectedDuration: 0,
        minute: state.minute,
        second: state.second,
        allDuration: state.allDuration,
      ),
    );
  }

  void udpateEnd(double value) {
    emit(
      VideoTrimmerState(
        endValue: value,
        isPlaying: state.isPlaying,
        startValue: state.startValue,
        selectedDuration: 0,
        minute: state.minute,
        second: state.second,
        allDuration: state.allDuration,
      ),
    );
  }

  void udpateSelectedDuration(int value) {
    emit(
      VideoTrimmerState(
        endValue: state.endValue,
        isPlaying: state.isPlaying,
        startValue: state.startValue,
        selectedDuration: value,
        minute: _default.minute,
        second: _default.second,
        allDuration: _default.allDuration,
      ),
    );
  }

  void updateMinute(int? minute) {
    emit(
      VideoTrimmerState(
        endValue: state.endValue,
        isPlaying: state.isPlaying,
        startValue: state.startValue,
        selectedDuration: -1,
        minute: minute,
        second: state.second,
        allDuration: _default.allDuration,
      ),
    );
  }

  void updateSecond(int? second) {
    emit(
      VideoTrimmerState(
        endValue: state.endValue,
        isPlaying: state.isPlaying,
        startValue: state.startValue,
        selectedDuration: -1,
        minute: state.minute,
        second: second,
        allDuration: _default.allDuration,
      ),
    );
  }

  void allDuration(int? value) {
    emit(
      VideoTrimmerState(
        endValue: state.endValue,
        isPlaying: state.isPlaying,
        startValue: state.startValue,
        selectedDuration: -1,
        minute: _default.minute,
        second: _default.second,
        allDuration: value,
      ),
    );
  }

  void clearDuration() {
    emit(
      VideoTrimmerState(
        endValue: state.endValue,
        isPlaying: state.isPlaying,
        startValue: state.startValue,
        selectedDuration: 0,
        minute: _default.minute,
        second: _default.second,
        allDuration: _default.allDuration,
      ),
    );
  }
}
