import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../src/providers/data.dart';
import '../src/services/firebase_ml_service.dart';
import '../src/services/image_picker_service.dart';
import '/src/app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => OcrService(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ImagePickerService(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Data(),
        ),
      ],
      child: App(),
    ),
  );
}
