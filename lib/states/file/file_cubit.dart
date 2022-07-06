import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'file_state.dart';

class FileCubitHandle {
  static FileCubit read(BuildContext context) {
    return context.read<FileCubit>();
  }

  static FileCubit watch(BuildContext context) {
    return context.watch<FileCubit>();
  }
}

class FileCubit extends Cubit<FileState> {
  FileCubit() : super(_default);

  static final FileState _default = FileState(image: null, video: null);

  // Function
  void clear() {
    emit(_default);
  }

  void takePhoto(String value) {
    emit(
      FileState(
        image: File(value),
        video: state.video,
      ),
    );
  }

  void takeVideo(String value) {
    emit(
      FileState(
        image: state.image,
        video: File(value),
      ),
    );
  }
}
