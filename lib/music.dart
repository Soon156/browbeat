import 'dart:async';
import 'package:browbeat/operation_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';

class AudioController {
  late AudioSource bgmSource;
  late AudioSource clickSource;
  SoLoud bgmInstance = SoLoud.instance;
  SoLoud clickInstance = SoLoud.instance;
  late SoundHandle musicHandle;
  Duration length = Duration(seconds: 1);
  late double bgmVolume;
  late double clickVolume;
  late bool isPlaying;
  late Icon musicIcon;

  Icon stopMusicIcon = Icon(Icons.music_off_rounded);
  Icon playMusicIcon = Icon(Icons.music_note_rounded);

  Future<void> initialize() async {
    audioLog.info("Initialize Audio Controller....");
    bgmVolume =
        (await ioController.readData('musicVolume', 'double') as double?) ?? 1;
    clickVolume =
        (await ioController.readData('clickVolume', 'double') as double?) ??
            0.7;
    isPlaying =
        (await ioController.readData('playMusic', 'bool') as bool?) ?? true;
    await bgmInstance.init();
    await bgmInstance
        .loadAsset('assets/backgound_music.mp3', mode: LoadMode.disk)
        .then((source) async {
      bgmSource = source;
    });
    await clickInstance
        .loadAsset('assets/pop_sound.mp3', mode: LoadMode.memory)
        .then((source) async {
      clickSource = source;
    });
    musicHandle =
        await bgmInstance.play(bgmSource, volume: bgmVolume, looping: true);
    if (isPlaying) {
      musicIcon = playMusicIcon;
    } else {
      musicIcon = stopMusicIcon;
      bgmInstance.setPause(musicHandle, true);
    }
  }

  void dispose() {
    audioLog.info('Disposing soloud..');
    bgmInstance.deinit();
    clickInstance.deinit();
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
    bgmInstance.setVolume(musicHandle, bgmVolume);
  }

  void playClickSound() {
    clickInstance.play(clickSource, volume: clickVolume);
  }

  void startMusic() {
    bgmInstance.fadeVolume(musicHandle, bgmVolume, length);
    bgmInstance.setPause(musicHandle, false);
  }

  void fadeOutMusic() {
    if (musicHandle == null) {
      return;
    }
    bgmInstance.fadeVolume(musicHandle, 0, length);
    bgmInstance.schedulePause(musicHandle, length);
  }

  Future<void> playEffect(String type) async {
    // Implement sound effect logic here
  }
}

final audioLog = Logger("AudioConttoller");
final audioController = AudioController();
