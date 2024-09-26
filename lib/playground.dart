import 'package:beatbrows/music.dart';
import 'package:beatbrows/state.dart';
import 'package:beatbrows/word.dart';
import 'package:flutter/material.dart';

class PlayGround extends StatefulWidget {
  @override
  State<PlayGround> createState() => _PlayGroundState();
}

class _PlayGroundState extends State<PlayGround> {
  var state = "";
  bool clickable = true;
  var wordData = wordController.getWordData()!;
  List<WordState> inputData = [];
  List<int> inputIndex = [];
  List<int> hintIndex = [];
  List<Color?> selectedHint = [];

  @override
  Widget build(BuildContext context) {
    print(wordData['word']);
    final TextEditingController textFieldController = TextEditingController();
    final newData = wordData['hint'].toString().toUpperCase().split('');
    var hintWord = wordData['hintWord'].toString().toUpperCase().split('');

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
      fontSize: 20,
    );

    List<Widget> inputCard = [];
    Color? cardColor;
    for (int i = 0; i < newData.length; i++) {
      if (inputData.length < newData.length) {
        inputData.add(WordState(newData[i], "", ""));
      }
      if (inputData[i].character == "_") {
        cardColor = appColorScheme.getColorSheme("third");
      } else {
        cardColor = appColorScheme.getColorSheme("fourth");
      }
      inputCard.add(DragTarget(
        builder: (context, candidateItems, rejectedItems) {
          return Card(
            color: cardColor,
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
        cardColor = appColorScheme.getColorSheme("third");
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
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "${wordController.wordCounter.toString()}/${wordController.wordCounterAll.toString()}",
            ),
            Column(
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
              ],
            ),

            // TextField(controller: textFieldController,),
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
                  Widget dialog;
                  if (correctness == "error") {
                    dialog = AlertDialog(
                      title: const Text('Incorrect'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  } else {
                    dialog = AlertDialog(
                      title: const Text('Correct'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            wordController.removeWord();
                            wordData = wordController.getWordData()!;
                            setState(() {
                              state = "";
                              inputData = [];
                              inputIndex = [];
                              hintIndex = [];
                              selectedHint = [];
                            });
                          },
                          child: const Text('Continue'),
                        )
                      ],
                    );
                  }

                  // Show Dialog
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => dialog);
                },
                child: Text("Check Word")),
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
          title: Text("BeatBrows"),
        ),
        body: mainPage);
  }
}
