import 'dart:convert';
import 'dart:math';
import 'package:beatbrows/operation_io.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

class WordController {
  late String wordList;
  Map<String, dynamic> word = {
    'easy': {
      'word': '',
      'hint': '',
      'description': '',
    },
    'normal': {
      'word': '',
      'hint': '',
      'description': '',
    },
    'hard': {
      'word': '',
      'hint': '',
      'description': '',
    },
  };
  late String difficulty;
  late int wordIndex;

  Future<void> initialize() async {
    wordLog.info("Initialize Word Controller....");

    // Retrieve difficulty
    difficulty =
        (await ioController.readData('difficulty', 'string') as String?) ??
            'easy';
    wordLog.config('Difficulty : $difficulty');

    // Retrieve last state of game
    wordIndex = (await ioController.readData('wordIndex', 'int') as int?) ?? -1;
    var tempWord =
        (await ioController.readData('progression', 'string') as String?) ?? '';

    if (tempWord.isEmpty) {
      wordLog.info("Init game: $tempWord");
      word = {
        'easy': {
          'word': '',
          'hint': '',
          'description': '',
        },
        'normal': {
          'word': '',
          'hint': '',
          'description': '',
        },
        'hard': {
          'word': '',
          'hint': '',
          'description': '',
        },
      };
    } else {
      wordLog.info("Last state found: $tempWord");
      word = jsonDecode(tempWord);
    }

    // Retrieve progression
    final userWordList =
        (await ioController.readData('userWordList', 'string') as String?);
    if (userWordList != null) {
      wordLog.config('Last Progression: $userWordList');
      wordList = userWordList;
    } else {
      final String jsonString = await rootBundle.loadString('assets/word.json');
      var data = jsonDecode(jsonString);
      wordList = jsonEncode(data["categories"]);
      wordLog.config('New game detected');
    }
  }

  Map<String, dynamic>? getWordData() {
    final wordData = word[difficulty];
    if (wordData!['word']!.isEmpty) {
      wordLog.info("'Game difficulty' change or 'New Stage' detected!");
      var random = Random();
      var wordArray = jsonDecode(wordList)[difficulty];
      if (wordArray.isNotEmpty) {
        // Assign hint 
        wordIndex = random.nextInt(wordArray.length);
        ioController.writeData('wordIndex', 'int', wordIndex);
        var wordToHint = wordArray[wordIndex]["word"];

        if (wordToHint.isNotEmpty) {
          List<String> charArray = wordToHint.split('');
          var hintCount = getRandomNumber(wordToHint.length);
          var availableIndex =
              List<int>.generate(wordToHint.length, (index) => index);
          var tempMapping = shuffleArray(availableIndex).sublist(0, hintCount);
          for (var i = 0; i < wordToHint.length; i++) {
            if (tempMapping.contains(i)) {
              charArray[i] = "_";
            }
          }
          word[difficulty]!['hint'] = charArray.join("");

          // Assign word
          word[difficulty]!['word'] = wordToHint;

          // Assign description
          word[difficulty]!['description'] =
              wordArray[wordIndex]["definition"] ?? "";
        }
      } else {
        wordLog.warning("Difficulty beat/wrong word file!");
        word[difficulty]!['word'] = "";
        word[difficulty]!['description'] = "";
        word[difficulty]!['hint'] = "";
      }
    }
    ioController.writeData('progression', 'string', jsonEncode(word));
    wordLog.config("New state: $word");
    return word[difficulty];
  }

  void removeWord() {
    var wordArray = jsonDecode(wordList);
    if (wordArray[difficulty].isNotEmpty) {
      var newWordArray = wordArray[difficulty] as List;
      if (wordIndex >= 0 && wordIndex < newWordArray.length) {
        newWordArray.removeAt(wordIndex);
        wordArray[difficulty] = newWordArray;
        wordList = jsonEncode(wordArray);
        ioController.writeData('userWordList', 'string', wordList);
        word[difficulty]!['word'] = "";
        wordLog.config("New progession: $wordList");
      } else {
        wordLog.shout(
            "Word Remove Failed: $wordIndex \n $difficulty \n $wordArray");
      }
    } else {
      wordLog.shout(
          "Word Remove Failed: Word Array missing!\n $difficulty \n $wordList");
    }
  }
}

int getRandomNumber(int totalWords) {
  int minCount = (totalWords / 4).ceil();
  int maxCount = (totalWords / 2).ceil();
  minCount = max(1, minCount);
  return Random().nextInt(maxCount - minCount + 1) + minCount;
}

List<T> shuffleArray<T>(List<T> array) {
  final random = Random();
  for (int i = array.length - 1; i > 0; i--) {
    int j = random.nextInt(i + 1);
    T temp = array[i];
    array[i] = array[j];
    array[j] = temp;
  }
  return array;
}

final wordLog = Logger("Word Controller");
final wordController = WordController();
