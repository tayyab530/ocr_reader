import 'package:flutter/cupertino.dart';

class Word {
  final String text;
  final List<Offset> cornerPoints;

  Word({
    required this.text,
    required this.cornerPoints,
  });
}

class Line {
  final String text;
  final List<Offset> cornerPoints;
  final List<Word> elements;

  Line({
    required this.text,
    required this.cornerPoints,
    required this.elements,
  });
}
