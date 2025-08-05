#!/bin/bash

echo "🚀 Chat PDF App - Quick Start Script"
echo "====================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

echo "✅ Prerequisites check passed!"

# Start Docker service
echo "🐳 Starting Docker Manim service..."
cd docker
docker-compose up --build -d
cd ..

# Wait for Docker service to be ready
echo "⏳ Waiting for Docker service to be ready..."
sleep 10

# Check if Docker service is running
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ Docker service is running at http://localhost:8000"
else
    echo "⚠️  Docker service might not be ready yet. Check with: docker-compose logs"
fi

# Install Flutter dependencies
echo "📱 Installing Flutter dependencies..."
flutter pub get

# Check if Supabase CLI is installed
if command -v supabase &> /dev/null; then
    echo "🗄️  Supabase CLI found. You can run:"
    echo "   supabase login"
    echo "   supabase link --project-ref lohnajutfpglpdzywzuf"
    echo "   supabase db push"
else
    echo "📦 Install Supabase CLI: npm install -g supabase"
fi

echo ""
echo "🎉 Setup complete! Next steps:"
echo ""
echo "1. Configure Supabase environment variables:"
echo "   - OPENAI_API_KEY"
echo "   - MANIM_SERVICE_URL=http://localhost:8000"
echo ""
echo "2. Update Flutter app with your Supabase credentials"
echo ""
echo "3. Run the Flutter app:"
echo "   flutter run"
echo ""
echo "4. Test the complete flow:"
echo "   - Select a PDF with mathematical content"
echo "   - Send a mathematical query"
echo "   - Check animation generation"
echo ""
echo "📚 For detailed setup instructions, see SETUP.md" 