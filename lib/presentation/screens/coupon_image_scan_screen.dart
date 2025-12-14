import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';

class CouponImageScanScreen extends StatefulWidget {
  const CouponImageScanScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  State<CouponImageScanScreen> createState() => _CouponImageScanScreenState();
}

class _CouponImageScanScreenState extends State<CouponImageScanScreen> {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  bool _isProcessing = true;
  String? _errorMessage;

  Size? _imageSize;
  List<TextElement> _textElements = [];
  List<Barcode> _barcodes = [];

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Load image to get its original size
      final file = File(widget.imagePath);
      final decoded = await decodeImageFromList(await file.readAsBytes());
      _imageSize = Size(
        decoded.width.toDouble(),
        decoded.height.toDouble(),
      );

      final inputImage = InputImage.fromFilePath(widget.imagePath);

      final recognizedText = await _textRecognizer.processImage(inputImage);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      final elements = recognizedText.blocks
          .expand((b) => b.lines)
          .expand((l) => l.elements)
          .toList();

      setState(() {
        _textElements = elements;
        _barcodes = barcodes;
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
        _errorMessage = 'Błąd przetwarzania obrazu: $e';
        _isProcessing = false;
      });
      }
    }
  }

  void _handleTap(TapDownDetails details, Size widgetSize) {
    if (_imageSize == null) return;

    final tap = details.localPosition;

    final scaleX = widgetSize.width / _imageSize!.width;
    final scaleY = widgetSize.height / _imageSize!.height;

    Rect scaleRect(Rect? r) {
      if (r == null) return Rect.zero;
      return Rect.fromLTRB(
        r.left * scaleX,
        r.top * scaleY,
        r.right * scaleX,
        r.bottom * scaleY,
      );
    }

    for (final barcode in _barcodes) {
      final rect = scaleRect(barcode.boundingBox);
      if (rect.contains(tap)) {
        final value = barcode.rawValue;
        if (value != null && value.isNotEmpty) {
          Navigator.of(context).pop(value);
        }
        return;
      }
    }

    for (final element in _textElements) {
      final rect = scaleRect(element.boundingBox);
      if (rect.contains(tap)) {
        final value = element.text.trim();
        if (value.isNotEmpty) {
          Navigator.of(context).pop(value);
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16,
                children: [
                  CustomIconButton(
                    icon: SvgPicture.asset('assets/icons/back.svg'),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: const Text(
                      'Zeskanuj kod z kuponu',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Itim',
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildImageWithOverlay(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Dotknij kod kreskowy, kod QR lub fragment tekstu, aby wypełnić pole kodu kuponu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontFamily: 'Itim',
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithOverlay() {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            color: AppColors.alertText,
            fontFamily: 'Itim',
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_isProcessing || _imageSize == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.textPrimary,),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageAspectRatio = _imageSize!.width / _imageSize!.height;

        double viewWidth = constraints.maxWidth;
        double viewHeight = viewWidth / imageAspectRatio;

        if (viewHeight > constraints.maxHeight) {
          viewHeight = constraints.maxHeight;
          viewWidth = viewHeight * imageAspectRatio;
        }

        final size = Size(viewWidth, viewHeight);

        return Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _handleTap(details, size),
            child: SizedBox(
              width: viewWidth,
              height: viewHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:AppColors.textPrimary,
                            offset: const Offset(6,6),
                            blurRadius: 0,
                            spreadRadius: 0,
                          ),
                        ]
                      ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: _DetectionPainter(
                      imageSize: _imageSize!,
                      textElements: _textElements,
                      barcodes: _barcodes,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetectionPainter extends CustomPainter {
  _DetectionPainter({
    required this.imageSize,
    required this.textElements,
    required this.barcodes,
  });

  final Size imageSize;
  final List<TextElement> textElements;
  final List<Barcode> barcodes;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    const double padding = 4.0;
    
    final Paint textPaint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint barcodePaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    Rect scaleRect(Rect? r) {
      if (r == null) return Rect.zero;
      return Rect.fromLTRB(
        r.left * scaleX,
        r.top * scaleY,
        r.right * scaleX,
        r.bottom * scaleY,
      );
    }

    Rect withPadding(Rect rect) {
      if (rect.isEmpty) return rect;
      return rect.inflate(padding);
    }

    for (final barcode in barcodes) {
      final rect = scaleRect(barcode.boundingBox);
      if (!rect.isEmpty) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(withPadding(rect), const Radius.circular(6)),
          barcodePaint,
        );
      }
    }

    for (final element in textElements) {
      final rect = scaleRect(element.boundingBox);
      if (!rect.isEmpty) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(withPadding(rect), const Radius.circular(4)),
          textPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize ||
        oldDelegate.textElements != textElements ||
        oldDelegate.barcodes != barcodes;
  }
}
