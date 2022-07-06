import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

enum VideoStatus { undoing, onLoading, ondone }

class VideoStatusCubitHandle {
  static VideoStatusCubit read(BuildContext context) {
    return context.read<VideoStatusCubit>();
  }
}

class VideoStatusCubit extends Cubit<VideoStatus> {
  VideoStatusCubit() : super(_default);

  static const _default = VideoStatus.undoing;

  // Fumnction
  void clear() {
    emit(_default);
  }

  void update(VideoStatus value) {
    emit(value);
  }
}
