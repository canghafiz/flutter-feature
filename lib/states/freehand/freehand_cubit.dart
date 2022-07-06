import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'freehand_state.dart';

class FreehandCubitHandle {
  static FreehandCubit read(BuildContext context) {
    return context.read<FreehandCubit>();
  }
}

class FreehandCubit extends Cubit<FreehandState> {
  FreehandCubit() : super(_default);

  static final _default = FreehandState(
    color: Colors.blue,
    isActive: false,
    strokeWidth: 3,
  );

  // Function
  void clear() {
    emit(_default);
  }

  void updateActive() {
    emit(FreehandState(
      color: state.color,
      isActive: !state.isActive,
      strokeWidth: state.strokeWidth,
    ));
  }

  void updateColor(Color value) {
    emit(FreehandState(
      color: value,
      isActive: state.isActive,
      strokeWidth: state.strokeWidth,
    ));
  }

  void updateStrokeWidth(double value) {
    emit(FreehandState(
      color: state.color,
      isActive: state.isActive,
      strokeWidth: value,
    ));
  }
}
