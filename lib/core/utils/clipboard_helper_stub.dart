import 'package:flutter/services.dart';

void copyTextToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
}
