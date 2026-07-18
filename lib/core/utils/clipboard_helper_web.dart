import 'dart:html' as html;
import 'package:flutter/services.dart';

void copyTextToClipboard(String text) {
  try {
    final textarea = html.TextAreaElement();
    textarea.value = text;
    html.document.body?.append(textarea);
    textarea.select();
    html.document.execCommand('copy');
    textarea.remove();
  } catch (_) {
    // Fallback to Flutter default clipboard if document/execCommand fails
    Clipboard.setData(ClipboardData(text: text));
  }
}
