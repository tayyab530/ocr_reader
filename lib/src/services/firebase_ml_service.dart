import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OcrService with ChangeNotifier {
  final TextDetector _recognizer = GoogleMlKit.vision.textDetector();

  Map<List<String>, List<bool>> _lines = {};

  Future<Map<List<String>, List<bool>>> getText(InputImage image) async {
    try {
      final RecognisedText _text = await _recognizer.processImage(image);
      int i = 0;
      for (TextBlock block in _text.blocks) {
        for (TextLine line in block.lines) {
          print(line.text);
          _lines.addAll({
            [line.text, i.toString()]: [false, false]
          });
          i++;
        }
      }
      notifyListeners();
      return _lines;
    } catch (e) {
      print(e.toString());
    }
    return Future.value();
  }

  clearData() {
    _lines = {};
  }

  Map<List<String>, List<bool>> get lines => _lines;

  Map<List<String>, List<bool>> numericLines() {
    Map<List<String>, List<bool>> _numeric = {};
    _lines.forEach(
      (key, value) {
        if (isNumeric(key[0])) _numeric.addAll({key: value});
      },
    );
    return _numeric;
  }

  Map<List<String>, List<bool>> alphabeticLines() {
    Map<List<String>, List<bool>> _alphabetic = {};
    _lines.forEach(
      (key, value) {
        if (isAlpha(key[0])) _alphabetic.addAll({key: value});
      },
    );
    return _alphabetic;
  }

  bool isNumeric(String str) {
    for (var i = 0; i < str.length; i++) {
      bool found = str[i].contains(new RegExp(r'[0-9]'));
      if (found) return true;
    }
    return false;
  }

  bool isAlpha(String str) {
    return double.tryParse(str) == null;
  }
}
