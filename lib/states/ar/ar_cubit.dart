import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera_deep_ar/camera_deep_ar.dart';
import 'package:flutter/material.dart';

part 'ar_state.dart';

class ArCubitHandle {
  static ArCubit read(BuildContext context) {
    return context.read<ArCubit>();
  }

  static ArCubit watch(BuildContext context) {
    return context.watch<ArCubit>();
  }
}

class ArCubit extends Cubit<ArState> {
  ArCubit() : super(_arDefault.call());

  static const DeepArConfig _config = DeepArConfig(
    // Get This Api Key From Site: https://www.deepar.ai/
    androidKey:
        "a8578c2bbd18a18e9045f07f7d87cb3b0c7b1c0b048fcc45eb80f4c5b3e88edefbc2a4b51c94efd0",
    ioskey: "",
    cameraDirection: CameraDirection.front,
    cameraMode: CameraMode.mask,
  );

  static ArState _arDefault() {
    return ArState(
      currentEffect: 0,
      cameraDirection: _config.cameraDirection,
      modeType: _config.cameraMode,
    );
  }

  static CameraDeepArController controller = CameraDeepArController(_config);

  // Function
  void clear() {
    emit(_arDefault.call());
  }

  void changeCameraDirection(CameraDirection value) {
    controller.switchCameraDirection(direction: value);
    emit(
      ArState(
        currentEffect: state.currentEffect,
        cameraDirection: value,
        modeType: state.modeType,
      ),
    );
  }

  void updateEffectMode(CameraMode value) {
    emit(
      ArState(
        currentEffect: state.currentEffect,
        cameraDirection: state.cameraDirection,
        modeType: value,
      ),
    );
  }

  void updateEffect(int value) {
    emit(
      ArState(
        currentEffect: value,
        cameraDirection: state.cameraDirection,
        modeType: state.modeType,
      ),
    );
  }
}
