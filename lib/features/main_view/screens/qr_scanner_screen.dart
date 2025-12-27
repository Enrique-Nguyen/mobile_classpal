import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    torchEnabled: false,
  );
  bool _isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quét mã lớp học",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              print("LOG: Đã phát hiện ${barcodes.length} mã!");

              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                print("LOG: Giá trị mã là: $code");

                if (code != null) {
                  print(context);
                  _isScanned = true;
                  Navigator.pop(context, code);
                }
              }
            },
          ),
          const QRScannerOverlay(overlayColour: Colors.black54),
        ],
      ),
    );
  }
}

class QRScannerOverlay extends StatelessWidget {
  final Color overlayColour;

  const QRScannerOverlay({super.key, required this.overlayColour});

  @override
  Widget build(BuildContext context) {
    double scanArea =
        (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;

    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            overlayColour,
            BlendMode.srcOut,
          ), // Chế độ đục thủng lỗ
          child: Center(
            child: Container(
              height: scanArea,
              width: scanArea,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            height: scanArea,
            width: scanArea,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.blueAccent, width: 2.0),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
