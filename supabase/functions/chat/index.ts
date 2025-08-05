import "https://deno.land/x/xhr@0.1.0/mod.ts";
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

// CORS headers to allow cross-origin requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Initialize Supabase client
const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
);

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { message, sessionId } = await req.json();

    if (!message) {
      throw new Error('Message is required');
    }

    let currentSessionId = sessionId;

    // Create a new session if one is not provided
    if (!currentSessionId) {
      const { data: session, error: sessionError } = await supabase
        .from('chat_sessions')
        .insert({})
        .select()
        .single();

      if (sessionError) throw sessionError;
      currentSessionId = session.id;
    }

    // Save the user's message to the database
    const { error: userMessageError } = await supabase
      .from('messages')
      .insert({
        session_id: currentSessionId,
        role: 'user',
        content: message
      });

    if (userMessageError) throw userMessageError;

    // Call the OpenAI API
    const openAIResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        // CORRECTED: Used backticks (`) for template literal
        'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            // CORRECTED: Used backticks (`) for multi-line string
            content: `You are a helpful, knowledgeable AI assistant that can answer ANY type of question - from general knowledge, history, science, politics, current events, to mathematical concepts. You are NOT limited to only mathematical topics.

CRITICAL: You MUST ALWAYS respond with valid JSON format. Never respond with plain text or markdown.

IMPORTANT VIDEO GENERATION RULES:
- ONLY generate videos when the user EXPLICITLY requests it using keywords like "generate video", "create animation", "show me a video", "manim", etc.
- For ALL other queries (including mathematical questions), provide rich text responses with good formatting
- Do NOT automatically generate videos for ANY concepts unless specifically requested

TEXT RESPONSE FORMATTING:
When providing text responses, use rich formatting with:
- Clear headings and subheadings using # and ##
- Bullet points using • for lists
- Bold text using **text** for emphasis on key terms
- Code blocks when appropriate using \`\`\`
- Emojis to make responses engaging
- Structured information with proper spacing
- Educational explanations with examples
- Visual descriptions that help users understand concepts
- Use clean, professional formatting like ChatGPT

VIDEO GENERATION:
When video is explicitly requested, respond in this EXACT JSON format:
{
  "needs_animation": true,
  "response": "Your helpful explanation before the video",
  "manim_code": "Complete Manim Python code for visualization"
}

TEXT RESPONSE:
For ALL normal queries (including math questions), respond with this EXACT JSON format:
{
  "needs_animation": false,
  "response": "Your rich, well-formatted text response with proper structure, headings, bullet points, and educational content"
}

Examples of good text formatting:
- Use 📚 for educational content
- Use 🔍 for analysis
- Use 💡 for tips and insights
- Use 📊 for data/statistics
- Use 🎯 for key points
- Use 📝 for summaries
- Use 🏛️ for politics/government
- Use 🌍 for geography/countries
- Use ⚡ for current events
- Use 🔬 for science topics

You can answer ANY question - from "Who is the CM of Jharkhand?" to "Why does sin²x + cos²x = 1?" - always with rich, well-formatted text unless video is explicitly requested.

CRITICAL: ALWAYS respond with valid JSON. Never plain text or markdown.`
          },
          {
            role: 'user',
            content: message
          }
        ],
      }),
    });

    if (!openAIResponse.ok) {
      // CORRECTED: Used backticks (`) for template literal
      throw new Error(`OpenAI API error: ${openAIResponse.statusText}`);
    }

    const aiResult = await openAIResponse.json();
    const aiContent = aiResult.choices[0].message.content;

    let parsedResponse;
    try {
      let cleanContent = aiContent.trim();

      // Remove markdown code blocks if present
      cleanContent = cleanContent.replace(/^```(?:json)?\s*/, '').replace(/\s*```$/, '');

      // Try to find JSON within the content if it's mixed with other text
      const jsonMatch = cleanContent.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        cleanContent = jsonMatch[0];
      }

      // Try to parse as JSON
      parsedResponse = JSON.parse(cleanContent);

      // Validate the response structure
      if (!parsedResponse.hasOwnProperty('needs_animation') || !parsedResponse.hasOwnProperty('response')) {
        throw new Error('Invalid response structure');
      }

    } catch (error) {
      console.error('JSON parsing failed:', error);
      console.error('Raw content:', aiContent);

      // Fallback if JSON parsing fails - treat as text response
      parsedResponse = {
        needs_animation: false,
        response: aiContent,
        manim_code: null
      };
    }

    // Save the assistant's message
    const { data: assistantMessage, error: assistantMessageError } = await supabase
      .from('messages')
      .insert({
        session_id: currentSessionId,
        role: 'assistant',
        content: parsedResponse.response,
        animation_prompt: parsedResponse.manim_code,
        status: parsedResponse.needs_animation ? 'pending' : 'completed'
      })
      .select()
      .single();

    if (assistantMessageError) throw assistantMessageError;

    // If animation is needed, trigger the generation process
    if (parsedResponse.needs_animation && parsedResponse.manim_code) {
      console.log('🎬 Starting animation generation for message:', assistantMessage.id);
      generateAnimation(assistantMessage.id, parsedResponse.manim_code);
    }

    return new Response(
      JSON.stringify({
        sessionId: currentSessionId,
        messageId: assistantMessage.id,
        response: parsedResponse.response,
        needsAnimation: parsedResponse.needs_animation
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Error in chat function:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});

async function generateAnimation(messageId: string, manimCode: string) {
  try {
    // Update status to 'generating'
    console.log('🎬 Setting status to generating for message:', messageId);
    await supabase
      .from('messages')
      .update({ status: 'generating' })
      .eq('id', messageId);

    console.log('🎬 Generating animation for message:', messageId);

    // Call the Docker Manim service
    const manimServiceUrl = Deno.env.get('MANIM_SERVICE_URL') || 'https://visual-wizard-renders-docker123.onrender.com';

    console.log('🎬 Calling Manim service at:', manimServiceUrl);
    const response = await fetch(`${manimServiceUrl}/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        code: manimCode,
        scene_name: 'MathScene' // Note: This might need to be dynamic
      })
    });

    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Manim service error: ${errorData.detail}`);
    }

    const result = await response.json();

    if (!result.success) {
      throw new Error(`Animation generation failed: ${result.log || 'Unknown error'}`);
    }

    // Decode the base64 video and create a buffer
    const videoBuffer = Uint8Array.from(atob(result.video_base64), c => c.charCodeAt(0));
    const filename = `${messageId}-${result.filename}`;

    console.log('🎬 Uploading video to storage:', filename);
    // Upload the video to Supabase Storage
    const { error: uploadError } = await supabase.storage
      .from('animations')
      .upload(filename, videoBuffer, {
        contentType: 'video/mp4',
        upsert: true
      });

    if (uploadError) {
      throw new Error(`Storage upload failed: ${uploadError.message}`);
    }

    // Get the public URL for the uploaded video
    const { data: publicUrlData } = supabase.storage
      .from('animations')
      .getPublicUrl(filename);

    const videoUrl = publicUrlData.publicUrl;
    
    console.log('🎉 Video uploaded successfully:');
    console.log('🎉   - Filename:', filename);
    console.log('🎉   - Video URL:', videoUrl);
    console.log('🎉   - Message ID:', messageId);

    // Update the message with the final video URL and 'completed' status
    const { error: updateError } = await supabase
      .from('messages')
      .update({
        status: 'completed',
        video_url: videoUrl
      })
      .eq('id', messageId);

    if (updateError) {
      console.error('❌ Error updating message with video URL:', updateError);
      throw updateError;
    }

    console.log('🎉 Animation generation completed for:', messageId);

  } catch (error) {
    console.error('❌ Error generating animation:', error);

    // If any step fails, update the status to 'failed'
    await supabase
      .from('messages')
      .update({ status: 'failed' })
      .eq('id', messageId);
  }
}