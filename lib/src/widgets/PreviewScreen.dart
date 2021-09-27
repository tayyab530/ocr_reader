import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ocr_reader/src/providers/data.dart';
import 'package:ocr_reader/src/services/firebase_ml_service.dart';
import 'package:ocr_reader/src/widgets/row_edit_form.dart';
import 'package:provider/provider.dart';

class PreviewScreen extends StatefulWidget {
  static const routeName = '/preview';
  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool init = false;
  List<Map<List<String>, List<bool>>> _data = [];
  Map<String, List<String>> _rowsDataMap = {};
  String _vendor = 'Default';
  String _totalPrice = '0.0';
  String _grandTotal = '0.0';
  double _totalTax = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _data = ModalRoute.of(context)!.settings.arguments
        as List<Map<List<String>, List<bool>>>;
    final _ocrService = Provider.of<OcrService>(context, listen: false);
    if (init) {
      _rowsDataMap = Provider.of<Data>(context, listen: false).getData()['map'];
      _totalPrice =
          Provider.of<Data>(context, listen: false).getData()['total_price'];
      _grandTotal =
          Provider.of<Data>(context, listen: false).getData()['grand_total'];
    }
    if (!init) _vendor = _data[0].keys.first.first;

    final _appBar = AppBar(
      title: Text('Preview Receipt'),
      leading: IconButton(
        onPressed: () {
          _ocrService.clearData();
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back),
      ),
    );

    final _mediaQuery = MediaQuery.of(context);
    final _height = _mediaQuery.size.height -
        _mediaQuery.padding.top -
        _appBar.preferredSize.height;

    return Scaffold(
      appBar: _appBar,
      body: Column(
        children: [
          Chip(
            label: Text(_vendor),
          ),
          Container(
            height: _height * 0.78,
            child: InteractiveViewer(
              constrained: false,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Expanded(
                      flex: 1,
                      child: Text('Items'),
                    ),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Expanded(
                      flex: 1,
                      child: Text('Quantity'),
                    ),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Expanded(
                      flex: 1,
                      child: Text('Unit Price'),
                    ),
                  ),
                  DataColumn(
                    numeric: true,
                    label: Expanded(
                      flex: 1,
                      child: Text('Tax'),
                    ),
                  ),
                ],
                rows: generateRows(),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(
              vertical: _height * 0.005,
              horizontal: 10.0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Total Tax: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '$_totalTax',
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Total Price: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$_totalPrice',
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      bottomSheet: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 7.0,
        ),
        child: Row(
          children: [
            Text(
              'Grand Total: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              _grandTotal,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  generateMap() {
    List<List<String>> _list = [];
    final _dataProvider = Provider.of<Data>(context);

    for (int i = 1; i < 6; i++) {
      _data[i].removeWhere(
        (key, value) {
          return !value[0];
        },
      );
      List<String> _listOfkeys = [];
      _data[i].keys.toList().forEach(
        (element) {
          _listOfkeys.add(element.first);
        },
      );
      _list.add(_listOfkeys);
      print(_listOfkeys.toString());
      print(_list.toString());
    }

    List<List<String>> _rowData = [];
    int _maxLength = maxLength(_list);
    print('max length = $_maxLength');
    _totalPrice = _list[3].isEmpty ? '0.0' : _list[3].first;
    _totalTax = (_list[4].isNotEmpty && double.tryParse(_list[4].first) != null)
        ? double.parse(_list[4].first)
        : 0.0;

    for (int i = 0; i < _maxLength; i++) {
      _rowData.add([]);
    }
    for (int i = 0; i < _maxLength; i++) {
      if (i >= _list[0].length || _list[0][i].isEmpty)
        _rowData[i].add('Not Selected');
      else
        _rowData[i].add(_list[0][i]);
      print('i = $i _list[0] length = ${_list[0].length}');

      if (i >= _list[1].length || _list[1][i].isEmpty)
        _rowData[i].add('1');
      else
        _rowData[i].add(_list[1][i]);
      print('i = $i _list[1] length = ${_list[1].length}');

      if (i >= _list[2].length || _list[2][i].isEmpty)
        _rowData[i].add('0.0');
      else
        _rowData[i].add(_list[2][i]);
      print('i = $i _list[2] length = ${_list[2].length}');

      _rowData[i].add('0.0');
    }
    print(_rowData.toString());
    for (int i = 1; i <= _maxLength; i++) {
      _rowsDataMap.addAll(
        {
          '$i': _rowData[i - 1],
        },
      );
    }
    print(_rowsDataMap.toString());
    init = true;
    var _temp = {
      'map': _rowsDataMap,
      'total_price': _list[3].isEmpty ? '0.0' : _list[3].first,
      'grand_total': _grandTotal,
    };
    _dataProvider.update(_temp);
  }

  List<DataRow> generateRows() {
    List<DataRow> _rows = [];

    if (!init) generateMap();

    _rowsDataMap.forEach((key, value) {
      if (value.isNotEmpty) {
        var row = DataRow(
          cells: [
            DataCell(
              Text(
                value[0],
              ),
            ),
            DataCell(
              Text(
                value[1],
              ),
            ),
            DataCell(
              Text(
                value[2],
              ),
            ),
            DataCell(
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value[3],
                  ),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: IconButton(
                      icon: Icon(
                        Icons.edit_rounded,
                      ),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: RowEditForm(key, refresh),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.contain,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          _rowsDataMap.remove(key);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        _rows.add(row);
      }
    });

    return _rows;
  }

  int maxLength(List<List<String>> _list) {
    return max(
      max(max(_list[0].length, _list[1].length), _list[2].length),
      _list[3].length,
    );
  }

  refresh() {
    setState(() {});
  }
}
