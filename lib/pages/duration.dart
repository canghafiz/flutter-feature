import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapchat_story/navigator.dart';
import 'package:snapchat_story/pages/video_trim.dart';
import 'package:snapchat_story/states/trimmer/video_trimmer_cubit.dart';

class ChooseDuration extends StatefulWidget {
  const ChooseDuration({
    Key? key,
    required this.indexDuration,
    required this.video,
  }) : super(key: key);
  final int indexDuration;
  final File video;

  @override
  State<ChooseDuration> createState() => _ChooseDurationState();
}

class _ChooseDurationState extends State<ChooseDuration> {
  final minuteController = TextEditingController();
  final secondController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Update State
    VideoTrimmerCubitHandle.read(context)
        .udpateSelectedDuration(widget.indexDuration);
    minuteController.addListener(() {
      if (minuteController.text.isNotEmpty) {
        // Update State
        VideoTrimmerCubitHandle.read(context).updateMinute(
          int.parse(minuteController.text),
        );
      }
    });
    secondController.addListener(() {
      if (secondController.text.isNotEmpty) {
        // Update State
        VideoTrimmerCubitHandle.read(context).updateSecond(
          int.parse(secondController.text),
        );
      }
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final state = BlocProvider.of<VideoTrimmerCubit>(context).state;
  //   if (state.selectedDuration == -1 &&
  //       state.minute == null &&
  //       state.second == null &&
  //       state.allDuration == null) {
  //     // Update State
  //     VideoTrimmerCubitHandle.read(context).udpateSelectedDuration(0);
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    minuteController.clear();
    minuteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Choose Story Duration",
            style: TextStyle(color: Colors.white),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                // Navigate
                Navigator.pushReplacement(
                  context,
                  NavigationHandle.standard(
                    context: context,
                    screen: VideoTrimPage(file: widget.video),
                  ),
                );
              },
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 24),
              // By Second
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        "By Second",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      // Seconds
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                            VideoTrimmerCubit.durations.length, (index) {
                          final int duration =
                              VideoTrimmerCubit.durations[index];
                          return GestureDetector(
                            onTap: () {
                              // Update State
                              VideoTrimmerCubitHandle.read(context)
                                  .udpateSelectedDuration(index);
                            },
                            child: Center(
                              child: BlocSelector<VideoTrimmerCubit,
                                  VideoTrimmerState, int>(
                                selector: (state) => state.selectedDuration,
                                builder: (_, selectedDuration) =>
                                    Text("$duration",
                                        style: TextStyle(
                                          fontSize: (index == selectedDuration)
                                              ? 24
                                              : 16,
                                          color: Colors.white,
                                        )),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // By Input
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        "By Input",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      // Inputs
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Minute
                          Expanded(
                            child: textField(
                              controller: minuteController,
                              label: "Minute",
                              inputType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Second
                          Expanded(
                            child: textField(
                              controller: secondController,
                              label: "Second",
                              inputType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Keep All Duration
              BlocSelector<VideoTrimmerCubit, VideoTrimmerState, int?>(
                selector: (state) => state.allDuration,
                builder: (_, allDuration) => CheckboxListTile(
                  value: allDuration != null,
                  onChanged: (_) {
                    if (allDuration == null) {
                      // Update State
                      VideoTrimmerCubitHandle.read(context).allDuration(
                        0,
                      );
                      return;
                    }
                    // Update State
                    VideoTrimmerCubitHandle.read(context).allDuration(null);
                  },
                  title: const Text(
                    "Keep all duration",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Btn Clear
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    // Update State
                    VideoTrimmerCubitHandle.read(context).clearDuration();
                  },
                  child: const Text("Clear"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    maximumSize: const Size(double.infinity, 48),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget textField({
  required TextEditingController controller,
  required String label,
  required TextInputType inputType,
}) {
  return TextField(
    controller: controller,
    keyboardType: inputType,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white,
          width: 3,
        ),
      ),
    ),
  );
}
