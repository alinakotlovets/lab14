import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NativeCameraApp(),
    );
  }
}

class NativeCameraApp extends StatefulWidget {
  @override
  _NativeCameraAppState createState() => _NativeCameraAppState();
}

class _NativeCameraAppState extends State<NativeCameraApp> {
  static const platform = MethodChannel('com.example/native_code');
  File? _image;

  Future<void> _getNativeTime(BuildContext context) async {
    try {
      final String nativeTime = await platform.invokeMethod('getNativeTime');
      _showTimeDialog(context, nativeTime);
    } on PlatformException catch (e) {
      _showTimeDialog(context, "Error: ${e.message}");
    }
  }

  void _showTimeDialog(BuildContext context, String time) {
    showDialog(
      context: context,
      builder: (context) => TimeDialog(time: time),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Native and Camera App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _getNativeTime(context),
              child: const Text("Get Native Time"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Take a Photo"),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Image.file(
                _image!,
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }
}

class TimeDialog extends StatelessWidget {
  final String time;

  const TimeDialog({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Current Time'),
      content: Text(time),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
