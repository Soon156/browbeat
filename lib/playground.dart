import 'dart:math';
import 'package:browbeat/music.dart';
import 'package:browbeat/operation_io.dart';
import 'package:browbeat/state.dart';
import 'package:browbeat/word.dart';
import 'package:flutter/material.dart';

class PlayGround extends StatefulWidget {
  @override
  State<PlayGround> createState() => _PlayGroundState();
}

class _PlayGroundState extends State<PlayGround> {
  late LiveTimestamp liveTimestamp;
  DateTime timsStamp = DateTime.now();
  var state = "";
  bool clickable = true;
  var wordData = wordController.getWordData()!;
  List<WordState> inputData = [];
  List<int> inputIndex = [];
  List<int> hintIndex = [];
  List<Color?> selectedHint = [];
  List newData = [];
  List hintWord = [];
  List<Color?> colorList = [];

  @override
  void initState() {
    liveTimestamp = LiveTimestamp();
    super.initState();
  }

  @override
  void dispose() {
    liveTimestamp.dispose();
    super.dispose();
  }

  Map<String, String> getHint() {
    var originalWord = wordData['word'];
    var charToHint = [];
    int randomIndex = -1;
    for (int i = 0; i < newData.length; i++) {
      if (inputData[i].character == "_") {
        charToHint.add([originalWord[i], i.toString()]);
      }
    }
    if (charToHint.isNotEmpty) {
      Random random = Random();
      randomIndex = random.nextInt(charToHint.length);
    }
    if (randomIndex != -1) {
      return {
        "hintChar": charToHint[randomIndex][0],
        "randomIndex": charToHint[randomIndex][1]
      };
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    newData = wordData['hint'].toString().toUpperCase().split('');
    hintWord = wordData['hintWord'].toString().toUpperCase().split('');

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
      fontSize: 20,
    );

    List<Widget> inputCard = [];
    for (int i = 0; i < newData.length; i++) {
      colorList.add(appColorScheme.getColorSheme("fourth"));
      if (inputData.length < newData.length) {
        inputData.add(WordState(newData[i], "", ""));
      }
      if (inputData[i].character == "_") {
        colorList[i] = appColorScheme.getColorSheme("third");
      }

      inputCard.add(DragTarget(
        builder: (context, candidateItems, rejectedItems) {
          return Card(
            color: colorList[i],
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                audioController.playClickSound();
                if (inputData[i].inputIndex != "" && clickable) {
                  clickable = false;
                  var index = int.parse(inputData[i].inputIndex);
                  setState(() {
                    inputIndex.remove(index);
                    hintIndex.remove(index);
                    inputData[i] = WordState("_", "", "");
                  });
                  clickable = true;
                }
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 50,
                  minWidth: 30,
                ),
                child:
                    Center(child: Text(inputData[i].character, style: style)),
              ),
            ),
          );
        },
        onAcceptWithDetails: (details) {
          Map<String, dynamic>? data = details.data as Map<String, dynamic>;
          setState(() {
            var index = int.parse(data["inputIndex"]);
            if (inputData[i].character == "_" && !hintIndex.contains(index)) {
              inputData[i].character = data["hintWord"];
              inputData[i].hintIndex = i.toString();
              inputData[i].inputIndex = index.toString();
              hintIndex.add(index);
            } else if (!hintIndex.contains(index)) {
              inputIndex.remove(index);
            }
          });
        },
      ));
    }

    List<Widget> hintCard = [];
    for (int i = 0; i < hintWord.length; i++) {
      Color? cardColor;
      if (inputIndex.contains(i)) {
        cardColor = appColorScheme.getColorSheme("unselected");
      } else {
        cardColor = appColorScheme.getColorSheme("fourth");
      }
      if (selectedHint.length < hintWord.length) {
        selectedHint.add(null);
      }
      selectedHint[i] = cardColor;
      hintCard.add(Draggable(
        data: {"hintWord": hintWord[i], "inputIndex": i.toString()},
        onDragStarted: () {
          clickable = false;
          setState(() {
            if (!inputIndex.contains(i)) {
              inputIndex.add(i);
            }
          });
        },
        onDraggableCanceled: (velocity, offset) {
          setState(() {
            inputIndex.remove(i);
          });
          clickable = true;
        },
        onDragCompleted: () {
          clickable = true;
          audioController.playClickSound();
        },
        feedback: Card(
            child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 50,
            minWidth: 30,
          ),
          child: Center(child: Text(hintWord[i])),
        )),
        child: Card(
          color: selectedHint[i],
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              clickable = false;
              audioController.playClickSound();
              int firstBlankIndex =
                  inputData.indexWhere((char) => char.character == '_');
              if (firstBlankIndex != -1 && !inputIndex.contains(i)) {
                setState(() {
                  inputData[firstBlankIndex].character = hintWord[i];
                  inputData[firstBlankIndex].hintIndex =
                      firstBlankIndex.toString();
                  inputData[firstBlankIndex].inputIndex = i.toString();
                  hintIndex.add(i);
                  inputIndex.add(i);
                });
              }
              clickable = true;
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 50,
                minWidth: 30,
              ),
              child: Center(child: Text(hintWord[i], style: style)),
            ),
          ),
        ),
      ));
    }

    Widget mainPage;

    mainPage = Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "${wordController.wordCounter.toString()}/${wordController.wordCounterAll.toString()}",
                ),
                Spacer(),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          var hintDetail = getHint();
                          setState(() {
                            if (hintDetail.isNotEmpty) {
                              clickable = false;
                              if (wordController.hintCounter > 0) {
                                var now = DateTime.now().millisecondsSinceEpoch;
                                wordController.hintCounter -= 1;
                                wordController.lastHintTimeStamp = now;
                                ioController.writeData('hintCounter', 'int',
                                    wordController.hintCounter);
                                ioController.writeData(
                                    'lastHintTimeStamp', 'int', now);
                                var hintChar = hintDetail["hintChar"]!;
                                var randomIndex =
                                    int.parse(hintDetail["randomIndex"]!);
                                inputData[randomIndex].character =
                                    hintChar.toUpperCase();
                              } else {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: Text('Hint Chance Exhaust'),
                                          content: StreamBuilder(
                                              stream:
                                                  liveTimestamp.timestampStream,
                                              builder: (context, setState) {
                                                if (setState.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return CircularProgressIndicator();
                                                } else if (setState.hasError) {
                                                  return Text(
                                                      'Error: ${setState.error}');
                                                } else if (!setState.hasData) {
                                                  return Text(
                                                      'No data available');
                                                } else {
                                                  var now = setState.data!;
                                                  var remainingTime = ((wordController
                                                                  .lastHintTimeStamp +
                                                              (1000 *
                                                                  60 *
                                                                  hintInterval)) -
                                                          now) /
                                                      1000;
                                                  return Text(
                                                      "Next hint will be refresh in: ${remainingTime.round()} sec");
                                                }
                                              }),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        ));
                              }
                              clickable = true;
                            }
                          });
                        },
                        icon: Icon(Icons.lightbulb)),
                    StreamBuilder<int>(
                        stream: liveTimestamp.timestampStream,
                        initialData: DateTime.now().millisecondsSinceEpoch,
                        builder: (context, snapshot) {
                          var now = snapshot.data!;
                          var difference =
                              (now - wordController.lastHintTimeStamp) / 1000;
                          if (difference > hintInterval * 60) {
                            // seconds
                            if (wordController.hintCounter < hintMax) {
                              wordController.hintCounter +=
                                  hintMax - wordController.hintCounter;
                              wordController.lastHintTimeStamp = now;
                              ioController.writeData(
                                  'lastHintTimeStamp', 'int', now);
                              ioController.writeData('hintCounter', 'int',
                                  wordController.hintCounter);
                            }
                          }
                          return Text(
                              "${wordController.hintCounter.toString()}/$hintInterval");
                        })
                  ],
                ),
              ],
            ),
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: inputCard,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(wordData['description']!),
                ),
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: hintCard,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      // Check word corretness
                      var inputText = [];
                      var correctness = "error";
                      for (var element in inputData) {
                        inputText.add(element.character);
                      }
                      if (inputText.join('') ==
                          wordData['word'].toString().toUpperCase()) {
                        correctness = "correct";
                      }

                      // Build response
                      if (correctness == "error") {
                        // Show Dialog
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: Center(child: Text('Incorrect')),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Retry'),
                                    ),
                                  ],
                                ));
                      } else {
                        wordController.removeWord();
                        wordData = wordController.getWordData()!;
                        setState(() {
                          state = "";
                          inputData = [];
                          inputIndex = [];
                          hintIndex = [];
                          selectedHint = [];
                          colorList = [];
                        });
                      }
                    },
                    child: Text("Check Word")),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );

    if (wordData['word'].isEmpty) {
      mainPage = Center(
        child: Text("You beat this difficulty!"),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Browbeat"),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= minWidth) {
              return Center(
                  child:
                      Text("Please rotate your phone for better experience!"));
            } else {
              return mainPage;
            }
          },
        ));
  }
}
