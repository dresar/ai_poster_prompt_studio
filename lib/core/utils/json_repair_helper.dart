import 'dart:convert';

/// Helper to repair malformed or truncated JSON string from ChatGPT/Claude/Gemini.
class JsonRepairHelper {
  static String repair(String rawInput) {
    var text = rawInput.trim();

    // 1. Strip markdown code fences if present
    text = text.replaceAll(RegExp(r'^```json\s*', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'^```\s*'), '');
    text = text.replaceAll(RegExp(r'\s*```$'), '');
    text = text.trim();

    // 2. Extract substring starting from first '{' or '['
    final firstBrace = text.indexOf('{');
    final firstBracket = text.indexOf('[');
    int startIdx = -1;

    if (firstBrace != -1 && firstBracket != -1) {
      startIdx = firstBrace < firstBracket ? firstBrace : firstBracket;
    } else if (firstBrace != -1) {
      startIdx = firstBrace;
    } else if (firstBracket != -1) {
      startIdx = firstBracket;
    }

    if (startIdx != -1) {
      text = text.substring(startIdx);
    }

    // 3. Try standard jsonDecode first
    try {
      jsonDecode(text);
      return text;
    } catch (_) {}

    // 4. Clean trailing commas before closing braces/brackets
    text = text.replaceAll(RegExp(r',\s*\}'), '}');
    text = text.replaceAll(RegExp(r',\s*\]'), ']');

    try {
      jsonDecode(text);
      return text;
    } catch (_) {}

    // 5. Advanced Repair for Truncated JSON
    bool inString = false;
    bool isEscaped = false;
    final List<String> stack = [];
    final StringBuffer repaired = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (isEscaped) {
        isEscaped = false;
        repaired.write(char);
        continue;
      }

      if (char == '\\') {
        isEscaped = true;
        repaired.write(char);
        continue;
      }

      if (char == '"') {
        inString = !inString;
        repaired.write(char);
        continue;
      }

      if (!inString) {
        if (char == '{' || char == '[') {
          stack.add(char);
        } else if (char == '}' && stack.isNotEmpty && stack.last == '{') {
          stack.removeLast();
        } else if (char == ']' && stack.isNotEmpty && stack.last == '[') {
          stack.removeLast();
        }
      }

      repaired.write(char);
    }

    // If cut off inside a string, append closing quote
    if (inString) {
      repaired.write('"');
    }

    var result = repaired.toString().trim();

    // Strip trailing comma at the end
    result = result.replaceAll(RegExp(r',\s*$'), '');

    // Close open brackets/braces in reverse order
    while (stack.isNotEmpty) {
      final lastOpen = stack.removeLast();
      if (lastOpen == '{') {
        result += '}';
      } else if (lastOpen == '[') {
        result += ']';
      }
    }

    // Clean trailing commas after balance
    result = result.replaceAll(RegExp(r',\s*\}'), '}');
    result = result.replaceAll(RegExp(r',\s*\]'), ']');

    return result;
  }

  /// Merges multiple JSON string parts into a single unified JSON string.
  static String mergeParts(List<String> rawParts) {
    final Map<String, dynamic> merged = {};

    for (final raw in rawParts) {
      final text = raw.trim();
      if (text.isEmpty) continue;

      final cleaned = repair(text);
      try {
        final decoded = jsonDecode(cleaned);
        if (decoded is Map<String, dynamic>) {
          merged.addAll(decoded);
        } else if (decoded is Map) {
          decoded.forEach((key, value) {
            merged[key.toString()] = value;
          });
        }
      } catch (_) {}
    }

    if (merged.isNotEmpty) {
      return const JsonEncoder.withIndent('  ').convert(merged);
    }

    // Fallback if parts were not maps: concatenate repaired text
    final validParts = rawParts.map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    if (validParts.isEmpty) return '';
    if (validParts.length == 1) {
      return repair(validParts.first);
    }

    return repair(validParts.join('\n'));
  }
}
