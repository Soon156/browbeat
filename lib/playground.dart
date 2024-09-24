import 'package:beatbrows/state.dart';
import 'package:beatbrows/word.dart';
import 'package:flutter/material.dart';

class PlayGround extends StatefulWidget {
  @override
  State<PlayGround> createState() => _PlayGroundState();
}

class _PlayGroundState extends State<PlayGround> {
  var state = "";
  var inputData = [];
  List<int> inputIndex = [];

  @override
  Widget build(BuildContext context) {
    final TextEditingController textFieldController = TextEditingController();
    final wordData = wordController.getWordData();
    final newData = wordData!['hint'].split('');

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
      fontSize: 20,
    );

    List<Widget> inputCard = [];

    for (int i = 0; i < newData.length; i++) {
      if (inputData.length < newData.length) {
        inputData.add([newData[i], null, null]);
      }
      inputCard.add(Card(
        color: appColorScheme.getColorSheme("fourth"),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            setState(() {
              inputIndex.remove(int.parse(inputData[i][2]));
              inputData[i] = ['_', null, null];
            });
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 50,
              minWidth: 30,
            ),
            child: Center(child: Text(inputData[i][0], style: style)),
          ),
        ),
      ));
    }

    List<Widget> hintCard = [];
    var hintWord = wordData['hintWord'].split('');
    for (int i = 0; i < hintWord.length; i++) {
      Color? cardColor;
      if (inputIndex.contains(i)) {
        cardColor = appColorScheme.getColorSheme("unselected");
      } else {
        cardColor = appColorScheme.getColorSheme("third");
      }
      hintCard.add(Card(
        color: cardColor,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            int firstBlankIndex =
                inputData.indexWhere((char) => char[0] == '_');
            if (firstBlankIndex != -1) {
              setState(() {
                inputData[firstBlankIndex][0] = hintWord[i];
                inputData[firstBlankIndex][1] = firstBlankIndex.toString();
                inputData[firstBlankIndex][2] = i.toString();
                inputIndex.add(i);
              });
            }
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 50,
              minWidth: 30,
            ),
            child: Center(child: Text(hintWord[i], style: style)),
          ),
        ),
      ));
    }

    Widget mainPage;
    Widget page;

    switch (state) {
      case "correct":
        page = Column(
          children: [
            TextButton(
                onPressed: () => {
                      wordController.removeWord(),
                      setState(() {
                        state = "";
                        inputData = [];
                        inputIndex = [];
                      })
                    },
                child: Text("Continue")),
            Text('Correct! The word is ${wordData['word']}')
          ],
        );
      case "error":
        page = Text("Incorrect. Try again.");
      default:
        page = Container();
    }

    mainPage = Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${wordController.wordCounter.toString()}/${wordController.wordCounterAll.toString()}",
            ),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: inputCard,
              ),
            ),

            Text(wordData['description']!),

            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: hintCard,
              ),
            ),
            // TextField(controller: textFieldController,),
            TextButton(
                onPressed: () {
                  var inputText = [];
                  var correctness = "error";
                  for (var element in inputData) {
                    inputText.add(element[0]);
                  }
                  if (textFieldController.text.toLowerCase().trim() ==
                          wordData['word'] ||
                      inputText.join('') == wordData['word']) {
                    correctness = "correct";
                  }

                  setState(() {
                    state = correctness;
                  });
                },
                child: Text("Check Word")),
            page,
          ],
        ),
      ),
    );

    if (wordData['word']!.isEmpty) {
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
