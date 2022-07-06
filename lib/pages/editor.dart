import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:snapchat_story/states/caption/caption_text_cubit.dart';
import 'package:story_creator/story_creator.dart';

class EditorImage extends StatelessWidget {
  const EditorImage({
    Key? key,
    required this.image,
  }) : super(key: key);
  final String image;

  @override
  Widget build(BuildContext context) {
    return StoryCreator(filePath: image);
  }
}

class CaptionTextEditor extends StatefulWidget {
  const CaptionTextEditor({Key? key}) : super(key: key);

  @override
  State<CaptionTextEditor> createState() => _CaptionTextEditorState();
}

class _CaptionTextEditorState extends State<CaptionTextEditor> {
  final textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (textController.text.isNotEmpty) {
          // Update State
          CaptionTextCubitHandle.read(context).updateText(textController.text);
        }

        Navigator.pop(context);
      },
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Color Palete | Weight | Delete
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Color Palete
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            titlePadding: const EdgeInsets.all(0),
                            contentPadding: const EdgeInsets.all(0),
                            content: SingleChildScrollView(
                              child: BlocSelector<CaptionTextCubit,
                                  CaptionTextState, Color>(
                                selector: (state) => state.textColor,
                                builder: (_, state) => ColorPicker(
                                  pickerColor: state,
                                  onColorChanged: (value) {
                                    // Update State
                                    CaptionTextCubitHandle.read(context)
                                        .updateTextColor(value);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.color_lens, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  // Delete
                  IconButton(
                    onPressed: () {
                      // Update State
                      CaptionTextCubitHandle.read(context).clear();
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              // Font Sizer | Textfield
              BlocSelector<CaptionTextCubit, CaptionTextState,
                  CaptionTextState>(
                selector: (state) => state,
                builder: (_, state) => SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Font Size Slider
                      RotatedBox(
                        quarterTurns: 3,
                        child: Slider(
                          min: 8,
                          max: 96,
                          value: state.size.toDouble(),
                          thumbColor: state.textColor,
                          activeColor: state.textColor,
                          inactiveColor: state.textColor.withOpacity(0.5),
                          onChanged: (value) {
                            //  Update State
                            CaptionTextCubitHandle.read(context).updateSize(
                              value,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Textfield
                      Expanded(
                        child: SingleChildScrollView(
                          child: TextField(
                            autofocus: true,
                            controller: textController
                              ..text = (state.text != null) ? state.text! : "",
                            style: TextStyle(
                              color: state.textColor,
                              fontSize: state.size.toDouble(),
                            ),
                            cursorColor: state.textColor,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
