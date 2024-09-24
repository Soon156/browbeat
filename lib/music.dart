import 'dart:async';
import 'package:beatbrows/operation_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

class AudioController {
  late AudioSource musicSource;
  SoLoud soloud = SoLoud.instance;
  late SoundHandle musicHandle;
  Duration length = Duration(seconds: 1);
  late double volume;
  late bool isPlaying;
  late Icon musicIcon;

  Icon stopMusicIcon = Icon(Icons.music_off_rounded);
  Icon playMusicIcon = Icon(Icons.music_note_rounded);

  Future<void> initialize() async {
    audioLog.info("Initialize Audio Controller....");
    volume =
        (await ioController.readData('musicVolume', 'double') as double?) ?? 1;
    isPlaying =
        (await ioController.readData('playMusic', 'bool') as bool?) ?? true;
    await soloud.init();
    await soloud
        .loadAsset('assets/MainMenu.mp3', mode: LoadMode.disk)
        .then((source) async {
      musicSource = source;
    });
    musicHandle = await soloud.play(musicSource, volume: volume, looping: true);
    if (isPlaying) {
      musicIcon = playMusicIcon;
    } else {
      musicIcon = stopMusicIcon;
      soloud.setPause(musicHandle, true);
    }
  }

  void dispose() {
    audioLog.info('Disposing soloud..');
    soloud.deinit();
  }

  Icon switchState() {
    if (isPlaying) {
      isPlaying = false;
      musicIcon = stopMusicIcon;
      fadeOutMusic();
    } else {
      isPlaying = true;
      musicIcon = playMusicIcon;
      startMusic();
    }
    ioController.writeData('playMusic', 'bool', isPlaying);
    audioLog.config('Audio state switch to: $isPlaying');
    return musicIcon;
  }

  void setMusicVolume() {
    soloud.setVolume(musicHandle, volume);
  }

  void startMusic() {
    soloud.fadeVolume(musicHandle, volume, length);
    soloud.setPause(musicHandle, false);
  }

  void fadeOutMusic() {
    if (musicHandle == null) {
      return;
    }
    soloud.fadeVolume(musicHandle, 0, length);
    soloud.schedulePause(musicHandle, length);
  }

  Future<void> playEffect(String type) async {
    // Implement sound effect logic here
  }
}

final audioLog = Logger("AudioConttoller");
final audioController = AudioController();
