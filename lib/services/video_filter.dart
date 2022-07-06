import 'dart:io';

import 'package:dart_now_time_filename/dart_now_time_filename.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapchat_story/states/caption/caption_text_cubit.dart';
import 'package:tapioca/tapioca.dart';

class VideoFilter {
  static void filterFromColor({
    required Color? color,
    required File video,
    required Function onLoading,
    required Function onSuccess,
    required Function onError,
    required CaptionTextState captionState,
    required Function(String) saveTo,
  }) {
    final fileName = NowFilename.gen(prefix: 'video-', ext: '.mp4');
    final localPath = "/storage/emulated/0/$fileName";
    try {
      onLoading.call();
      final tapiocaBalls = (captionState.text != null && color != null)
          ? [
              TapiocaBall.filterFromColor(color),
              TapiocaBall.textOverlay(
                captionState.text!,
                captionState.positionX.toInt() + 56,
                captionState.positionY.toInt() - 128,
                captionState.size.toInt() + 72,
                captionState.textColor,
              )
            ]
          : (captionState.text != null && color == null)
              ? [
                  TapiocaBall.textOverlay(
                    captionState.text!,
                    captionState.positionX.toInt() + 56,
                    captionState.positionY.toInt() - 128,
                    captionState.size.toInt() + 72,
                    captionState.textColor,
                  )
                ]
              : [
                  TapiocaBall.filterFromColor(color!),
                ];
      final cup = Cup(Content(video.path), tapiocaBalls);
      cup.suckUp(localPath).then((_) async {
        saveTo.call(localPath);
        onSuccess.call();
        return;
      });
    } on PlatformException {
      debugPrint("error!!!!");
      onError.call();
    }
  }
}
