import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ocr_reader/src/screens/analysis_screen.dart';
import 'package:ocr_reader/src/widgets/PreviewScreen.dart';
import 'package:provider/provider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '/src/services/firebase_ml_service.dart';
import 'widgets/wizard_screen.dart';
import '/src/services/image_picker_service.dart';

class App extends StatelessWidget {
  Widget build(BuildContext context) {
    final _imagePicker =
        Provider.of<ImagePickerService>(context, listen: false);
    final _ocrService = Provider.of<OcrService>(context, listen: false);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('OCR Reader'),
        ),
        body: Center(
          child: Text('Please select a receipt'),
        ),
        floatingActionButton:
            ScanButton(imagePicker: _imagePicker, ocrService: _ocrService),
      ),
      routes: {
        WizardScreen.routeName: (ctx) => WizardScreen(),
        PreviewScreen.routeName: (ctx) => PreviewScreen(),
        AnalysisScreen.routeName: (ctx) => AnalysisScreen(),
      },
    );
  }
}

class ScanButton extends StatelessWidget {
  const ScanButton({
    Key? key,
    required ImagePickerService imagePicker,
    required OcrService ocrService,
  })  : _imagePicker = imagePicker,
        _ocrService = ocrService,
        super(key: key);

  final ImagePickerService _imagePicker;
  final OcrService _ocrService;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      spacing: 10.0,
      spaceBetweenChildren: 5.0,
      icon: Icons.scanner,
      activeIcon: Icons.close,
      activeBackgroundColor: Colors.amber,
      children: [
        SpeedDialChild(
          child: Icon(Icons.image),
          onTap: () async {
            await getImageFromGallery(context);
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.camera),
          onTap: () async {
            await getImageFromCamera(context);
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.analytics),
          onTap: () async {
            await gotoAnalysis(context);
          },
        ),
      ],
    );
  }

  getImageFromGallery(BuildContext context) async {
    final InputImage _image = await _imagePicker.getImageFromGallery();
    _ocrService.clearData();
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    await _ocrService.getText(_image).then((value) {
      Navigator.of(context).pop();
    });
    await Navigator.of(context).pushNamed(WizardScreen.routeName);
  }

  getImageFromCamera(BuildContext context) async {
    final InputImage _image = await _imagePicker.getImageFromCamera();
    _ocrService.clearData();
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    await _ocrService.getText(_image).then((value) {
      Navigator.of(context).pop();
    });
    await Navigator.of(context).pushNamed(WizardScreen.routeName);
  }

  gotoAnalysis(BuildContext context) async {
    final InputImage _image = await _imagePicker.getImageFromGallery();
    _ocrService.clearData();
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    await _ocrService.getText(_image).then((value) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(AnalysisScreen.routeName);
    });
  }
}
