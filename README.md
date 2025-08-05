# Flutter Chat PDF App

A sophisticated mobile application built with Flutter that enables intelligent conversations with PDF documents using gesture-based text extraction and AI-powered responses.

## Features

### 🗣️ General Chat
- Direct conversation with AI without document context
- Clean, intuitive chat interface
- Message history with timestamps
- Real-time typing indicators

### 📄 PDF Interaction
- Upload and view PDF documents
- **Gesture Mode**: Draw circles or highlight text to extract content
- Automatic text extraction from selected regions
- Smart mode switching between RAG and general LLM responses
- Visual feedback for gesture interactions

### 📚 History
- Persistent storage of all conversations
- Organized by PDF document and timestamp
- Shows extracted text and final prompts
- Source tracking (PDF vs General chat)

## Technical Architecture

### State Management
- **Riverpod** for reactive state management
- Separate providers for chat, PDF, and UI state
- Persistent storage using SharedPreferences

### PDF Processing
- **flutter_pdfview** for PDF rendering
- Custom gesture recognition for text selection
- Coordinate mapping for precise text extraction
- Offline PDF storage and management

### AI Integration
- OpenAI GPT integration with customizable endpoints
- Context-aware responses using RAG methodology
- Intelligent fallback to general LLM when needed
- Proper error handling and retry mechanisms

## Setup Instructions

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure API Key**
   Update the API key in `lib/services/chat_service.dart`:
   ```dart
   static const String apiKey = 'YOUR_OPENAI_API_KEY_HERE';
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Key Components

- **ChatService**: Handles AI communication with context switching
- **StorageService**: Manages persistent data storage
- **PdfViewerWidget**: Custom PDF viewer with gesture recognition
- **GesturePainter**: Custom painter for drawing selection indicators
- **Material Design 3**: Modern, accessible UI components

## Permissions Required

- File access for PDF uploads
- Storage permissions for document caching
- Network access for AI API calls

## Performance Optimizations

- Lazy loading of chat history
- Efficient PDF rendering with caching
- Debounced gesture processing
- Memory-conscious image handling