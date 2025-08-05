import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../providers/pdf_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/pdf_viewer_widget.dart';
import '../widgets/chat_input_widget.dart';
import '../models/pdf_document.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final PdfDocument pdfDocument;

  const PdfViewerScreen({
    super.key,
    required this.pdfDocument,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  PDFViewController? _pdfController;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pdfState = ref.watch(pdfProvider);
    final pdfNotifier = ref.read(pdfProvider.notifier);
    final chatNotifier = ref.read(chatProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  // Title and File Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.pdfDocument.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${(widget.pdfDocument.size / 1024).toStringAsFixed(0)} kB',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search Button
                  IconButton(
                    icon: Icon(
                      _isSearchVisible ? Icons.close : Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = !_isSearchVisible;
                        if (!_isSearchVisible) {
                          _searchController.clear();
                          _searchQuery = '';
                        }
                      });
                    },
                  ),
                  // Gesture Mode Toggle
                  IconButton(
                    icon: Icon(
                      pdfState.isGestureMode
                          ? Icons.touch_app
                          : Icons.touch_app_outlined,
                      color:
                          pdfState.isGestureMode ? Colors.blue : Colors.white,
                      size: 24,
                    ),
                    onPressed: pdfNotifier.toggleGestureMode,
                    tooltip: 'Toggle Gesture Mode',
                  ),
                  // Help Button
                  IconButton(
                    icon: const Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      _showHelpDialog(context);
                    },
                  ),
                ],
              ),
            ),
            // Search Bar
            if (_isSearchVisible)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search in PDF...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    // TODO: Implement search functionality
                  },
                ),
              ),
            // Gesture Mode Indicator
            if (pdfState.isGestureMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gesture Mode: Draw to highlight and extract text',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () => pdfNotifier.toggleGestureMode(),
                    ),
                  ],
                ),
              ),
            // PDF Viewer
            Expanded(
              child: Stack(
                children: [
                  PdfViewerWidget(
                    pdfDocument: widget.pdfDocument,
                    isGestureMode: pdfState.isGestureMode,
                    onTextExtracted: pdfNotifier.setExtractedText,
                    onViewCreated: (controller) {
                      _pdfController = controller;
                    },
                    onPageChanged: (page, total) {
                      setState(() {
                        _currentPage = page;
                        _totalPages = total;
                      });
                    },
                  ),
                  // Page Navigation Controls
                  Positioned(
                    right: 16,
                    top: MediaQuery.of(context).size.height * 0.5 - 100,
                    child: Column(
                      children: [
                        // Page Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_currentPage/$_totalPages',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Navigation Buttons
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                ),
                                onPressed: _currentPage > 1
                                    ? () => _pdfController
                                        ?.setPage(_currentPage - 1)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                                onPressed: _currentPage < _totalPages
                                    ? () => _pdfController
                                        ?.setPage(_currentPage + 1)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Extracted Text Section
            if (pdfState.extractedText != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.text_snippet,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Extracted Text:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: pdfNotifier.clearExtractedText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pdfState.extractedText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            // Chat Input
            ChatInputWidget(
              onSendMessage: (message) {
                chatNotifier.sendMessage(
                  message: message,
                  context: pdfState.extractedText,
                  pdfName: widget.pdfDocument.name,
                  extractedText: pdfState.extractedText,
                );
                pdfNotifier.clearExtractedText();
              },
              initialText: pdfState.extractedText,
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'PDF Viewer Help',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Use the arrow buttons to navigate between pages',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• Tap the search icon to search within the PDF',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• Enable gesture mode to highlight and extract text',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '• Use the chat input to ask questions about the PDF',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
