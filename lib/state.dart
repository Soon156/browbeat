import 'package:browbeat/music.dart';
import 'package:browbeat/operation_io.dart';
import 'package:browbeat/word.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:rxdart/subjects.dart';

class LiveTimestamp {
  final BehaviorSubject<int> _subject = BehaviorSubject<int>();
  Stream<int> get timestampStream => _subject.stream;
  Timer? _timer;

  LiveTimestamp() {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_subject.isClosed) {
        _subject.add(DateTime.now().millisecondsSinceEpoch);
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _subject.close();
  }
}

class AppState extends ChangeNotifier {
  void switchMusic() {
    audioController.switchState();
    notifyListeners();
  }

  Future<void> refreshState() async {
    audioController.dispose();
    await ioController.resetData();
    await ioController.initialize();
    await audioController.initialize();
    await wordController.initialize();
    notifyListeners();
  }

  void setDifficulty(String diff) {
    wordController.difficulty = diff;
    ioController.writeData('difficulty', 'string', diff);
    notifyListeners();
  }
}

// Reference only
class AppColorScheme {
  final colorScheme = {
    "primary": Color.fromRGBO(231, 204, 204, 1),
    "secondary": Color.fromRGBO(237, 232, 220, 1),
    "third": Color.fromRGBO(165, 182, 141, 1),
    "fourth": Color.fromRGBO(193, 207, 161, 1),
    "easy": Color.fromARGB(255, 33, 163, 105),
    "normal": Color.fromARGB(255, 226, 229, 51),
    "hard": Color.fromARGB(255, 223, 28, 44),
    "unselected": Color.fromARGB(255, 130, 122, 122),
  };

  Color? getColorSheme(String type) {
    final color = colorScheme[type];
    return color;
  }
}

var appColorScheme = AppColorScheme();

class WordState {
  String character;
  String hintIndex;
  String inputIndex;

  WordState(this.character, this.hintIndex, this.inputIndex);
}

const int hintInterval = 3; // minutes
const int minWidth = 350;