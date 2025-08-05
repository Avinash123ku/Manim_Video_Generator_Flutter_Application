class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? source;
  final String? pdfName;
  final String? extractedText;
  final String? animationPrompt;
  final String? videoUrl;
  final String? status;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.source,
    this.pdfName,
    this.extractedText,
    this.animationPrompt,
    this.videoUrl,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'pdfName': pdfName,
      'extractedText': extractedText,
      'animation_prompt': animationPrompt,
      'video_url': videoUrl,
      'status': status,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      source: json['source'],
      pdfName: json['pdfName'],
      extractedText: json['extractedText'],
      animationPrompt: json['animation_prompt'],
      videoUrl: json['video_url'],
      status: json['status'],
    );
  }

  // Factory method for Supabase JSON format
  factory ChatMessage.fromSupabaseJson(Map<String, dynamic> json) {
    print('📝 [MESSAGE] Creating ChatMessage from Supabase JSON:');
    print('📝 [MESSAGE]   - ID: ${json['id']}');
    print('📝 [MESSAGE]   - Role: ${json['role']}');
    print('📝 [MESSAGE]   - Content length: ${json['content']?.length ?? 0}');
    print('📝 [MESSAGE]   - Video URL: ${json['video_url']}');
    print('📝 [MESSAGE]   - Status: ${json['status']}');
    print('📝 [MESSAGE]   - Animation prompt present: ${json['animation_prompt'] != null}');
    
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['role'] == 'user',
      timestamp: DateTime.parse(json['created_at']),
      source: json['source'],
      pdfName: json['pdf_name'],
      extractedText: json['extracted_text'],
      animationPrompt: json['animation_prompt'],
      videoUrl: json['video_url'],
      status: json['status'],
    );
  }
}