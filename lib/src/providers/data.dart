import 'package:flutter/cupertino.dart';

class Data with ChangeNotifier {
  Map<String, List<String>> _rowsDataMap = {};
  String _totalPrice = '0.0';
  String _grandTotal = '0.0';

  Map<String, dynamic> getData() {
    return {
      'map': _rowsDataMap,
      'total_price': _totalPrice,
      'grand_total': _grandTotal,
    };
  }

  update(Map<String, dynamic> _data) {
    _rowsDataMap = _data['map'];
    _totalPrice = _data['total_price'];
    _grandTotal = _data['grand_total'];
  }
}
