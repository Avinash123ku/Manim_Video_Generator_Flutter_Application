import 'package:flutter/material.dart';

class RichTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;

  const RichTextWidget({
    super.key,
    required this.text,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      // Check for headings
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 12),
            child: Text(
              line.substring(2),
              style: (baseStyle ?? const TextStyle()).copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              line.substring(3),
              style: (baseStyle ?? const TextStyle()).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: Text(
              line.substring(4),
              style: (baseStyle ?? const TextStyle()).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.95),
                height: 1.4,
              ),
            ),
          ),
        );
      }
      // Check for bullet points
      else if (line.startsWith('• ') ||
          line.startsWith('- ') ||
          line.startsWith('* ')) {
        final bulletText = line.substring(2);

        // Check if bullet text contains bold formatting
        if (bulletText.contains('**')) {
          final parts = bulletText.split('**');
          final textSpans = <TextSpan>[];

          for (int j = 0; j < parts.length; j++) {
            if (j % 2 == 1) {
              // Bold part
              textSpans.add(
                TextSpan(
                  text: parts[j],
                  style: (baseStyle ?? const TextStyle()).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              );
            } else {
              // Regular text part
              textSpans.add(
                TextSpan(
                  text: parts[j],
                  style: (baseStyle ?? const TextStyle()).copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              );
            }
          }

          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 6, bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(children: textSpans),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Regular bullet point without bold formatting
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 6, bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bulletText,
                      style: (baseStyle ?? const TextStyle()).copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
      // Check for numbered lists
      else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        final match = RegExp(r'^(\d+)\.\s(.+)$').firstMatch(line);
        if (match != null) {
          final listText = match.group(2)!;

          // Check if list text contains bold formatting
          if (listText.contains('**')) {
            final parts = listText.split('**');
            final textSpans = <TextSpan>[];

            for (int j = 0; j < parts.length; j++) {
              if (j % 2 == 1) {
                // Bold part
                textSpans.add(
                  TextSpan(
                    text: parts[j],
                    style: (baseStyle ?? const TextStyle()).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                );
              } else {
                // Regular text part
                textSpans.add(
                  TextSpan(
                    text: parts[j],
                    style: (baseStyle ?? const TextStyle()).copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                );
              }
            }

            widgets.add(
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 6, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2, right: 12),
                      child: Text(
                        '${match.group(1)}.',
                        style: (baseStyle ?? const TextStyle()).copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(children: textSpans),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Regular numbered list without bold formatting
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 6, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2, right: 12),
                      child: Text(
                        '${match.group(1)}.',
                        style: (baseStyle ?? const TextStyle()).copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        listText,
                        style: (baseStyle ?? const TextStyle()).copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      }
      // Check for code blocks
      else if (line.startsWith('```')) {
        // Find the end of the code block
        int endIndex = i + 1;
        while (endIndex < lines.length && !lines[endIndex].startsWith('```')) {
          endIndex++;
        }

        if (endIndex < lines.length) {
          final codeLines = lines.sublist(i + 1, endIndex);
          widgets.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                codeLines.join('\n'),
                style: const TextStyle(
                  color: Color(0xFFE6E6E6),
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          );
          i = endIndex; // Skip the processed lines
        }
      }
      // Check for inline code
      else if (line.contains('`')) {
        final parts = line.split('`');
        final textSpans = <TextSpan>[];

        for (int j = 0; j < parts.length; j++) {
          if (j % 2 == 1) {
            // Code part
            textSpans.add(
              TextSpan(
                text: parts[j],
                style: TextStyle(
                  backgroundColor: const Color(0xFF2D2D2D),
                  color: const Color(0xFFE6E6E6),
                  fontFamily: 'monospace',
                  fontSize: (baseStyle?.fontSize ?? 15) * 0.9,
                ),
              ),
            );
          } else {
            // Regular text part
            textSpans.add(
              TextSpan(
                text: parts[j],
                style: (baseStyle ?? const TextStyle()).copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            );
          }
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: TextSpan(children: textSpans),
            ),
          ),
        );
      }
      // Check for bold text (text between **)
      else if (line.contains('**')) {
        final parts = line.split('**');
        final textSpans = <TextSpan>[];

        for (int j = 0; j < parts.length; j++) {
          if (j % 2 == 1) {
            // Bold part
            textSpans.add(
              TextSpan(
                text: parts[j],
                style: (baseStyle ?? const TextStyle()).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            );
          } else {
            // Regular text part
            textSpans.add(
              TextSpan(
                text: parts[j],
                style: (baseStyle ?? const TextStyle()).copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            );
          }
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RichText(
              text: TextSpan(children: textSpans),
            ),
          ),
        );
      }
      // Regular text
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              line,
              style: (baseStyle ?? const TextStyle()).copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
