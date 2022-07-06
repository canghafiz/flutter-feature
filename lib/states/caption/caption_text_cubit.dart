import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'caption_text_state.dart';

class CaptionTextCubitHandle {
  static CaptionTextCubit read(BuildContext context) {
    return context.read<CaptionTextCubit>();
  }
}

class CaptionTextCubit extends Cubit<CaptionTextState> {
  CaptionTextCubit() : super(_default);

  static final _default = CaptionTextState(
    positionX: 0,
    positionY: 0,
    size: 48,
    text: null,
    textColor: Colors.white,
  );

  // Function
  void clear() {
    emit(_default);
  }

  void updatePosition({required double? x, required double? y}) {
    emit(CaptionTextState(
      positionX: x ?? state.positionX,
      positionY: y ?? state.positionY,
      size: state.size,
      text: state.text,
      textColor: state.textColor,
    ));
  }

  void updateSize(double value) {
    emit(CaptionTextState(
      positionX: state.positionX,
      positionY: state.positionY,
      size: value,
      text: state.text,
      textColor: state.textColor,
    ));
  }

  void updateText(String value) {
    emit(CaptionTextState(
      positionX: state.positionX,
      positionY: state.positionY,
      size: state.size,
      text: value,
      textColor: state.textColor,
    ));
  }

  void updateTextColor(Color value) {
    emit(CaptionTextState(
      positionX: state.positionX,
      positionY: state.positionY,
      size: state.size,
      text: state.text,
      textColor: value,
    ));
  }
}
