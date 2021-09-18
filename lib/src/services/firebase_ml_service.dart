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

      return _linesMap;
    } catch (e) {
      print(e.toString());
      return Future.value();
    }
  }

  Future<List<Map<List<String>, List<bool>>>> getSmartData(
      InputImage image) async {
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
      List<dynamic> _item = findData(
        ['item', 'product', 'barcode', 'description'],
        TextType.line,
        true,
        false,
        SearchTrack.vertical,
        'total',
        includeLine: true,
      );

      // ignore: unused_local_variable
      List<dynamic> _date = findData(
        ['invoice date', 'order date', 'delievery date', 'date'],
        TextType.line,
        true,
        false,
        SearchTrack.horizontal,
        'total',
      );

      List<dynamic> _unitPrice = findData(
        ['rate', 'value', 'amount', 'price'],
        TextType.line,
        true,
        true,
        SearchTrack.vertical,
        'total',
      );

      List<dynamic> _quantity = findData(
        ['quantity', 'qty'],
        TextType.line,
        true,
        false,
        SearchTrack.vertical,
        'total',
      );

      List<dynamic> _total = findData(
        ['total'],
        TextType.line,
        false,
        false,
        SearchTrack.horizontal, //Offset(220.0, 1112.0)
        'total',
        includeLine: true,
      );

      // ignore: unused_local_variable
      List<dynamic> _tax = findData([
        'tax amount',
        'vat',
        'tax',
      ], TextType.line, true, true, SearchTrack.horizontal, 'total',
          includeLine: true);

      List<Map<List<String>, List<bool>>> _finalListofData = [
        toMap(findFirstNonEmpty(_segregatedData['lines']!)),
        toMap(_item),
        toMap(_quantity),
        toMap(_unitPrice),
        toMap(_total),
        toMap(_tax),
      ];
      return _finalListofData;
    } catch (e) {
      print(e.toString());
      return Future.value([]);
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

  List<dynamic> findData(
    List<String> _tags,
    TextType _textType,
    bool enableMulTags,
    bool isNumeric,
    SearchTrack track,
    String yRef, {
    bool includeLine = false,
  }) {
    var _result = searchTag(
      _tags,
      _textType,
      enableMulTags,
      track,
    );
    if (!((_result is TextElement) || (_result is TextLine))) {
      print('No element found.');
      return [];
    } else
      return selectItems(
        _result,
        _textType,
        isNumeric,
        track,
        yRef,
        includeLine,
      );
  }

  searchTag(
    List<String> _tags,
    TextType type,
    bool enableMultipleTags,
    SearchTrack track,
  ) {
    var _searchData;

    if (!enableMultipleTags) {
      try {
        _searchData = _segregatedData.values.toList()[type.index].firstWhere(
              (data) =>
                  data.text.toLowerCase().contains(_tags[0].toLowerCase()),
            );
        print(_searchData.text);
        print(_searchData.cornerPoints.toString());
      } catch (e) {
        print(e.toString());
        return [];
      }
    } else {
      for (String tag in _tags) {
        try {
          var _splittedTag = tag.split(' ');
          TextLine _searchLineData;
          _searchLineData =
              _segregatedData.values.toList()[type.index].firstWhere(
                    (data) => data.text.toLowerCase().contains(
                          tag.toLowerCase(),
                        ),
                  );
          print(_searchLineData.text + " searched line");
          print("_splittedTag ${_splittedTag[_splittedTag.length - 1]}");
          _searchData = _segregatedData.values
              .toList()[TextType.element.index]
              .firstWhere(
            (data) {
              bool isContain = data.text.toLowerCase().contains(
                    _splittedTag[_splittedTag.length - 1].toLowerCase(),
                  );
              if (isContain) {
                print("data.text ${data.text}");
                List<Offset> _tagAllCordinate = _searchLineData.cornerPoints;
                Offset _tagCordinate = _tagAllCordinate[3];
                bool pointsContain = findAllFieldsHorizontally(
                    _tagCordinate.dx,
                    _tagCordinate.dy,
                    data.cornerPoints[3],
                    _tagAllCordinate[2].dy - _tagAllCordinate[1].dy,
                    isOnSameLine: true);
                print('pointsContain $pointsContain');
                return pointsContain;
              }
              return false;
            },
          );
          print(_searchData.text);
          print(_searchData.cornerPoints.toString());
          break;
        } catch (e) {
          print(e.toString());
          _searchData = [];
        }
      }
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

  List<dynamic> selectItems(
    var _searchData,
    TextType type,
    bool isNumeric,
    SearchTrack track,
    String yRef,
    bool includeLine,
  ) {
    double _stopingY = 0.0;
    if (track == SearchTrack.vertical) {
      var _stopingYRef = searchTag(
          [yRef, 'bill amount'], TextType.line, true, SearchTrack.vertical);
      if (_stopingYRef is TextLine)
        _stopingY = _stopingYRef.cornerPoints[0].dy;
      else {
        _stopingY =
            _segregatedData['blocks']!.last.cornerPoints[2].dy as double;
      }
      print('_stopingY $_stopingY');
    }
    List<Offset> _cornerPoints = _searchData.cornerPoints;
    double _tagX = _cornerPoints[isNumeric ? 2 : 3].dx;
    double _tagY = _searchData.cornerPoints[isNumeric ? 2 : 3].dy as double;
    double _horizontalThresholdRatio =
        _cornerPoints[2].dy - _cornerPoints[1].dy;
    print('tag_x $_tagX');
    print('tag_y $_tagY');
    print("_horizontalThresholdRatio $_horizontalThresholdRatio");

    List<dynamic> _lines;

    _lines = _segregatedData[includeLine ? 'lines' : 'elements']!
        .where(
          (line) => track == SearchTrack.vertical
              ? findAllFieldsVertically(
                  _tagX,
                  _tagY,
                  line.cornerPoints[isNumeric ? 2 : 3],
                  20.0,
                  _stopingY,
                  line.text,
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
    return _lines;
  }

  bool findAllFieldsVertically(double tagX, double tagY, Offset point,
      double threshold, double stopingYRef, String text) {
    var estimateSum = tagX + threshold;
    var estimateDiff = tagX - threshold;
    print('point text $text');
    print('estimated Sum for x $estimateSum');
    print('estimated Diff for x $estimateDiff');
    print('stopingYRef $stopingYRef');
    print('${point.dx} x ${point.dy} y');

    if (tagX == point.dx && tagY < point.dy && stopingYRef > point.dy)
      return true;
    else if (point.dx <= estimateSum &&
        point.dx > tagX &&
        tagY < point.dy &&
        stopingYRef > point.dy)
      return true;
    else if (point.dx >= estimateDiff &&
        point.dx < tagX &&
        tagY < point.dy &&
        stopingYRef > point.dy)
      return true;
    else
      return false;
  }

  bool findAllFieldsHorizontally(
      double tagX, double tagY, Offset point, double threshold,
      {bool isOnSameLine = false}) {
    var estimateSum = tagY + threshold;
    var estimateDiff = tagY - threshold;
    print('x reference $tagX');
    print('estimated Sum for y $estimateSum');
    print('estimated Diff for y $estimateDiff');
    print('${point.dx} x ${point.dy} y');

    bool xStopingExp = isOnSameLine ? tagX <= point.dx : tagX < point.dx;

    if (tagY == point.dy && xStopingExp)
      return true;
    else if (point.dy <= estimateSum && point.dy > tagY && xStopingExp)
      return true;
    else if (point.dy >= estimateDiff && point.dy < tagY && xStopingExp)
      return true;
    else
      return false;
  }

  RecognisedText get text => _extractedText;
  Map<List<String>, List<bool>> get lines => _linesMap;

  Map<List<String>, List<bool>> toMap(List<dynamic> _list) {
    Map<List<String>, List<bool>> _map = {};
    int i = 0;
    for (var field in _list) {
      _map.addAll({
        [field.text, i.toString()]: [true, true],
      });
      i++;
    }
    return _map;
  }

  findFirstNonEmpty(List<dynamic> _list) {
    var _vendor = _list.firstWhere((element) {
      print(element.text);
      return element.text.isNotEmpty;
    });
    return [_vendor];
  }
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
