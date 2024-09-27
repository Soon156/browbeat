import 'dart:convert';
import 'dart:math';
import 'package:beatbrows/operation_io.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

class WordController {
  late String wordList;
  late Map<String, dynamic> progressionWordList;
  late String defaultWordList;
  late String difficulty;
  late String wordIndex;
  late int wordCounter;
  late int wordCounterAll;
  late int hintCounter;
  late int lastHintTimeStamp;

  Future<void> initialize() async {
    wordLog.info("Initialize Word Controller....");

    // Retrieve difficulty
    difficulty =
        (await ioController.readData('difficulty', 'string') as String?) ??
            'easy';
    wordLog.config('Difficulty : $difficulty');

    // Retrieve last state of game
    wordIndex =
        (await ioController.readData('wordIndex', 'string') as String?) ?? "{}";
    hintCounter =
        (await ioController.readData('hintCounter', 'int') as int?) ?? 3;
    lastHintTimeStamp =
        (await ioController.readData('lastHintTimeStamp', 'int') as int?) ??
            DateTime.now().millisecondsSinceEpoch;
    var tempWord =
        (await ioController.readData('progression', 'string') as String?) ?? '';

    if (tempWord.isEmpty) {
      wordLog.info("Init game: $tempWord");
      progressionWordList = {
        'easy': {
          'word': '',
          'hint': '',
          'hintWord': '',
          'description': '',
        },
        'normal': {
          'word': '',
          'hint': '',
          'hintWord': '',
          'description': '',
        },
        'hard': {
          'word': '',
          'hint': '',
          'hintWord': '',
          'description': '',
        },
      };
    } else {
      wordLog.info("Last state found: $tempWord");
      progressionWordList = jsonDecode(tempWord);
    }

    defaultWordList = await rootBundle.loadString('assets/word.json');

    wordCounterAll =
        jsonDecode(defaultWordList)["categories"][difficulty].length;
    // Retrieve progression
    final userWordList =
        (await ioController.readData('userWordList', 'string') as String?);
    if (userWordList != null) {
      wordLog.config('Last Progression: $userWordList');
      wordList = userWordList;
    } else {
      wordLog.config('New game detected');
      wordList = jsonEncode(jsonDecode(defaultWordList)["categories"]);
      wordCounter = wordCounterAll;
    }
  }

  Map<String, dynamic>? getWordData() {
    final wordData = progressionWordList[difficulty];
    wordCounterAll =
        jsonDecode(defaultWordList)["categories"][difficulty].length;
    wordCounter = jsonDecode(wordList)[difficulty].length;

    if (wordData!['word']!.isEmpty) {
      wordLog.info("'Game difficulty' change or 'New Stage' detected!");
      var random = Random();
      var wordArray = jsonDecode(wordList)[difficulty];
      if (wordArray.isNotEmpty) {
        // Assign hint
        var wordPointer = random.nextInt(wordArray.length);
        var newWordIndex = jsonDecode(wordIndex);
        newWordIndex[difficulty] = wordPointer;
        wordIndex = jsonEncode(newWordIndex);
        ioController.writeData('wordIndex', 'string', wordIndex);

        var wordToHint = wordArray[wordPointer]["word"];

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
          // Assign word
          progressionWordList[difficulty]!['hint'] = charArray.join("");
          progressionWordList[difficulty]!['hintWord'] =
              generateCharacterList(charArray, wordToHint.split(''));
          progressionWordList[difficulty]!['word'] = wordToHint;

          // Assign description
          progressionWordList[difficulty]!['description'] =
              wordArray[wordPointer]["definition"] ?? "";
        }
      } else {
        wordLog.warning("Difficulty beat/wrong word file!");
        progressionWordList[difficulty]!['word'] = "";
        progressionWordList[difficulty]!['description'] = "";
        progressionWordList[difficulty]!['hint'] = "";
        progressionWordList[difficulty]!['hintWord'] = "";
      }
    }
    ioController.writeData(
        'progression', 'string', jsonEncode(progressionWordList));
    wordLog.config("New state: $progressionWordList");
    return progressionWordList[difficulty];
  }

  void removeWord() {
    var wordArray = jsonDecode(wordList);
    var wordPointer = jsonDecode(wordIndex);
    if (wordArray[difficulty].isNotEmpty) {
      var newWordArray = wordArray[difficulty] as List;
      if (newWordArray.isNotEmpty) {
        newWordArray.removeAt(wordPointer[difficulty]);
        wordArray[difficulty] = newWordArray;
        wordList = jsonEncode(wordArray);
        ioController.writeData('userWordList', 'string', wordList);
        progressionWordList[difficulty]!['word'] = "";
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
  minCount = max(2, minCount);
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

String generateCharacterList(List hintWord, List originalWord) {
  List<String> hintChars = [];
  Random random = Random();
  var hintLength = max(hintWord.length, 8);

  for (int i = 0; i < hintWord.length; i++) {
    if (hintWord[i] == '_') {
      hintChars.add(originalWord[i]);
    }
  }

  // Generate random characters from 'a' to 'z'
  while (hintChars.length < hintLength) {
    String randomChar = String.fromCharCode(random.nextInt(26) + 97);
    if (!hintChars.contains(randomChar)) {
      hintChars.add(randomChar);
    }
  }

  return shuffleArray(hintChars).join();
}

final wordLog = Logger("Word Controller");
final wordController = WordController();
