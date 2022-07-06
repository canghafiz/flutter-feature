import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerCubitHandle {
  static VideoPlayerCubit read(BuildContext context) {
    return context.read<VideoPlayerCubit>();
  }
}

class VideoPlayerCubit extends Cubit<VideoPlayerController?> {
  VideoPlayerCubit() : super(null);

  // Function
  void initialize(File video) {
    emit(VideoPlayerController.file(video));
    state?.setLooping(true);
  }

  void play() {
    state?.play();
  }

  void pause() {
    state?.pause();
  }

  void dispose() {
    state?.dispose();
  }
}
