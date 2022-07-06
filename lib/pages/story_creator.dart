import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera_deep_ar/camera_deep_ar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:screenshot/screenshot.dart';
import 'package:scribble/scribble.dart';
import 'package:snapchat_story/models/effect.dart';
import 'package:snapchat_story/models/filter.dart';
import 'package:snapchat_story/navigator.dart';
import 'package:snapchat_story/pages/editor.dart';
import 'package:snapchat_story/pages/video_trim.dart';
import 'package:snapchat_story/services/video_filter.dart';
import 'package:snapchat_story/states/ar/ar_cubit.dart';
import 'package:snapchat_story/states/caption/caption_text_cubit.dart';
import 'package:snapchat_story/states/file/file_cubit.dart';
import 'package:snapchat_story/states/freehand/freehand_cubit.dart';
import 'package:snapchat_story/states/giphy/giphy_cubit.dart';
import 'package:snapchat_story/states/video/video_recorder_cubit.dart';
import 'package:snapchat_story/states/video_player/video_player_cubit.dart';
import 'package:snapchat_story/states/video_status/video_status_cubit.dart';
import 'package:snapchat_story/widget/icon_button.dart';
import 'package:video_player/video_player.dart';
import 'package:dart_now_time_filename/dart_now_time_filename.dart';

void deleteFile(File file) {
  file.exists().then(
    (there) {
      if (there) {
        file.delete();
      }
    },
  );
}

Future<void> saveImageToLocal(Uint8List? image) async {
  if (image != null) {
    final fileName = NowFilename.gen(prefix: 'photo-', ext: '.png');
    File imgFile = File("/storage/emulated/0/$fileName");
    imgFile.writeAsBytes(image);
  }
}

void saveVideoToLocal(String path) {
  GallerySaver.saveVideo(path);
}

class StoryCreatorPage extends StatefulWidget {
  const StoryCreatorPage({Key? key}) : super(key: key);

  @override
  State<StoryCreatorPage> createState() => _StoryCreatorPageState();
}

class _StoryCreatorPageState extends State<StoryCreatorPage> {
  final ScreenshotController controller = ScreenshotController();
  final ScribbleNotifier scribbleNotifier = ScribbleNotifier();
  final picker = ImagePicker();
  late FreehandCubit freehandCubit;
  late StreamSubscription freehandStream;

  @override
  void initState() {
    super.initState();
    // Update State
    ArCubitHandle.read(context).clear();
    FileCubitHandle.read(context).clear();
    VideoRecorderCubitHandle.read(context).clear();
    VideoStatusCubitHandle.read(context).clear();
    GiphyCubitEvent.read(context).clear();

    // Set Freehand
    freehandCubit = FreehandCubitHandle.read(context);
    freehandStream = freehandCubit.stream.listen((state) {
      scribbleNotifier.setColor(state.color);
      scribbleNotifier.setStrokeWidth(state.strokeWidth);
    });

    // Event Handler
    ArCubit.controller.setEventHandler(
      DeepArEventHandler(
        onSnapPhotoCompleted: (file) async {
          // Navigate
          toEditor(file).then(
            (value) => // Update State
                FileCubitHandle.read(context).takePhoto(value.path),
          );
        },
        onVideoRecordingComplete: (file) {
          // Navigate
          Navigator.push(
            context,
            NavigationHandle.standard(
              context: context,
              screen: VideoTrimPage(
                file: File(file),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    freehandStream.cancel();
  }

  Future<File> toEditor(String path) async {
    File editedFile = await Navigator.of(context).push(
      NavigationHandle.standard(
        context: context,
        screen: EditorImage(image: path),
      ),
    );

    return editedFile;
  }

  void startRecordVideo() {
    // Call Controller
    ArCubit.controller.startVideoRecording();
    // Update State
    VideoRecorderCubitHandle.read(context).startTime();
  }

  void stopRecordVideo() {
    // Call Controller
    ArCubit.controller.stopVideoRecording();
    // Update State
    VideoRecorderCubitHandle.read(context).reset();
  }

  void showCaptionTextEditor() {
    showDialog(context: context, builder: (_) => const CaptionTextEditor());
  }

  @override
  Widget build(BuildContext context) {
    return GiphyGetWrapper(
      // Get This Api Key From Site: https://developers.giphy.com/
      giphy_api_key: "LHTMvpoYL5UHqVuFJ6mgOA382A45PQ9O",
      builder: (stream, giphy) => Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // View
            BlocSelector<FileCubit, FileState, FileState>(
              selector: (state) => state,
              builder: (_, state) {
                return (state.image != null)
                    ? StoryImageViewWidget(
                        image: state.image!,
                        controller: controller,
                        scribbleNotifier: scribbleNotifier,
                      )
                    : (state.video != null)
                        ? const DraggableText(content: StoryVideoViewWidget())
                        : DeepArPreview(ArCubit.controller);
              },
            ),
            // Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24 + 16,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: BlocSelector<FileCubit, FileState, FileState>(
                  selector: (state) => state,
                  builder: (_, state) =>
                      BlocSelector<FreehandCubit, FreehandState, FreehandState>(
                    selector: (state) => state,
                    builder: (_, freehandState) => (freehandState.isActive)
                        ? FreehandButton(scribbleNotifier: scribbleNotifier)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Cancel
                              iconButton(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  iconData: Icons.clear),
                              // Gallery
                              BlocSelector<VideoRecorderCubit,
                                  VideoRecorderState, Duration>(
                                selector: (state) => state.duration,
                                builder: (_, duration) {
                                  String twoDigits(int n) =>
                                      n.toString().padLeft(2, '0');
                                  final minutes = twoDigits(
                                      duration.inMinutes.remainder(60));
                                  final seconds = twoDigits(
                                      duration.inSeconds.remainder(60));
                                  return (duration.inSeconds > 0)
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                          child: Text(
                                            "$minutes:$seconds",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        )
                                      : (state.video == null &&
                                              state.image == null)
                                          ? iconButton(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  backgroundColor: Colors.white,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(20),
                                                      topRight:
                                                          Radius.circular(20),
                                                    ),
                                                  ),
                                                  context: context,
                                                  builder: (_) => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        title:
                                                            const Text("Photo"),
                                                        trailing: const Icon(Icons
                                                            .arrow_forward_ios),
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    20),
                                                            topRight:
                                                                Radius.circular(
                                                                    20),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          picker
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .gallery)
                                                              .then(
                                                            (file) {
                                                              if (file !=
                                                                  null) {
                                                                toEditor(file
                                                                        .path)
                                                                    .then(
                                                                  (value) => // Update State
                                                                      FileCubitHandle.read(
                                                                              context)
                                                                          .takePhoto(
                                                                              value.path),
                                                                );
                                                              }
                                                            },
                                                          );
                                                        },
                                                      ),
                                                      ListTile(
                                                        title:
                                                            const Text("Video"),
                                                        trailing: const Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                          picker
                                                              .pickVideo(
                                                            source: ImageSource
                                                                .gallery,
                                                          )
                                                              .then(
                                                            (file) {
                                                              if (file !=
                                                                  null) {
                                                                // Navigate
                                                                Navigator.push(
                                                                  context,
                                                                  NavigationHandle
                                                                      .standard(
                                                                    context:
                                                                        context,
                                                                    screen:
                                                                        VideoTrimPage(
                                                                      file: File(
                                                                          file.path),
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              iconData: Icons.wallpaper,
                                            )
                                          : (state.video != null)
                                              ? iconButton(
                                                  onTap: () {
                                                    showCaptionTextEditor();
                                                  },
                                                  iconData: Icons.font_download,
                                                )
                                              : iconButton(
                                                  onTap: () {
                                                    // Update State
                                                    FreehandCubitHandle.read(
                                                            context)
                                                        .updateActive();
                                                  },
                                                  iconData: Icons.edit);
                                },
                              ),
                              // Gif
                              StreamBuilder<GiphyGif>(
                                  stream: stream,
                                  builder: (_, snapshot) {
                                    if (!snapshot.hasData) {
                                      return iconButton(
                                        onTap: () {
                                          if (state.image == null) {
                                            // show Snackbar
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "There's no content here"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          // Open Giphy
                                          giphy.getGif("", context);
                                        },
                                        iconData: Icons.emoji_emotions,
                                      );
                                    } else {
                                      SchedulerBinding.instance!
                                          .addPostFrameCallback((_) {
                                        // Update State
                                        GiphyCubitEvent.read(context)
                                            .updateGif(snapshot.data!);
                                        GiphyCubitEvent.read(context)
                                            .updateWrapper(giphy);
                                      });

                                      return BlocSelector<GiphyCubit,
                                          GiphyState, GiphyGif?>(
                                        selector: (state) => state.gif,
                                        builder: (_, gifState) => (gifState ==
                                                null)
                                            ? iconButton(
                                                onTap: () {
                                                  if (state.image == null) {
                                                    // show Snackbar
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "There's no content here"),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  // Open Giphy
                                                  giphy.getGif("", context);
                                                },
                                                iconData: Icons.emoji_emotions,
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  // Update State
                                                  GiphyCubitEvent.read(context)
                                                      .clear();
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(5),
                                                    ),
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                  ),
                                                  child: const Text(
                                                    "Clear Gif",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )),
                                      );
                                    }
                                  }),
                              // Switch
                              (state.image != null || state.video != null)
                                  ? iconButton(
                                      onTap: () {
                                        // Delete File
                                        if (state.image != null) {
                                          deleteFile(state.image!);
                                        } else if (state.video != null) {
                                          deleteFile(state.video!);
                                        }
                                        // Update State
                                        FileCubitHandle.read(context).clear();
                                      },
                                      iconData: Icons.delete)
                                  : BlocSelector<ArCubit, ArState,
                                      CameraDirection>(
                                      selector: (state) =>
                                          state.cameraDirection,
                                      builder: (context, state) => iconButton(
                                          onTap: () {
                                            if (state ==
                                                CameraDirection.front) {
                                              // Update State
                                              ArCubitHandle.read(context)
                                                  .changeCameraDirection(
                                                      CameraDirection.back);
                                              return;
                                            }
                                            // Update State
                                            ArCubitHandle.read(context)
                                                .changeCameraDirection(
                                                    CameraDirection.front);
                                          },
                                          iconData:
                                              Icons.cameraswitch_outlined),
                                    ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            // Effects
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: BlocSelector<FileCubit, FileState, FileState>(
                  selector: (state) => state,
                  builder: (_, state) =>
                      (state.image == null && state.video == null)
                          ? _effectWidget(context)
                          : _buttonEditorWidget(
                              context: context,
                              controller: controller,
                            ),
                ),
              ),
            ),
            // Button Capture
            BlocSelector<FileCubit, FileState, FileState>(
              selector: (state) => state,
              builder: (_, state) => (state.image == null &&
                      state.video == null)
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 64),
                        child: BlocSelector<VideoRecorderCubit,
                            VideoRecorderState, Duration>(
                          selector: (state) => state.duration,
                          builder: (_, duration) => GestureDetector(
                            onTap: () {
                              if (duration.inSeconds > 0) {
                                stopRecordVideo();
                                return;
                              }
                              ArCubit.controller.snapPhoto();
                            },
                            onLongPress: () {
                              if (duration.inSeconds == 0) {
                                startRecordVideo();
                                return;
                              }
                              stopRecordVideo();
                            },
                            child: BlocSelector<VideoRecorderCubit,
                                VideoRecorderState, Duration>(
                              selector: (state) => state.duration,
                              builder: (_, duration) => Container(
                                width: 74,
                                height: 74,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 6,
                                  ),
                                ),
                                child: (duration.inSeconds > 0)
                                    ? Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
            // Video Status
            Align(
              alignment: Alignment.bottomCenter,
              child: BlocSelector<VideoStatusCubit, VideoStatus, VideoStatus>(
                selector: (state) => state,
                builder: (_, status) => (status == VideoStatus.onLoading)
                    ? Container(
                        width: double.infinity,
                        height: 56,
                        color: Colors.blue,
                        child: const Center(
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buttonEditorWidget({
  required BuildContext context,
  required ScreenshotController controller,
}) {
  final FileState state = FileCubitHandle.read(context).state;
  // Filters
  List<Filter> filters = Filter.filters(state.image);
  // Update State
  ArCubitHandle.read(context).updateEffect(0);

  // Function
  void playVideo() {
    // Call Controller
    VideoPlayerCubitHandle.read(context).play();
    // Update State
    VideoRecorderCubitHandle.read(context).updatePlaying(true);
  }

  void pauseVideo() {
    // Call Controller
    VideoPlayerCubitHandle.read(context).pause();
    // Update State
    VideoRecorderCubitHandle.read(context).updatePlaying(false);
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Filters
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(
            filters.length,
            (index) {
              final Filter filter = filters[index];

              return GestureDetector(
                onTap: () {
                  // Update State
                  ArCubitHandle.read(context).updateEffect(index);
                },
                child: BlocSelector<ArCubit, ArState, int>(
                  selector: (state) => state.currentEffect,
                  builder: (_, currentEffect) => Container(
                    margin: EdgeInsets.only(
                      left: 8,
                      right: (index == filters.length - 1) ? 8 : 0,
                    ),
                    width: (currentEffect == index) ? 64 : 48,
                    height: (currentEffect == index) ? 64 : 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: (filter.color == Colors.black)
                            ? Colors.white
                            : Colors.black,
                        width: (currentEffect == index) ? 6 : 1,
                      ),
                      image: (filter.img == null)
                          ? null
                          : DecorationImage(
                              image: FileImage(filter.img!),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (index == 0)
                            ? Colors.white
                            : filter.color!
                                .withOpacity((state.image == null) ? 1 : 0.7),
                      ),
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
      const SizedBox(height: 24),
      // Button
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Save
            BlocSelector<ArCubit, ArState, int>(
              selector: (state) => state.currentEffect,
              builder: (_, currentEffect) => BlocSelector<CaptionTextCubit,
                  CaptionTextState, CaptionTextState>(
                selector: (state) => state,
                builder: (_, captionState) => (state.image != null)
                    ? GestureDetector(
                        onTap: () {
                          // Save Image
                          controller.capture().then(
                            (image) {
                              saveImageToLocal(image).then(
                                (_) =>
                                    // Show Snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Success Save"),
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.file_download,
                              color: Colors.white,
                            ),
                            Text(
                              "Save",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : (currentEffect > 0 || captionState.text != null)
                        ? GestureDetector(
                            onTap: () {
                              // Save Video
                              VideoFilter.filterFromColor(
                                color: (currentEffect < 1)
                                    ? null
                                    : Filter.filters(null)[currentEffect]
                                        .color!,
                                video: state.video!,
                                captionState: captionState,
                                onLoading: () {
                                  // Update State
                                  VideoStatusCubitHandle.read(context)
                                      .update(VideoStatus.onLoading);
                                },
                                onSuccess: () {
                                  // Update State
                                  VideoStatusCubitHandle.read(context)
                                      .update(VideoStatus.ondone);
                                },
                                onError: () {
                                  // Update State
                                  VideoStatusCubitHandle.read(context)
                                      .update(VideoStatus.ondone);
                                },
                                saveTo: (path) {
                                  saveVideoToLocal(path);
                                },
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.file_download,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),
              ),
            ),
            // Video Control
            (state.video != null)
                ? BlocSelector<VideoRecorderCubit, VideoRecorderState, bool>(
                    selector: (state) => state.isPlaying,
                    builder: (_, isPlaying) => iconButton(
                      onTap: () {
                        if (isPlaying) {
                          pauseVideo();
                          return;
                        }
                        playVideo();
                      },
                      iconData: (isPlaying) ? Icons.pause : Icons.play_arrow,
                    ),
                  )
                : const SizedBox(),
            // Upload
            ElevatedButton(
              onPressed: () {},
              child: const Text("Send to story"),
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                primary: Colors.white,
                onPrimary: Colors.black,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _effectWidget(BuildContext context) {
  // Update State
  ArCubitHandle.read(context).clear();

  Widget btnModeType({
    required CameraMode mode,
    required CameraMode modeState,
  }) {
    return GestureDetector(
      onTap: () {
        // Update State
        ArCubitHandle.read(context).updateEffectMode(mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color:
              (mode == modeState) ? Colors.blue : Colors.blue.withOpacity(0.5),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(
          (mode == CameraMode.mask) ? "Effect" : "Filter",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  return BlocSelector<ArCubit, ArState, CameraMode>(
    selector: (state) => state.modeType,
    builder: (_, mode) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Effects | Filters
        CarouselSlider.builder(
          itemCount: (mode == CameraMode.mask)
              ? Effect.effects.length
              : Effect.filters.length,
          itemBuilder: (context, index, _) {
            final Effect effect = (mode == CameraMode.mask)
                ? Effect.effects[index]
                : Effect.filters[index];
            return Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                image: (index == 0)
                    ? null
                    : DecorationImage(
                        image: AssetImage(effect.img),
                      ),
              ),
            );
          },
          options: CarouselOptions(
            viewportFraction: 0.2,
            height: 64,
            enlargeCenterPage: true,
            scrollPhysics: const BouncingScrollPhysics(),
            onPageChanged: (index, _) {
              // Update Effect
              ArCubit.controller.switchEffect(
                mode,
                (mode == CameraMode.mask)
                    ? Effect.effects[index].path
                    : Effect.filters[index].path,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Btn ModeType
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Effect
            btnModeType(mode: CameraMode.mask, modeState: mode),
            const SizedBox(width: 8),
            // Filter
            btnModeType(mode: CameraMode.filter, modeState: mode),
          ],
        ),
      ],
    ),
  );
}

// Image
class StoryImageViewWidget extends StatelessWidget {
  const StoryImageViewWidget({
    Key? key,
    required this.image,
    required this.controller,
    required this.scribbleNotifier,
  }) : super(key: key);
  final File image;
  final ScreenshotController controller;
  final ScribbleNotifier scribbleNotifier;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Screenshot(
        controller: controller,
        child: Stack(
          children: [
            // Image
            BlocSelector<ArCubit, ArState, int>(
              selector: (state) => state.currentEffect,
              builder: (_, currentEffect) => (currentEffect == 0)
                  ? Image.file(image)
                  : ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Filter.filters(image)[currentEffect].color!,
                        BlendMode.color,
                      ),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            // Freehand
            Freehand(scribbleNotifier: scribbleNotifier),
            // Gif
            const GifWidget(),
          ],
        ),
      ),
    );
  }
}

// Video
class StoryVideoViewWidget extends StatefulWidget {
  const StoryVideoViewWidget({Key? key}) : super(key: key);

  @override
  State<StoryVideoViewWidget> createState() => _StoryVideoViewWidgetState();
}

class _StoryVideoViewWidgetState extends State<StoryVideoViewWidget> {
  void play() {
    // Call Controller
    VideoPlayerCubitHandle.read(context).play();
    // Update State
    VideoRecorderCubitHandle.read(context).updatePlaying(true);
    CaptionTextCubitHandle.read(context).clear();
  }

  @override
  void initState() {
    super.initState();
    final state = FileCubitHandle.read(context).state;
    VideoPlayerCubitHandle.read(context).initialize(state.video!);
    play();
  }

  @override
  void dispose() {
    super.dispose();
    VideoPlayerCubitHandle.read(context).dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocSelector<VideoPlayerCubit, VideoPlayerController?,
          VideoPlayerController?>(
        selector: (state) => state,
        builder: (_, state) => FutureBuilder(
          future: state!.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return BlocSelector<ArCubit, ArState, int>(
                  selector: (state) => state.currentEffect,
                  builder: (_, currentEffect) {
                    Widget aspectRatio() {
                      return AspectRatio(
                        aspectRatio: state.value.aspectRatio,
                        child: VideoPlayer(state),
                      );
                    }

                    return (currentEffect == 0)
                        ? aspectRatio()
                        : ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Filter.filters(null)[currentEffect].color!,
                              BlendMode.color,
                            ),
                            child: aspectRatio(),
                          );
                  });
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

// Draggable Text
class DraggableText extends StatefulWidget {
  const DraggableText({
    Key? key,
    required this.content,
  }) : super(key: key);
  final Widget content;

  @override
  State<DraggableText> createState() => _DraggableTextState();
}

class _DraggableTextState extends State<DraggableText> {
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.content,
        //  Draggable Text
        BlocSelector<CaptionTextCubit, CaptionTextState, CaptionTextState>(
          selector: (state) => state,
          builder: (_, state) => (state.text == null)
              ? const SizedBox()
              : BlocSelector<VideoPlayerCubit, VideoPlayerController?,
                  VideoPlayerController?>(
                  selector: (state) => state,
                  builder: (_, videoPlayer) => Positioned(
                    left: offset.dx,
                    top: offset.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          offset = Offset(
                            offset.dx + details.delta.dx,
                            offset.dy + details.delta.dy,
                          );

                          // Update State
                          CaptionTextCubitHandle.read(context).updatePosition(
                            x: offset.dx + details.delta.dx,
                            y: offset.dy + details.delta.dy,
                          );
                        });
                      },
                      child: SizedBox(
                        width: videoPlayer!.value.size.width,
                        height: videoPlayer.value.size.height,
                        child: Text(
                          state.text!,
                          style: TextStyle(
                            color: state.textColor,
                            fontSize: state.size.toDouble(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// Freehand
class Freehand extends StatelessWidget {
  const Freehand({
    Key? key,
    required this.scribbleNotifier,
  }) : super(key: key);
  final ScribbleNotifier scribbleNotifier;

  @override
  Widget build(BuildContext context) {
    return Scribble(notifier: scribbleNotifier, drawPen: true);
  }
}

// Freehand Button
class FreehandButton extends StatelessWidget {
  const FreehandButton({Key? key, required this.scribbleNotifier})
      : super(key: key);
  final ScribbleNotifier scribbleNotifier;

  @override
  Widget build(BuildContext context) {
    Widget _buttonBuild({
      required String? text,
      required Color? color,
      required Widget? widget,
      required Function onTap,
    }) {
      return GestureDetector(
        onTap: () => onTap(),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            ),
            color: color ?? Colors.black.withOpacity(0.5),
          ),
          child: widget ??
              Text(
                text ?? "",
                style: const TextStyle(color: Colors.white),
              ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Undo
            (scribbleNotifier.canUndo)
                ? _buttonBuild(
                    onTap: () {
                      scribbleNotifier.undo();
                    },
                    text: "Undo",
                    color: null,
                    widget: null)
                : const SizedBox(width: 32),
            // Pen
            BlocSelector<FreehandCubit, FreehandState, Color>(
              selector: (state) => state.color,
              builder: (_, color) => _buttonBuild(
                onTap: () {
                  // Update State
                  FreehandCubitHandle.read(context).updateActive();
                },
                text: null,
                color: color,
                widget: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
            // Color
            iconButton(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titlePadding: const EdgeInsets.all(0),
                        contentPadding: const EdgeInsets.all(0),
                        content: SingleChildScrollView(
                          child:
                              BlocSelector<FreehandCubit, FreehandState, Color>(
                            selector: (state) => state.color,
                            builder: (_, state) => ColorPicker(
                              pickerColor: state,
                              onColorChanged: (value) {
                                // Update State
                                FreehandCubitHandle.read(context)
                                    .updateColor(value);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                iconData: Icons.color_lens),
            // Clear
            _buttonBuild(
                onTap: () {
                  scribbleNotifier.clear();

                  // Update State
                  FreehandCubitHandle.read(context).clear();
                },
                text: "Clear",
                color: null,
                widget: null),
          ],
        ),
        const SizedBox(height: 12),
        //  Stroke Controller
        BlocSelector<FreehandCubit, FreehandState, FreehandState>(
          selector: (state) => state,
          builder: (_, state) => Slider(
            min: 1,
            max: 20,
            value: state.strokeWidth,
            activeColor: state.color,
            thumbColor: state.color,
            inactiveColor: state.color.withOpacity(0.5),
            onChanged: (value) {
              //  Update State
              FreehandCubitHandle.read(context).updateStrokeWidth(value);

              scribbleNotifier.setStrokeWidth(value);
            },
          ),
        ),
      ],
    );
  }
}

// Gif
class GifWidget extends StatelessWidget {
  const GifWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GiphyCubit, GiphyState, GiphyState>(
      selector: (state) => state,
      builder: (_, state) => (state.gif == null)
          ? const SizedBox()
          : DraggableWidget(
              content: GiphyGifWidget(
                showGiphyLabel: false,
                imageAlignment: Alignment.center,
                gif: state.gif!,
                giphyGetWrapper: state.wrapper!,
              ),
            ),
    );
  }
}

// Draggable Widget
class DraggableWidget extends StatelessWidget {
  const DraggableWidget({
    Key? key,
    required this.content,
  }) : super(key: key);
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        notifier.value = m;
      },
      child: AnimatedBuilder(
        animation: notifier,
        builder: (_, __) => Transform(
          transform: notifier.value,
          child: content,
        ),
      ),
    );
  }
}
