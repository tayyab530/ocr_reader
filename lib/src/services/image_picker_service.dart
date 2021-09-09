import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  Future<InputImage> getImageFromGallery() async {
    try {
      final _pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (_pickedImage != null) {
        final String _path = _pickedImage.path;
        print(_path);
        final _image = InputImage.fromFile(File(_path));
        return _image;
      }
    } catch (e) {
      print(e.toString());
    }
    return Future.value();
  }

  Future<InputImage> getImageFromCamera() async {
    try {
      final _pickedImage = await _picker.pickImage(
        source: ImageSource.camera,
      );
      if (_pickedImage != null) {
        final String _path = _pickedImage.path;
        print(_path);
        final _image = InputImage.fromFile(File(_path));
        return _image;
      }
    } catch (e) {
      print(e.toString());
    }
    return Future.value();
  }
}
