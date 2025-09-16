import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ler Código de Barras'),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          // Permite que o usuário use o flash do celular
          detectionSpeed: DetectionSpeed.normal,
          formats: [BarcodeFormat.all],
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            // Retorna o primeiro código de barras encontrado e fecha a tela
            Navigator.pop(context, barcodes.first.rawValue);
          }
        },
      ),
    );
  }
}