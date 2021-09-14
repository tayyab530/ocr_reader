import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OcrService with ChangeNotifier {
  final TextDetector _recognizer = GoogleMlKit.vision.textDetector();
  late RecognisedText _extractedText;
  Map<List<String>, List<bool>> _linesMap = {};
  Map<String, List<dynamic>> _segregatedData = {};

  Future<Map<List<String>, List<bool>>> getText(InputImage image) async {
    try {
      _extractedText = await _recognizer.processImage(image);
      int i = 0;
      for (TextBlock block in _extractedText.blocks) {
        for (TextLine line in block.lines) {
          print(line.text);
          _linesMap.addAll({
            [line.text, i.toString()]: [false, false]
          });
          i++;
        }
      }
      segregateIntoMap();
      var _result = searchTag('Item', TextType.line);
      selectItems(_result);

      return _linesMap;
    } catch (e) {
      print(e.toString());
    }
    return Future.value();
  }

  clearData() {
    _linesMap = {};
  }

  Map<List<String>, List<bool>> numericLines() {
    Map<List<String>, List<bool>> _numeric = {};
    _linesMap.forEach(
      (key, value) {
        if (isNumeric(key[0])) _numeric.addAll({key: value});
      },
    );
    return _numeric;
  }

  Map<List<String>, List<bool>> alphabeticLines() {
    Map<List<String>, List<bool>> _alphabetic = {};
    _linesMap.forEach(
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

  searchTag(String _tag, TextType type) {
    var _searchData = _segregatedData.values.toList()[type.index].firstWhere(
        (data) => data.text.toLowerCase().contains(_tag.toLowerCase()),
        orElse: null);
    if (_searchData != null) {
      print(_searchData.text);
      print(_searchData.cornerPoints.toString());
    } else
      print('No data found with tag "$_tag" ');

    return _searchData;
  }

  void segregateIntoMap() {
    List<TextBlock> _blocks = [];
    List<TextLine> _lines = [];
    List<TextElement> _elements = [];

    for (var block in _extractedText.blocks) {
      _blocks.add(block);
      for (var line in block.lines) {
        _lines.add(line);
        for (var element in line.elements) {
          _elements.add(element);
        }
      }
    }

    _segregatedData.addAll({
      'blocks': _blocks,
      'lines': _lines,
      'elements': _elements,
    });
    print(_segregatedData.toString());
  }

  selectItems(var _searchData) {
    double _x = _searchData.cornerPoints[0].dx as double;
    double _y = _searchData.cornerPoints[3].dy as double;
    List<TextLine> _lines = _segregatedData['lines']!
        .where(
            (line) => findAllCOCornerPoints(_x, _y, line.cornerPoints[0], 10.0))
        .toList() as List<TextLine>;
    _lines.forEach((element) {
      print(element.text);
    });
  }

  findAllCOCornerPoints(
      double actualX, double actualY, Offset point, double threshold) {
    var estimateSum = actualX + threshold;
    var estimateDiff = actualX - threshold;

    if (actualX == point.dx && actualY < point.dy)
      return true;
    else if (point.dx <= estimateSum &&
        point.dx > actualX &&
        actualY < point.dy)
      return true;
    else if (point.dx >= estimateDiff &&
        point.dx < actualX &&
        actualY < point.dy)
      return true;
    else
      return false;
  }

  RecognisedText get text => _extractedText;
  Map<List<String>, List<bool>> get lines => _linesMap;
}

enum TextType {
  block,
  line,
  element,
}
