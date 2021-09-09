import 'package:flutter/material.dart';
import 'package:ocr_reader/src/services/firebase_ml_service.dart';
import 'package:ocr_reader/src/widgets/PreviewScreen.dart';
import 'package:ocr_reader/src/widgets/navigation_buttons.dart';
import 'package:provider/provider.dart';

class WizardScreen extends StatefulWidget {
  static const routeName = '/wizard';
  @override
  _WizardScreenState createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  bool _showBackToTopButton = false;
  ScrollController _scrollController = ScrollController();

  int _currentStep = 0;
  Map<bool, Type> isLinkEnable = {false: Type.none};

  //Map<List<text,index>, List<checkBox, tile selection>>
  List<Map<List<String>, List<bool>>> _types = [{}, {}, {}, {}, {}];

  @override
  void initState() {
    var _ocrService = Provider.of<OcrService>(context, listen: false);
    _types[0] = _ocrService.alphabeticLines();
    _types[1] = _ocrService.alphabeticLines();

    _types[2] = _ocrService.numericLines();
    _types[3] = _ocrService.numericLines();
    _types[4] = _ocrService.numericLines();

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {
            _showBackToTopButton = true; // show the back-to-top button
          } else {
            _showBackToTopButton = false; // hide the back-to-top button
          }
        });
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wizard'),
        actions: [
          if (isLinkEnable.keys.first)
            IconButton(
              icon: Icon(Icons.link),
              onPressed: () {
                linkLines(isLinkEnable.values.first);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          NavigationButtons(),
          SingleChildScrollView(
            controller: _scrollController,
            child: Stepper(
              currentStep: _currentStep,
              physics: ScrollPhysics(),
              onStepTapped: (step) => tapped(step),
              controlsBuilder: (context, {onStepCancel, onStepContinue}) => Row(
                children: [
                  if (_currentStep < 4)
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: _currentStep == 4
                            ? Colors.blue[200]
                            : Colors.transparent,
                      ),
                      onPressed: () async {
                        setState(
                          () {
                            _currentStep += 1;
                            // setAllSelectionTofalse();
                            isLinkEnable = {false: Type.none};
                          },
                        );
                      },
                      child: Text('Next '),
                    ),
                  if (_currentStep == 4)
                    TextButton(
                      onPressed: () async {
                        var types = _types;
                        await Navigator.of(context).pushNamed(
                            PreviewScreen.routeName,
                            arguments: types);
                      },
                      child: Text('Preview '),
                    ),
                  if (_currentStep != 0)
                    TextButton(
                      onPressed: () {
                        if (_currentStep > 0)
                          setState(
                            () {
                              _currentStep -= 1;
                              // setAllSelectionTofalse();
                              isLinkEnable = {false: Type.none};
                            },
                          );
                      },
                      child: Text('Previous '),
                    ),
                  if (_currentStep != 4)
                    TextButton(
                      onPressed: () {
                        if (_currentStep < 4)
                          setState(
                            () {
                              _currentStep += 1;
                              // setAllSelectionTofalse();
                              isLinkEnable = {false: Type.none};
                            },
                          );
                      },
                      child: Text('Skip '),
                    ),
                ],
              ),
              steps: [
                Step(
                  title: Text('Vendor'),
                  content: Column(
                    children: populateColumn(_types[0], Type.vendor),
                  ),
                ),
                Step(
                  title: Text('Items'),
                  content: Column(
                    children: populateColumn(_types[1], Type.items),
                  ),
                ),
                Step(
                  title: Text('Quantity'),
                  content: Column(
                    children: populateColumn(_types[2], Type.quantity),
                  ),
                ),
                Step(
                  title: Text('Unit Price'),
                  content: Column(
                    children: populateColumn(_types[3], Type.unitPrice),
                  ),
                ),
                Step(
                  title: Text('Total Price'),
                  content: Column(
                    children: populateColumn(_types[4], Type.totalPrice),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !_showBackToTopButton
          ? null
          : FloatingActionButton(
              onPressed: _scrollToTop,
              child: Icon(Icons.arrow_upward),
            ),
    );
  }

  tapped(int step) {
    setState(() {
      _currentStep = step;
      // setAllSelectionTofalse();
      isLinkEnable = {false: Type.none};
    });
  }

  List<Widget> populateColumn(Map<List<String>, List<bool>> lines, Type type) {
    List<Widget> _list = [];
    String customText = '';
    lines.forEach((key, _value) {
      _list.add(ListTile(
        tileColor: Colors.transparent,
        title: SelectableText(
          key[0],
          onSelectionChanged: (selection, cause) {
            print(selection.start);
            print(selection.end);
            final selectedText =
                key[0].substring(selection.start, selection.end);
            print(selectedText);
            customText = selectedText;
          },
          toolbarOptions: ToolbarOptions(),
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: Checkbox(
                value: _value[0],
                onChanged: (newVal) {
                  setState(
                    () {
                      updateValue(type, [newVal!, _value[1]], key);
                    },
                  );
                },
              ),
            ),
            FittedBox(
              fit: BoxFit.contain,
              child: IconButton(
                color: !_value[1] ? Colors.grey[300] : Colors.blue,
                icon: Icon(Icons.add_link),
                onPressed: () {
                  toggleTileSelection(type, _value, key);
                },
              ),
            ),
            FittedBox(
              fit: BoxFit.contain,
              child: IconButton(
                color: Colors.amberAccent,
                icon: Icon(Icons.edit),
                onPressed: () {
                  if (customText.isNotEmpty)
                    setState(() {
                      print(customText);
                      updateKey(type, key, customText);
                    });
                },
              ),
            ),
          ],
        ),
      ));
    });
    return _list;
  }

  updateValue(Type type, List<bool> newVal, List<String> key) {
    switch (type) {
      case Type.vendor:
        {
          _types[0][key] = newVal;
        }
        break;
      case Type.items:
        {
          _types[1][key] = newVal;
        }
        break;
      case Type.quantity:
        {
          _types[2][key] = newVal;
        }
        break;
      case Type.unitPrice:
        {
          _types[3][key] = newVal;
        }
        break;
      case Type.totalPrice:
        {
          _types[4][key] = newVal;
        }
        break;
      case Type.none:
        {
          print('no type');
        }
        break;
    }
  }

  updateKey(Type type, _key, String customText) {
    _types[type.index] = _types[type.index].map((key, value) {
      if (key == _key) return MapEntry([customText, key[1]], value);
      return MapEntry(key, value);
    });
  }

  // setAllSelectionTofalse() {
  //   _types.forEach((type) {
  //     type.updateAll((key, value) {
  //       return [value[0], false];
  //     });
  //   });
  // }

  bool enableLink(Type _type) {
    bool enable = _types[_type.index].values.any(
      (v) {
        if ((v[0] == false || v[0] == true) && v[1] == true) return true;
        return false;
      },
    );
    return enable;
  }

  linkLines(Type type) {
    if (type == Type.none) return;
    Map<List<String>, List<bool>> _temp = {
      ['', '']: [false, false]
    };
    Map<List<String>, List<bool>> _temp2 = {
      ['', '']: [false, false]
    };
    _types[type.index].forEach((key, value) {
      if (value[1] == true) {
        _temp.addAll({
          key: [false, false],
        });
      }
    });
    String text = '';
    _temp.forEach((key, value) {
      text = text + (text.isNotEmpty ? ' ' : '') + key[0];
    });
    print(text);
    _temp2.clear();
    _temp2.addAll({
      [text, _temp.keys.first[1]]: [false, false]
    });

    _temp.keys.forEach((key) {
      _types[type.index].removeWhere((_key, value) => _key == key);
    });
    setState(() {
      _types[type.index].addAll(_temp2);
      isLinkEnable = {false: Type.none};
    });

    print(_temp2.toString());
  }

  toggleTileSelection(Type type, List<bool> _value, List<String> key) {
    setState(
      () {
        updateValue(type, [_value[0], !_value[1]], key);
        isLinkEnable = {enableLink(type): type};
      },
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 1, microseconds: 400),
        curve: Curves.easeOut);
  }
}

enum Type {
  vendor,
  items,
  quantity,
  unitPrice,
  totalPrice,
  none,
}
