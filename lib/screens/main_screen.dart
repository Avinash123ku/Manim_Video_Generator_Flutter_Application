import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'general_chat_screen.dart';
import 'pdf_interaction_screen.dart';
import 'history_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const GeneralChatScreen(),
    const PdfInteractionScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0A0A),
              const Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Clean header like Perplexity
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Profile icon (left side like Perplexity)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // App title
                    const Text(
                      'chat pdf app',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    // Settings icon (right side like Perplexity)
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: _screens[_currentIndex],
              ),
              // Clean bottom navigation like Perplexity
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.search_rounded,
                      label: 'Search',
                      isActive: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),
                    _buildNavItem(
                      icon: Icons.description_rounded,
                      label: 'PDF Reader',
                      isActive: _currentIndex == 1,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    _buildNavItem(
                      icon: Icons.history_rounded,
                      label: 'History',
                      isActive: _currentIndex == 2,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      onTap: onTap,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
