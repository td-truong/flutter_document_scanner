import 'package:document_scanner/document_scanner.dart';

class DocumentScannerController {
  const DocumentScannerController();

  Future<void> captureImage() async {
    return channel.invokeMethod('captureImage');
  }
}
