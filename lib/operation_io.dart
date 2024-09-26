import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class IOController {
  late SharedPreferencesWithCache prefsWithCache;
  Future<void> initialize() async {
    ioLog.info("Initialize IO Controller....");
    prefsWithCache = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        // When an allowlist is included, any keys that aren't included cannot be used.
        allowList: availableList,
      ),
    );
  }

  Future<void> writeData(
      String dataIdentifier, String dataType, dynamic dataToWrite) async {
    ioLog.config(
        'Wrire data - id: $dataIdentifier, type: $dataType, data: $dataToWrite');
    switch (dataType) {
      case "bool":
        await prefsWithCache.setBool(dataIdentifier, dataToWrite);
      case "double":
        await prefsWithCache.setDouble(dataIdentifier, dataToWrite);
      case "int":
        await prefsWithCache.setInt(dataIdentifier, dataToWrite);
      case "string":
        await prefsWithCache.setString(dataIdentifier, dataToWrite);
      default:
        throw ("IO Operation Error: Data types not define!");
    }
  }

  Future<dynamic> readData(String dataIdentifier, String dataType) async {
    late dynamic result;
    switch (dataType) {
      case "bool":
        result = prefsWithCache.getBool(dataIdentifier);
      case "double":
        result = prefsWithCache.getDouble(dataIdentifier);
      case "int":
        result = prefsWithCache.getInt(dataIdentifier);
      case "string":
        return prefsWithCache.getString(dataIdentifier);
      default:
        throw ("IO Operation Error: Data types not define!");
    }
    ioLog.config(
        'Read data - id: $dataIdentifier, type: $dataType, result: $result');
    return result;
  }

  Future<void> removeData(String dataIdentifier) async {
    ioLog.config('Remove data - id: $dataIdentifier');
    await prefsWithCache.remove(dataIdentifier);
  }

  Future<void> dispose() async {
    ioLog.info('Disposing cache..');
    await prefsWithCache.clear();
  }

  Future<void> resetData() async {
    for (var dataId in availableList) {
      removeData(dataId);
    }
  }
}

final ioLog = Logger("IOController");

const availableList = <String>{
  'musicVolume',
  'clickVolume',
  'playMusic',
  'difficulty',
  'progression',
  'userWordList',
  'wordIndex',
};

final ioController = IOController();
