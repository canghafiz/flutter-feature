import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:giphy_get/giphy_get.dart';

part 'giphy_state.dart';

class GiphyCubitEvent {
  static GiphyCubit read(BuildContext context) {
    return context.read<GiphyCubit>();
  }
}

class GiphyCubit extends Cubit<GiphyState> {
  GiphyCubit() : super(_default);

  static final _default = GiphyState(gif: null, wrapper: null);

  // Function
  void clear() {
    emit(_default);
  }

  void updateGif(GiphyGif value) {
    emit(GiphyState(gif: value, wrapper: state.wrapper));
  }

  void updateWrapper(GiphyGetWrapper value) {
    emit(GiphyState(gif: state.gif, wrapper: value));
  }
}
