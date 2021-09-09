import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocr_reader/src/providers/data.dart';
import 'package:provider/provider.dart';

class RowEditForm extends StatelessWidget {
  RowEditForm(this.id, this.refresh);

  final String id;
  final Function refresh;

  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  Widget build(BuildContext ctx) {
    final _data = Provider.of<Data>(ctx);
    Map<String, List<String>> _rowData = _data.getData()['map'];
    String _totalPrice = _data.getData()['total_price'];
    String _grandTotal = _data.getData()['grand_total'];
    print(_rowData.toString());
    print(_totalPrice.toString());
    print(_grandTotal);
    print(_rowData.values.toList().toString());

    setInitialText(_rowData, _totalPrice, _grandTotal);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextField(
              controller: _controllers[0],
              decoration: InputDecoration(
                labelText: 'Item',
              ),
            ),
            TextField(
              controller: _controllers[1],
              decoration: InputDecoration(
                labelText: 'Quantity',
              ),
            ),
            TextField(
              controller: _controllers[2],
              decoration: InputDecoration(
                labelText: 'Unit Price',
              ),
            ),
            TextField(
              controller: _controllers[3],
              decoration: InputDecoration(
                labelText: 'Tax Amount',
              ),
            ),
            TextField(
              controller: _controllers[4],
              decoration: InputDecoration(
                labelText: 'Total Price',
              ),
            ),
            TextField(
              controller: _controllers[5],
              decoration: InputDecoration(
                labelText: 'Grand Total',
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _rowData.update(id, (value) {
                      return [
                        _controllers[0].text,
                        _controllers[1].text,
                        _controllers[2].text,
                        _controllers[3].text,
                      ];
                    });
                    _totalPrice = _controllers[4].text;
                    _grandTotal = _controllers[5].text;
                    var _results = toMap(_rowData, _totalPrice, _grandTotal);
                    _data.update(_results);
                    Navigator.of(ctx).pop();
                    refresh();
                  },
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  setInitialText(
    Map<String, List<String>> _rowData,
    String _totalPrice,
    String _grandTotal,
  ) {
    for (int i = 0; i < 6; i++) {
      if (i == 4)
        _controllers[i].text = _totalPrice;
      else if (i == 5)
        _controllers[i].text = _grandTotal;
      else
        _controllers[i].text = _rowData[id]![i];
    }
  }

  toMap(
    Map<String, List<String>> _rowData,
    String _totalPrice,
    String _grandTotal,
  ) {
    return {
      'map': _rowData,
      'total_price': _totalPrice,
      'grand_total': _grandTotal,
    };
  }
}
