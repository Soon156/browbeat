import 'package:beatbrows/music.dart';
import 'package:beatbrows/operation_io.dart';
import 'package:beatbrows/state.dart';
import 'package:beatbrows/word.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSurface,
      fontSize: 20,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("BeatBrows"),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: appColorScheme.getColorSheme("primary"),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Text(
                          "Volume:  ${(audioController.volume * 100).round().toString()}",
                          style: style,
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Slider(
                          label:
                              (audioController.volume * 100).round().toString(),
                          value: audioController.volume,
                          onChanged: (double value) => {
                            setState(() {
                              audioController.volume = value;
                            })
                          },
                          onChangeEnd: (double value) =>
                              {audioController.setMusicVolume()},
                        ),
                      ),
                    ],
                  )),
              ElevatedButton(
                  onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Reset All'),
                          content: const Text(
                              'This action will remove all data!\nDo you wish to continue?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async => {
                                Navigator.pop(context),
                                audioController.dispose(),
                                await ioController.resetData(),
                                await ioController.initialize(),
                                await audioController.initialize(),
                                await wordController.initialize(),
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ),
                  child: Text(
                    "Reset",
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
