import 'package:browbeat/music.dart';
import 'package:browbeat/operation_io.dart';
import 'package:browbeat/state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.secondary,
      fontSize: 15,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Browbeat"),
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
                  child: Column(
                    children: [
                      // BGM
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Center(
                              child: Text(
                                "Music: ${(audioController.bgmVolume * 100).round().toString()}",
                                style: style,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Slider(
                              label: (audioController.bgmVolume * 100)
                                  .round()
                                  .toString(),
                              value: audioController.bgmVolume,
                              onChanged: (double value) => {
                                setState(() {
                                  audioController.bgmVolume = value;
                                })
                              },
                              onChangeEnd: (double value) {
                                audioController.setMusicVolume();
                                ioController.writeData(
                                    'musicVolume', 'double', value);
                              },
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Center(
                              child: Text(
                                "Effect: ${(audioController.clickVolume * 100).round().toString()}",
                                style: style,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Slider(
                              label: (audioController.clickVolume * 100)
                                  .round()
                                  .toString(),
                              value: audioController.clickVolume,
                              onChanged: (double value) => {
                                setState(() {
                                  audioController.clickVolume = value;
                                })
                              },
                              onChangeEnd: (double value) => {
                                ioController.writeData(
                                    'clickVolume', 'double', value)
                              },
                            ),
                          ),
                        ],
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
                              onPressed: () async {
                                Navigator.pop(context);
                                await appState.refreshState();
                                setState(() {
                                  ioLog.info('Reset completed');
                                });
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
