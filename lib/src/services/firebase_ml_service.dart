import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ocr_reader/src/models/models.dart';

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
      _extractedText = await _recognizer.processImage(
        image,
      );

      print(_extractedText.text);

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
        true,
        SearchTrack.vertical,
        'total',
      );

      List<dynamic> _total = findData(
        ['total'],
        TextType.line,
        false,
        true,
        SearchTrack.horizontal, //Offset(220.0, 1112.0)
        'total',
        includeLine: true,
      );

      // ignore: unused_local_variable
      List<dynamic> _tax = findData([
        'total tax',
        'tax amount',
        'tax',
        'vat',
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
    _segregatedData = {};
  }

  Map<List<String>, List<bool>> numericLines() {
    Map<List<String>, List<bool>> _numeric = {};
    _linesMap.forEach(
      (key, value) {
        if (isNumericAny(key[0])) _numeric.addAll({key: value});
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

  bool isNumericAny(String str) {
    for (var i = 0; i < str.length; i++) {
      bool found = str[i].contains(new RegExp(r'[0-9]'));
      if (found) return true;
    }
    return false;
  }

  bool isNumericAll(String str) {
    return double.tryParse(str) != null;
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
    if (!((_result is Word) || (_result is Line))) {
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
          Line _searchLineData;
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
    List<Line> _lines = [];
    List<Word> _elements = [];

    for (var block in _extractedText.blocks) {
      _blocks.add(block);
      for (var line in block.lines) {
        Line _newLine = checkForStrangeReadings(line, ['*', '\'', '\"']);
        print('Line ${_newLine.text} isEmpty ${_newLine.text.isEmpty} ');
        if (_newLine.text.isNotEmpty) _lines.add(_newLine);
        for (var element in line.elements) {
          _elements.add(Word(
            text: element.text,
            cornerPoints: element.cornerPoints,
          ));
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
      if (_stopingYRef is Line || _stopingYRef is Word)
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
    double _verticalThresholdRatio = _cornerPoints[1].dx - _cornerPoints[0].dx;
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
                  _verticalThresholdRatio,
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

    if (includeLine) {
      _lines = separateWord(_lines);
    }

    _lines.forEach(
      (element) {
        print('${element.text} cornerPin ${element.cornerPoints.toString()}');
      },
    );

    if (isNumeric) {
      _lines = _lines.map((e) {
        String _text = e.text;
        List<String> _splittedText = _text.split(' ');
        _splittedText.removeWhere((element) => !isNumericAll(element));
        _text = _splittedText.join(" ");
        if (includeLine)
          return Line(
              text: _text, cornerPoints: e.cornerPoints, elements: e.elements);
        else
          return Word(text: _text, cornerPoints: e.cornerPoints);
      }).toList();
    }

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

  List<Line> separateWord(List<dynamic> _lines) {
    List<Line> _listOfLines = [];
    _lines = _lines.map(
      (line) {
        Word _word = line.elements.first;
        double widthOfWord =
            _word.cornerPoints[2].dx - _word.cornerPoints[3].dx;
        double _spaceWidth = (widthOfWord / _word.text.length) * 1.33333;
        double _currentRefrenceX = _word.cornerPoints[2].dx;
        print('widthOfWord $widthOfWord');
        print('_spaceWidth $_spaceWidth');
        Line _line = line;
        List<Word> _listofElement = [];
        String text = '';
        bool _break = false;

        line.elements.forEach(
          (element) {
            if (!_break) {
              Word word;
              Word _element = element;
              double _widthDifference =
                  element.cornerPoints[3].dx - _currentRefrenceX;
              print('text ${{element.text}}');
              print('_prevRefrenceX $_currentRefrenceX');
              print(
                  'x2 ${element.cornerPoints[3].dx} - x1 $_currentRefrenceX = $_widthDifference');
              bool isAWord = (_widthDifference) <= _spaceWidth;
              print("isAWord $isAWord");
              _currentRefrenceX = element.cornerPoints[2].dx;
              print('_nextRefrenceX $_currentRefrenceX');
              if (isAWord || _widthDifference <= 0) {
                word = Word(
                  text: _element.text,
                  cornerPoints: _element.cornerPoints,
                );
                _listofElement.add(word);
                text += (_element.text + ' ');
              } else
                _break = true;
            }
          },
        );

        if (_listofElement.isNotEmpty)
          _listOfLines.add(Line(
            elements: _listofElement,
            text: text,
            cornerPoints: line.cornerPoints,
          ));
        print(_line.text);
        return _line;
      },
    ).toList();
    return _listOfLines;
  }

  Line checkForStrangeReadings(TextLine _textLine, List<String> _charList) {
    String allText = _textLine.text;
    RegExp _regExp = RegExp(r'^[a-zA-Z0-9]');

    // for (var _char in _charList) {
    //   if (_regExp.hasMatch(_char)) {
    //     allText = allText.replaceAll(_char, '');
    //   }
    // }
    if (!_regExp.hasMatch(allText)) allText = '';
    List<Word> _words = _textLine.elements.toList().map<Word>((element) {
      return Word(text: element.text, cornerPoints: element.cornerPoints);
    }).toList();

    return Line(
      text: allText,
      cornerPoints: _textLine.cornerPoints,
      elements: _words,
    );
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
