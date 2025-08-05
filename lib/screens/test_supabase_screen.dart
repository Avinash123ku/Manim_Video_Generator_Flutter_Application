import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../services/supabase_service.dart';

class TestSupabaseScreen extends ConsumerStatefulWidget {
  const TestSupabaseScreen({super.key});

  @override
  ConsumerState<TestSupabaseScreen> createState() => _TestSupabaseScreenState();
}

class _TestSupabaseScreenState extends ConsumerState<TestSupabaseScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _testResult;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _testSupabaseConnection() async {
    try {
      setState(() {
        _testResult = 'Testing Supabase connection...';
      });

      // Test creating a session
      final sessionId = await SupabaseService.createChatSession();
      
      setState(() {
        _testResult = '✅ Session created: $sessionId';
      });

      // Test sending a message
      final response = await SupabaseService.sendMessage(
        message: 'Hello, this is a test message!',
        sessionId: sessionId,
      );

      setState(() {
        _testResult = '✅ Message sent successfully!\nResponse: ${response.toString()}';
      });

      // Test getting messages
      final messages = await SupabaseService.getMessages(sessionId);
      
      setState(() {
        _testResult = '✅ All tests passed!\nSession ID: $sessionId\nMessages: ${messages.length}';
      });

    } catch (e) {
      setState(() {
        _testResult = '❌ Test failed: $e';
      });
    }
  }

  Future<void> _sendTestMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatNotifier = ref.read(chatProvider.notifier);
    await chatNotifier.sendMessage(
      message: _messageController.text.trim(),
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Integration Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Connection Button
            ElevatedButton(
              onPressed: _testSupabaseConnection,
              child: const Text('Test Supabase Connection'),
            ),
            const SizedBox(height: 16),

            // Test Result
            if (_testResult != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult!.contains('✅') 
                      ? Colors.green.shade50 
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testResult!.contains('✅') 
                        ? Colors.green.shade200 
                        : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  _testResult!,
                  style: TextStyle(
                    color: _testResult!.contains('✅') 
                        ? Colors.green.shade800 
                        : Colors.red.shade800,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Chat Test Section
            const Text(
              'Chat Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Message Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a test message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: chatState.isLoading ? null : _sendTestMessage,
                  child: chatState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Messages Display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messages (${chatState.messages.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: message.isUser 
                                  ? Colors.blue.shade50 
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.isUser ? 'User' : 'Assistant',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(message.content),
                                if (message.videoUrl != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Video: ${message.videoUrl}',
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                if (message.status != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${message.status}',
                                    style: TextStyle(
                                      color: Colors.orange.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Error Display
            if (chatState.error != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'Error: ${chatState.error}',
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 