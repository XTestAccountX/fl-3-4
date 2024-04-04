import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ParseEvents {
  static Future<String> readEvents() async {
    String data = "";
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/events.txt';

      File f = File(filePath);

      data = await f.readAsString();
      // await Future.delayed(const Duration(seconds: 5));

    } catch (e) {
      print(e);
    }
    // print(data);
    return data;
  }

  static Future<void> writeEventsToFile(String data) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/events.txt';

      File file = File(filePath);

      await file.writeAsString(data);

      String fileContent = await file.readAsString();
      // print('Содержимое файла: $fileContent');
    } catch (e) {
      print(e);
    }
  }
}
