# Flutter App - Supabase Integration Guide

This guide explains how your Flutter app is now integrated with Supabase and the complete AI + Animation pipeline.

## 🎯 What's New

Your Flutter app now connects to the same Supabase backend that powers your web application, enabling:

- **Real-time chat** with AI through Supabase Edge Functions
- **Mathematical animation generation** using the Docker Manim service
- **Session management** and chat history
- **Cross-platform compatibility** (Android, iOS, Web)

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │───▶│  Supabase Edge   │───▶│  OpenAI API     │
│                 │    │    Functions     │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         │                       ▼                       ▼
         │              ┌──────────────────┐    ┌─────────────────┐
         │              │  Docker Manim    │    │  Supabase DB    │
         │              │     Service      │    │   & Storage     │
         │              └──────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                        ┌──────────────────┐
                        │  Generated       │
                        │  Animations      │
                        └──────────────────┘
```

## 📱 Key Features

### 1. **Supabase Integration**
- Real-time chat with AI through Supabase Edge Functions
- Session management and persistence
- Automatic animation generation for mathematical queries

### 2. **Animation Support**
- Mathematical animations generated using Manim
- Video playback through browser (opens external)
- Animation status tracking (pending, generating, completed)

### 3. **Enhanced Chat Experience**
- Real-time message updates
- Animation prompts and video URLs
- Error handling and loading states

## 🔧 Setup Instructions

### 1. **Dependencies**
The following dependencies have been added to `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.3.4
  url_launcher: ^6.2.4
```

### 2. **Configuration**
Your Supabase credentials are configured in `lib/services/supabase_service.dart`:

```dart
static const String supabaseUrl = 'https://lohnajutfpglpdzywzuf.supabase.co';
static const String supabaseAnonKey = 'your_anon_key';
```

### 3. **Initialization**
Supabase is initialized in `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}
```

## 📁 File Structure

### New Files Added:
- `lib/services/supabase_service.dart` - Supabase client and API methods
- `lib/widgets/animation_player_widget.dart` - Video player widget
- `lib/screens/test_supabase_screen.dart` - Integration test screen

### Updated Files:
- `lib/models/chat_message.dart` - Added animation fields
- `lib/providers/chat_provider.dart` - Updated to use Supabase
- `lib/widgets/chat_message_widget.dart` - Added animation display
- `lib/main.dart` - Added Supabase initialization

## 🧪 Testing the Integration

### 1. **Test Screen**
Tap the bug icon (🐛) in the app bar to access the test screen.

### 2. **Test Features**
- **Connection Test**: Verify Supabase connectivity
- **Session Creation**: Test chat session management
- **Message Sending**: Test AI chat functionality
- **Animation Generation**: Test mathematical animation requests

### 3. **Test Commands**
Try these test messages:
- "Hello, how are you?"
- "Show me a sine wave"
- "Create an animation of a circle"
- "What is the derivative of x²?"

## 🔄 How It Works

### 1. **Message Flow**
```
User Input → Flutter App → Supabase Edge Function → OpenAI → Response
```

### 2. **Animation Flow**
```
Mathematical Query → AI Analysis → Manim Service → Video Generation → Storage
```

### 3. **Session Management**
- Each chat session is stored in Supabase
- Messages are linked to sessions
- History is preserved across app restarts

## 🎨 UI Components

### 1. **Chat Messages**
- User messages (blue background)
- Assistant messages (grey background)
- Animation indicators (loading/generated)

### 2. **Animation Player**
- Clickable video thumbnails
- Opens animations in browser
- Shows animation prompts

### 3. **Status Indicators**
- Loading states for message sending
- Animation generation progress
- Error messages and retry options

## 🚀 Usage Examples

### 1. **Basic Chat**
```dart
final chatNotifier = ref.read(chatProvider.notifier);
await chatNotifier.sendMessage(message: "Hello, AI!");
```

### 2. **Mathematical Query**
```dart
await chatNotifier.sendMessage(
  message: "Show me the graph of y = sin(x)",
);
```

### 3. **Check Animation Status**
```dart
final messages = ref.watch(chatProvider).messages;
final lastMessage = messages.last;
if (lastMessage.videoUrl != null) {
  // Animation is ready
}
```

## 🔍 Troubleshooting

### Common Issues:

1. **Connection Errors**
   - Check internet connectivity
   - Verify Supabase credentials
   - Ensure edge functions are deployed

2. **Animation Not Generating**
   - Check Docker service is running
   - Verify OpenAI API key in Supabase
   - Check animation service URL

3. **Video Not Playing**
   - Ensure video URL is accessible
   - Check browser permissions
   - Verify storage bucket permissions

### Debug Steps:
1. Use the test screen to verify connectivity
2. Check Supabase dashboard for errors
3. Monitor edge function logs
4. Test Docker service independently

## 📊 Performance Tips

1. **Message Caching**
   - Messages are cached locally
   - Reduces API calls for repeated queries

2. **Animation Optimization**
   - Videos are generated on-demand
   - Consider implementing video caching

3. **Error Handling**
   - Graceful fallbacks for failed requests
   - User-friendly error messages

## 🔮 Future Enhancements

1. **Native Video Player**
   - Integrate video_player package
   - In-app video playback

2. **Offline Support**
   - Local message storage
   - Sync when online

3. **Real-time Updates**
   - WebSocket connections
   - Live animation status updates

4. **Advanced Animations**
   - Interactive mathematical plots
   - 3D visualizations

## 📚 Resources

- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart)
- [Flutter Riverpod Guide](https://riverpod.dev/)
- [Manim Documentation](https://docs.manim.community/)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)

## 🎉 Success!

Your Flutter app is now fully integrated with the same powerful backend as your web application. You can:

- Chat with AI about mathematical concepts
- Generate beautiful mathematical animations
- Maintain chat history across sessions
- Enjoy a seamless cross-platform experience

The integration maintains the same high-quality experience as your web app while providing native mobile functionality! 