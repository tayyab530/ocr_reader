import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  NavigationButtons({
    required this.skipOrNext,
    required this.gotoPrevious,
    required this.gotoPreview,
    required this.currentStep,
  });

  final VoidCallback skipOrNext;
  final VoidCallback gotoPrevious;
  final Function gotoPreview;

  final int currentStep;
  final _color = Colors.amber;
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return Positioned(
      top: _height * 0.3,
      right: 10.0,
      child: Column(
        children: [
          if (currentStep != 0)
            FloatingActionButton(
              heroTag: 'btn1',
              mini: true,
              child: Icon(Icons.arrow_back),
              onPressed: () {
                gotoPrevious();
              },
              backgroundColor: _color,
            ),
          SizedBox(
            height: 7.0,
          ),
          if (currentStep == 4)
            FloatingActionButton(
              heroTag: 'btn2',
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text("Preview"),
              ),
              onPressed: () {
                gotoPreview();
              },
              backgroundColor: Colors.amberAccent,
            ),
          if (currentStep != 4)
            FloatingActionButton(
              heroTag: 'btn3',
              mini: true,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text("skip"),
              ),
              onPressed: () {
                skipOrNext();
              },
              backgroundColor: _color,
            ),
          SizedBox(
            height: 7.0,
          ),
          if (currentStep < 4)
            FloatingActionButton(
              heroTag: 'btn4',
              mini: true,
              child: Icon(Icons.arrow_forward),
              onPressed: () {
                skipOrNext();
              },
              backgroundColor: _color,
            ),
        ],
      ),
    );
  }
}
