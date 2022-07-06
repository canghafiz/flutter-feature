import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:snapchat_story/pages/home.dart';
import 'package:snapchat_story/states/ar/ar_cubit.dart';
import 'package:snapchat_story/states/caption/caption_text_cubit.dart';
import 'package:snapchat_story/states/file/file_cubit.dart';
import 'package:snapchat_story/states/freehand/freehand_cubit.dart';
import 'package:snapchat_story/states/giphy/giphy_cubit.dart';
import 'package:snapchat_story/states/trimmer/video_trimmer_cubit.dart';
import 'package:snapchat_story/states/video/video_recorder_cubit.dart';
import 'package:snapchat_story/states/video_player/video_player_cubit.dart';
import 'package:snapchat_story/states/video_status/video_status_cubit.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<ArCubit>(
          create: (context) => ArCubit(),
        ),
        BlocProvider<FileCubit>(
          create: (context) => FileCubit(),
        ),
        BlocProvider<VideoRecorderCubit>(
          create: (context) => VideoRecorderCubit(),
        ),
        BlocProvider<VideoTrimmerCubit>(
          create: (context) => VideoTrimmerCubit(),
        ),
        BlocProvider<VideoStatusCubit>(
          create: (context) => VideoStatusCubit(),
        ),
        BlocProvider<CaptionTextCubit>(
          create: (context) => CaptionTextCubit(),
        ),
        BlocProvider<FreehandCubit>(
          create: (context) => FreehandCubit(),
        ),
        BlocProvider<VideoPlayerCubit>(
          create: (context) => VideoPlayerCubit(),
        ),
        BlocProvider<GiphyCubit>(
          create: (context) => GiphyCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          unselectedWidgetColor: Colors.white,
        ),
        home: const HomePage(),
      ),
    );
  }
}
