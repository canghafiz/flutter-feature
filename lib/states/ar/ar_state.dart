part of 'ar_cubit.dart';

class ArState {
  CameraDirection cameraDirection;
  int currentEffect;
  CameraMode modeType;

  ArState({
    required this.currentEffect,
    required this.cameraDirection,
    required this.modeType,
  });
}
