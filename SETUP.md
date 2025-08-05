# Chat PDF App - Complete Setup Guide

This guide covers the complete setup of your Chat PDF Flutter app with Docker and Supabase integration.

## 🏗️ Architecture Overview

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

## 📱 Flutter App Setup

### Prerequisites
- Flutter SDK 3.10.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code

### Installation
```bash
# Clone the repository
git clone <your-repo-url>
cd chat_pdf_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Key Features
- PDF file selection using `file_selector`
- Chat interface with mathematical analysis
- Animation generation for mathematical concepts
- History tracking and session management

## 🐳 Docker Setup

### Prerequisites
- Docker Desktop
- Docker Compose

### Local Development
```bash
cd docker

# Build and run the Manim service
docker-compose up --build

# The service will be available at http://localhost:8000
```

### Production Deployment

#### Option 1: Railway
```bash
# Install Railway CLI
npm install -g @railway/cli

# Deploy
railway login
railway up
```

#### Option 2: Render
1. Connect your GitHub repository
2. Create a new Web Service
3. Set build command: `pip install -r requirements.txt`
4. Set start command: `uvicorn app:app --host 0.0.0.0 --port $PORT`

#### Option 3: DigitalOcean App Platform
1. Create new app from GitHub
2. Select Docker container
3. Configure environment variables

## 🗄️ Supabase Setup

### Prerequisites
- Supabase account
- Supabase CLI (optional)

### Database Setup
```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref lohnajutfpglpdzywzuf

# Apply migrations
supabase db push
```

### Environment Variables
Set these in your Supabase dashboard:

```
OPENAI_API_KEY=your_openai_api_key
MANIM_SERVICE_URL=https://your-manim-service.railway.app
```

### Edge Functions
The edge functions are already configured:

- `chat/` - Main chat function with AI integration
- `get-messages/` - Retrieves chat messages

## 🔧 Configuration

### Flutter App Configuration
Update `lib/services/chat_service.dart` with your Supabase credentials:

```dart
const String supabaseUrl = 'https://lohnajutfpglpdzywzuf.supabase.co';
const String supabaseAnonKey = 'your_anon_key';
```

### Docker Service Configuration
The Docker service is configured to:
- Generate mathematical animations using Manim
- Accept POST requests with Manim code
- Return base64-encoded video files
- Handle timeouts and errors gracefully

### Supabase Database Schema
- `chat_sessions` - Stores chat conversations
- `messages` - Stores individual messages with animation data
- Storage bucket `animations` - Stores generated video files

## 🚀 Deployment Checklist

### Flutter App
- [ ] Update Supabase credentials
- [ ] Test file selection functionality
- [ ] Test chat interface
- [ ] Build APK/IPA for distribution

### Docker Service
- [ ] Deploy to cloud platform
- [ ] Set environment variables
- [ ] Test animation generation
- [ ] Configure CORS if needed

### Supabase
- [ ] Apply database migrations
- [ ] Set environment variables
- [ ] Deploy edge functions
- [ ] Test chat functionality
- [ ] Configure storage policies

## 🧪 Testing

### Test the Complete Flow
1. Start the Flutter app
2. Select a PDF with mathematical content
3. Send a mathematical query
4. Verify animation generation
5. Check video playback

### API Testing
```bash
# Test Manim service
curl -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{
    "code": "from manim import *\n\nclass TestScene(Scene):\n    def construct(self):\n        circle = Circle()\n        self.play(Create(circle))",
    "scene_name": "TestScene"
  }'

# Test Supabase chat function
curl -X POST https://lohnajutfpglpdzywzuf.supabase.co/functions/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Show me a sine wave"}'
```

## 🔍 Troubleshooting

### Common Issues

1. **Docker build fails**
   - Check Docker Desktop is running
   - Ensure sufficient disk space
   - Try `docker system prune`

2. **Supabase connection errors**
   - Verify project URL and keys
   - Check network connectivity
   - Ensure RLS policies are correct

3. **Animation generation fails**
   - Check Manim service is running
   - Verify OpenAI API key
   - Check service URL in Supabase

4. **Flutter app crashes**
   - Check file permissions
   - Verify Supabase credentials
   - Test with different PDF files

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [Manim Documentation](https://docs.manim.community/)
- [Docker Documentation](https://docs.docker.com/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License. 