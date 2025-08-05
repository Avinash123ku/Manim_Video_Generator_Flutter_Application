# Manim Animation Service for Chat PDF App

This Docker service generates mathematical animations for the Chat PDF Flutter app using Manim.

## Architecture

```
Flutter App → Supabase Edge Functions → OpenAI → Docker Manim Service → Supabase Storage
```

## Quick Setup

1. **Build and run locally:**
```bash
cd docker
docker-compose up --build
```

2. **Test the service:**
```bash
curl -X POST http://localhost:8000/generate \
  -H "Content-Type: application/json" \
  -d '{
    "code": "from manim import *\n\nclass MathScene(Scene):\n    def construct(self):\n        axes = Axes()\n        func = axes.plot(lambda x: np.sin(3*x), color=BLUE)\n        self.play(Create(axes), Create(func))",
    "scene_name": "MathScene"
  }'
```

3. **Deploy to cloud:**
   - Railway: `railway up`
   - Render: Connect GitHub repo
   - DigitalOcean: Use App Platform
   - AWS ECS: Use container registry

4. **Configure Supabase:**
   - Add `MANIM_SERVICE_URL` environment variable in Supabase dashboard
   - Point to your deployed service URL
   - Update the chat function to use the correct service URL

## Environment Variables

- `MANIM_SERVICE_URL`: URL of your deployed Manim service (set in Supabase Edge Functions)
- `OPENAI_API_KEY`: OpenAI API key for AI processing

## Integration with Flutter App

The Flutter app communicates with this service through Supabase Edge Functions:

1. User sends mathematical query in Flutter app
2. Supabase `chat` function analyzes with OpenAI
3. If animation needed, calls this Manim service
4. Generated video stored in Supabase storage
5. Video URL returned to Flutter app

## Supported Features

- Mathematical functions and graphs
- Geometric shapes and transformations
- LaTeX mathematical expressions
- Custom animations and scenes
- PDF text extraction and mathematical analysis

## Performance Tips

- Use `-pql` flag for faster generation (preview quality, low resolution)
- Implement caching for repeated animations
- Consider using GPU acceleration for complex animations
- Set appropriate timeouts for animation generation