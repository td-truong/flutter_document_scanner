import 'dart:async';
import 'dart:io' show Platform;

import 'package:document_scanner/document_scanner_controller.dart';
import 'package:document_scanner/scannedImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:document_scanner/document_scanner_controller.dart';
export 'package:document_scanner/scannedImage.dart';

const String _methodChannelIdentifier = 'document_scanner';
const MethodChannel channel = MethodChannel(_methodChannelIdentifier);

/// Document scanner Platform view.
///
/// Creates a platform specific (only Android and iOS) UI view that displays the device's camera and attempts to detect documents.
/// When a document is detected, [onDocumentScanned] is called with an instance of [ScannedImage].
/// The whole image is saved and it's url is returned as [scannedDocument.initialImage].
/// The document is cropped and saved and it's url is returned as [scannedDocument.croppedImage].
/// ```dart
/// DocumentScanner(
///  onDocumentScanned: (ScannedImage scannedImage) {
///                        print("document : " + scannedImage.croppedImage!);
///                      },
///)
/// ```
class DocumentScanner extends StatefulWidget {
  /// onDocumentScanned gets called when the scanner successfully scans a rectangle (document)
  final Function(ScannedImage) onDocumentScanned;

  final bool? documentAnimation;
  final String? overlayColor;
  final int? detectionCountBeforeCapture;
  // final int detectionRefreshRateInMS;
  final bool? enableTorch;
  // final bool useFrontCam;
  final double? brightness;
  // final double saturation;
  final double? contrast;
  // final double quality;
  // final bool useBase64;
  // final bool saveInAppDocument;
  // final bool captureMultiple;
  final bool manualOnly;
  final bool? noGrayScale;
  final bool showSpinner;
  final bool enhanceDocument;
  final int noSquareCountBeforeRemoveQuad;

  final DocumentScannerController controller;

  DocumentScanner(
      {required this.controller,
      required this.onDocumentScanned,
      this.documentAnimation,
      this.overlayColor, // #2FE329 or #FF2FE329
      this.detectionCountBeforeCapture,
      // this.detectionRefreshRateInMS,
      this.enableTorch,
      // this.useFrontCam,
      this.brightness,
      // this.saturation,
      this.contrast,
      // this.quality,
      // this.useBase64,
      // this.saveInAppDocument,
      // this.captureMultiple,
      this.manualOnly = false,
      this.noGrayScale,
      this.showSpinner = true,
      this.enhanceDocument = true,
      this.noSquareCountBeforeRemoveQuad = 3});

  @override
  _DocState createState() => _DocState();
}

class _DocState extends State<DocumentScanner> with WidgetsBindingObserver {
  bool isResumed = true;

  @override
  void initState() {
    print("initializing document scanner state");
    channel.setMethodCallHandler(_onDocumentScanned);
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    channel.setMethodCallHandler(null);
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  Future<dynamic> _onDocumentScanned(MethodCall call) async {
    if (call.method == "onPictureTaken") {
      Map<String, dynamic> argsAsMap =
          Map<String, dynamic>.from(call.arguments);

      ScannedImage scannedImage = ScannedImage.fromMap(argsAsMap);

      // ScannedImage scannedImage = ScannedImage(
      //     croppedImage: argsAsMap["croppedImage"],
      //     initialImage: argsAsMap["initialImage"]);

      // print("scanned image decoded");
      // print(scannedImage.toJson());

      if (scannedImage.croppedImage != null) {
        // print("scanned image not null");
        widget.onDocumentScanned(scannedImage);
      }
    }

    return;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      isResumed = (state == AppLifecycleState.resumed) ? true : false;
    });
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    if (!isResumed) {
      return Container(color: Colors.black);
    } else {
      if (Platform.isAndroid) {
        return AndroidView(
          viewType: _methodChannelIdentifier,
          creationParamsCodec: const StandardMessageCodec(),
          creationParams: _getParams(),
        );
      } else if (Platform.isIOS) {
        print("platform ios");
        return UiKitView(
          viewType: _methodChannelIdentifier,
          creationParams: _getParams(),
          creationParamsCodec: const StandardMessageCodec(),
        );
      } else {
        throw ("Current Platform is not supported");
      }
    }
  }

  Map<String, dynamic> _getParams() {
    Map<String, dynamic> allParams = {
      "documentAnimation": widget.documentAnimation,
      "overlayColor": widget.overlayColor,
      "detectionCountBeforeCapture": widget.detectionCountBeforeCapture,
      "enableTorch": widget.enableTorch,
      "manualOnly": widget.manualOnly,
      "noGrayScale": widget.noGrayScale,
      "brightness": widget.brightness,
      "contrast": widget.contrast,
      // "saturation": widget.saturation,
      "showSpinner": widget.showSpinner,
      "enhanceDocument": widget.enhanceDocument,
      "noSquareCountBeforeRemoveQuad": widget.noSquareCountBeforeRemoveQuad
    };

    Map<String, dynamic> nonNullParams = {};
    allParams.forEach((key, value) {
      if (value != null) {
        nonNullParams.addAll({key: value});
      }
    });

    return nonNullParams;
  }
}
