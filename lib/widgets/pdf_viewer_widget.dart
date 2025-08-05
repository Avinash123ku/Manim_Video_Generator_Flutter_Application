import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../models/pdf_document.dart';

class PdfViewerWidget extends StatefulWidget {
  final PdfDocument pdfDocument;
  final bool isGestureMode;
  final Function(String) onTextExtracted;
  final Function(PDFViewController)? onViewCreated;
  final Function(int, int)? onPageChanged;

  const PdfViewerWidget({
    super.key,
    required this.pdfDocument,
    required this.isGestureMode,
    required this.onTextExtracted,
    this.onViewCreated,
    this.onPageChanged,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  PDFViewController? _pdfController;
  final List<Offset> _gesturePoints = [];
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PDFView(
          filePath: widget.pdfDocument.path,
          enableSwipe: !widget.isGestureMode,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
          onRender: (pages) {
            // PDF rendered
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading PDF: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
          onPageError: (page, error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading page $page: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
          onViewCreated: (PDFViewController pdfViewController) {
            _pdfController = pdfViewController;
            widget.onViewCreated?.call(pdfViewController);
          },
          onPageChanged: (page, total) {
            if (page != null && total != null) {
              widget.onPageChanged?.call(page, total);
            }
          },
        ),
        if (widget.isGestureMode)
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDrawing = true;
                  _gesturePoints.clear();
                  _gesturePoints.add(details.localPosition);
                });
              },
              onPanUpdate: (details) {
                if (_isDrawing) {
                  setState(() {
                    _gesturePoints.add(details.localPosition);
                  });
                }
              },
              onPanEnd: (details) {
                setState(() {
                  _isDrawing = false;
                });
                _processGesture();
              },
              child: CustomPaint(
                painter: GesturePainter(
                  points: _gesturePoints,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _processGesture() {
    if (_gesturePoints.length < 3) return;

    // Simulate text extraction (in a real app, you'd use OCR or PDF text extraction)
    final extractedText = _simulateTextExtraction();
    
    if (extractedText.isNotEmpty) {
      widget.onTextExtracted(extractedText);
      setState(() {
        _gesturePoints.clear();
      });
    }
  }

  String _simulateTextExtraction() {
    // This is a simulation - in a real app, you would:
    // 1. Convert gesture coordinates to PDF coordinates
    // 2. Extract text from the selected region using a PDF library
    // 3. Or use OCR if the PDF doesn't have selectable text
    
    final sampleTexts = [
      'This is extracted text from the PDF document.',
      'Sample paragraph about machine learning algorithms.',
      'Important information highlighted by the user.',
      'Technical specification details from the document.',
      'Research findings and conclusions section.',
    ];
    
    return sampleTexts[DateTime.now().millisecond % sampleTexts.length];
  }
}

class GesturePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  GesturePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}