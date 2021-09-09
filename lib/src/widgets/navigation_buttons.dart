import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final _color = Colors.amber;
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return Positioned(
      top: _height * 0.3,
      right: 10.0,
      child: Column(
        children: [
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.arrow_forward),
            onPressed: () {},
            backgroundColor: _color,
          ),
          SizedBox(
            height: 7.0,
          ),
          FloatingActionButton(
            mini: true,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text("skip"),
            ),
            onPressed: () {},
            backgroundColor: _color,
          ),
          SizedBox(
            height: 7.0,
          ),
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.arrow_back),
            onPressed: () {},
            backgroundColor: _color,
          ),
        ],
      ),
    );
  }
}
