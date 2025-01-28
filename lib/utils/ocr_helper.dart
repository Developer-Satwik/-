import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class OCRHelper {
  static Future<void> initializeTessdata() async {
    if (Platform.isIOS) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final tessdataDir = Directory('${appDir.path}/tessdata');
        
        if (!await tessdataDir.exists()) {
          await tessdataDir.create(recursive: true);
        }

        final tessdataFile = File('${tessdataDir.path}/eng.traineddata');
        if (!await tessdataFile.exists()) {
          final data = await rootBundle.load('assets/tessdata/eng.traineddata');
          await tessdataFile.writeAsBytes(data.buffer.asUint8List());
        }
      } catch (e) {
        print('Error initializing tessdata: $e');
      }
    }
  }
} 