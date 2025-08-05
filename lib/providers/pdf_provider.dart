import 'dart:io';
import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pdf_document.dart';

final pdfProvider = StateNotifierProvider<PdfNotifier, PdfState>((ref) {
  return PdfNotifier();
});

class PdfState {
  final List<PdfDocument> pdfList;
  final PdfDocument? currentPdf;
  final bool isGestureMode;
  final String? extractedText;
  final bool isLoading;
  final String? error;

  PdfState({
    this.pdfList = const [],
    this.currentPdf,
    this.isGestureMode = false,
    this.extractedText,
    this.isLoading = false,
    this.error,
  });

  PdfState copyWith({
    List<PdfDocument>? pdfList,
    PdfDocument? currentPdf,
    bool? isGestureMode,
    String? extractedText,
    bool? isLoading,
    String? error,
  }) {
    return PdfState(
      pdfList: pdfList ?? this.pdfList,
      currentPdf: currentPdf ?? this.currentPdf,
      isGestureMode: isGestureMode ?? this.isGestureMode,
      extractedText: extractedText ?? this.extractedText,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PdfNotifier extends StateNotifier<PdfState> {
  PdfNotifier() : super(PdfState()) {
    loadPdfList();
  }

  Future<void> loadPdfList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pdfListJson = prefs.getStringList('pdf_list') ?? [];

      final List<PdfDocument> pdfList = [];
      for (final jsonString in pdfListJson) {
        try {
          final json = jsonDecode(jsonString);
          final pdf = PdfDocument.fromJson(json);
          // Check if file still exists
          if (await pdf.file.exists()) {
            pdfList.add(pdf);
          }
        } catch (e) {
          print('Error loading PDF from storage: $e');
        }
      }

      // Sort by upload date (newest first)
      pdfList.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      state = state.copyWith(pdfList: pdfList);
    } catch (e) {
      print('Error loading PDF list: $e');
    }
  }

  Future<void> savePdfList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pdfListJson =
          state.pdfList.map((pdf) => jsonEncode(pdf.toJson())).toList();
      await prefs.setStringList('pdf_list', pdfListJson);
    } catch (e) {
      print('Error saving PDF list: $e');
    }
  }

  Future<void> pickPdf() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      const typeGroup = XTypeGroup(
        label: 'PDFs',
        extensions: ['pdf'],
      );

      final XFile? result = await openFile(
        acceptedTypeGroups: [typeGroup],
      );

      if (result != null) {
        final file = File(result.path);
        final directory = await getApplicationDocumentsDirectory();
        final fileName = result.name;
        final newPath = '${directory.path}/$fileName';

        await file.copy(newPath);

        final newFile = File(newPath);
        final pdfDocument = PdfDocument(
          name: fileName,
          path: newPath,
          file: newFile,
          uploadedAt: DateTime.now(),
          size: await newFile.length(),
        );

        // Add to the beginning of the list (newest first)
        final updatedList = [pdfDocument, ...state.pdfList];

        state = state.copyWith(
          pdfList: updatedList,
          isLoading: false,
        );

        await savePdfList();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load PDF: $e',
      );
    }
  }

  void selectPdf(PdfDocument pdf) {
    state = state.copyWith(currentPdf: pdf);
  }

  void clearCurrentPdf() {
    state = state.copyWith(currentPdf: null, extractedText: null);
  }

  void removePdf(PdfDocument pdf) async {
    try {
      // Remove file from storage
      if (await pdf.file.exists()) {
        await pdf.file.delete();
      }

      // Remove from list
      final updatedList =
          state.pdfList.where((p) => p.path != pdf.path).toList();
      state = state.copyWith(pdfList: updatedList);

      // If this was the current PDF, clear it
      if (state.currentPdf?.path == pdf.path) {
        state = state.copyWith(currentPdf: null, extractedText: null);
      }

      await savePdfList();
    } catch (e) {
      print('Error removing PDF: $e');
    }
  }

  void toggleGestureMode() {
    state = state.copyWith(isGestureMode: !state.isGestureMode);
  }

  void setExtractedText(String text) {
    state = state.copyWith(extractedText: text);
  }

  void clearExtractedText() {
    state = state.copyWith(extractedText: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
