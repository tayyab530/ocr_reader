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
      var _result = searchTag(
        'deal',
        TextType.element,
      );
      if (!((_result is TextElement) || (_result is TextLine))) {
        print('No element found.');
      } else
        selectItems(
          _result,
          true,
          track: SearchTrack.horizontal,
        );

      return _linesMap;
    } catch (e) {
      print(e.toString());
      return Future.value();
    }
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
    var _searchData;
    try {
      _searchData = _segregatedData.values.toList()[type.index].singleWhere(
            (data) => data.text.toLowerCase().contains(_tag.toLowerCase()),
          );
      print(_searchData.text);
      print(_searchData.cornerPoints.toString());
    } catch (e) {
      print(e.toString());
      return [];
    }

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

  selectItems(var _searchData, bool isNumeric,
      {SearchTrack track = SearchTrack.vertical}) {
    double _stopingY = searchTag('total', TextType.line).cornerPoints[0].dy;
    List<Offset> _cornerPoints = _searchData.cornerPoints;
    double _tagX = _cornerPoints[isNumeric ? 2 : 3].dx;
    double _tagY = _searchData.cornerPoints[isNumeric ? 2 : 3].dy as double;
    double _horizontalThresholdRatio =
        _cornerPoints[2].dy - _cornerPoints[1].dy;
    print('_stopingY $_stopingY');
    print('tag_x $_tagX');
    print('tag_y $_tagY');
    print(_horizontalThresholdRatio);

    List<dynamic> _lines;

    _lines = _segregatedData['elements']!
        .where(
          (line) => track == SearchTrack.vertical
              ? findAllFieldsVertically(
                  _tagX,
                  _tagY,
                  line.cornerPoints[isNumeric ? 2 : 3],
                  20.0,
                  _stopingY,
                )
              : findAllFieldsHorizontally(
                  _tagX,
                  _tagY,
                  line.cornerPoints[isNumeric ? 2 : 3],
                  1 * _horizontalThresholdRatio,
                ),
        )
        .toList();
    _lines.forEach(
      (element) {
        print('${element.text} cornerPin ${element.cornerPoints.toString()}');
      },
    );
  }

  findAllFieldsVertically(
      double tagX, double tagY, Offset point, double threshold, double totalY) {
    var estimateSum = tagX + threshold;
    var estimateDiff = tagX - threshold;

    print('estimated Sum $estimateSum');
    print('estimated Diff $estimateDiff');
    print('${point.dx} x ${point.dy} y');

    if (tagX == point.dx && tagY < point.dy && totalY > point.dy)
      return true;
    else if (point.dx <= estimateSum &&
        point.dx > tagX &&
        tagY < point.dy &&
        totalY > point.dy)
      return true;
    else if (point.dx >= estimateDiff &&
        point.dx < tagX &&
        tagY < point.dy &&
        totalY > point.dy)
      return true;
    else
      return false;
  }

  findAllFieldsHorizontally(
      double tagX, double tagY, Offset point, double threshold) {
    var estimateSum = tagY + threshold;
    var estimateDiff = tagY - threshold;

    print('estimated Sum $estimateSum');
    print('estimated Diff $estimateDiff');
    print('${point.dx} x ${point.dy} y');

    if (tagY == point.dy && tagX < point.dx)
      return true;
    else if (point.dy <= estimateSum && point.dy > tagY && tagX < point.dx)
      return true;
    else if (point.dy >= estimateDiff && point.dy < tagY && tagX < point.dx)
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

enum SearchTrack {
  vertical,
  horizontal,
}
