import 'dart:io';

import 'package:flutter/material.dart';

import 'package:document_scanner/document_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(HomeApp());

class HomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      backgroundColor: Colors.green,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => MyApp()));
          },
          child: const Text('Push'),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? scannedDocument;
  Future<PermissionStatus>? cameraPermissionFuture;

  final _scannerController = DocumentScannerController();

  @override
  void initState() {
    cameraPermissionFuture = Permission.camera.request();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: FutureBuilder<PermissionStatus>(
        future: cameraPermissionFuture,
        builder:
            (BuildContext context, AsyncSnapshot<PermissionStatus> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.isGranted)
              return Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: scannedDocument != null
                            ? Image(
                                image: FileImage(scannedDocument!),
                              )
                            : DocumentScanner(
                                controller: _scannerController,
                                manualOnly: true,
                                onDocumentScanned: (ScannedImage scannedImage) {
                                  print("document : " +
                                      scannedImage.croppedImage!);

                                  setState(() {
                                    scannedDocument = null;
                                    // scannedImage.getScannedDocumentAsFile(); Duy
                                    // imageLocation = image;
                                  });
                                },
                                onStartDetectingRectangle: () {
                                  print("onStartDetectingRectangle");
                                },
                              ),
                      ),
                    ],
                  ),
                  scannedDocument != null
                      ? Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: RaisedButton(
                              child: Text("retry"),
                              onPressed: () {
                                setState(() {
                                  scannedDocument = null;
                                });
                              }),
                        )
                      : Container(),
                ],
              );
            else
              return Center(
                child: Text("camera permission denied"),
              );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scannerController.captureImage();
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
