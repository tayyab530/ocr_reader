import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ocr_reader/src/services/firebase_ml_service.dart';
import 'package:provider/provider.dart';

class AnalysisScreen extends StatelessWidget {
  static const routeName = '/analysis';

  @override
  Widget build(BuildContext context) {
    final RecognisedText _text = Provider.of<OcrService>(context).text;

    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis'),
      ),
      body: InteractiveViewer(
        minScale: 0.1,
        constrained: false,
        child: Column(
          children: _text.blocks
              .map((block) => Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(width: 3, color: Colors.black),
                    ),
                    child: Column(children: [
                      ...block.lines
                          .map((line) => Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.amber,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: line.elements
                                          .map(
                                            (element) => Container(
                                              margin: EdgeInsets.symmetric(
                                                vertical: 5,
                                                horizontal: 5,
                                              ),
                                              padding: EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 2,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(element.text),
                                                  Row(
                                                    children:
                                                        element.cornerPoints
                                                            .map(
                                                                (coordinates) =>
                                                                    Chip(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .blue,
                                                                      label:
                                                                          Text(
                                                                        "(" +
                                                                            coordinates.dx.toString() +
                                                                            ',' +
                                                                            coordinates.dy.toString() +
                                                                            ')',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ))
                                                            .toList(),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    ...line.cornerPoints
                                        .map(
                                          (coordinates) => Chip(
                                            backgroundColor: Colors.amber,
                                            label: Text(
                                              "(" +
                                                  coordinates.dx.toString() +
                                                  ',' +
                                                  coordinates.dy.toString() +
                                                  ')',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ))
                          .toList(),
                      Row(
                        children: block.cornerPoints
                            .map(
                              (cordinate) => Chip(
                                backgroundColor: Colors.black,
                                label: Text(
                                  "(" +
                                      cordinate.dx.toString() +
                                      ',' +
                                      cordinate.dy.toString() +
                                      ')',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ]),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
