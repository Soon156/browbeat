import 'package:beatbrows/word.dart';
import 'package:flutter/material.dart';

class PlayGround extends StatefulWidget {
  @override
  State<PlayGround> createState() => _PlayGroundState();
}

class _PlayGroundState extends State<PlayGround> {
  var state = "";

  @override
  Widget build(BuildContext context) {
    final TextEditingController textFieldController = TextEditingController();
    final wordData = wordController.getWordData();

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
      fontSize: 20,
    );

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
                      })
                    },
                child: Text("Continue")),
            Text('Correct! The word is ${wordData!['word']}')
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var char in wordData!['hint']!.split(''))
                  Card(
                    color: theme.colorScheme.primary,
                    clipBehavior: Clip.hardEdge,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(char, style: style),
                    ),
                  ),
              ],
            ),
            Text(wordData['description']!),
            TextField(
              controller: textFieldController,
            ),
            TextButton(
                onPressed: () => {
                      if (textFieldController.text.toLowerCase().trim() ==
                          wordData['word'])
                        {
                          setState(() {
                            state = "correct";
                          })
                        }
                      else
                        {
                          setState(() {
                            state = "error";
                          })
                        }
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
