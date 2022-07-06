import 'package:flutter/material.dart';
import 'package:snapchat_story/navigator.dart';
import 'package:snapchat_story/pages/story_creator.dart';
import 'package:camera_deep_ar/camera_deep_ar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Story Like Snapchat"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            (CameraDeepArController.checkPermissions() as Future<dynamic>)
                .then((value) {
              Navigator.push(
                context,
                NavigationHandle.standard(
                  context: context,
                  screen: const StoryCreatorPage(),
                ),
              );
            });
          },
          child: const Text("Add Story"),
        ),
      ),
    );
  }
}
