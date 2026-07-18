import 'package:flutter/material.dart';
import '../../core/theme/neo_theme.dart';

class NeoTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool isObscure;
  final int maxLines;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;

  const NeoTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.isObscure = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  void _showExpandedModal(BuildContext context) {
    final tempController = TextEditingController(text: controller.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: NeoTheme.bgBase,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 2.5),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📝 Edit $label',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: NeoTheme.accentPink,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: tempController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.4),
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                controller.text = tempController.text;
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: NeoTheme.accentGreen,
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            if (maxLines > 1)
              GestureDetector(
                onTap: () => _showExpandedModal(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Row(
                    children: [
                      Icon(Icons.fullscreen, size: 16, color: Colors.black),
                      SizedBox(width: 4),
                      Text(
                        'Perbesar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: NeoTheme.neoBoxDecoration(
            color: Colors.white,
            borderRadius: 16.0,
            hasShadow: false,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isObscure,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: NeoTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: const BorderSide(
                  color: NeoTheme.borderStrong,
                  width: NeoTheme.borderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: const BorderSide(
                  color: NeoTheme.borderStrong,
                  width: NeoTheme.borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: const BorderSide(
                  color: NeoTheme.accentPink,
                  width: NeoTheme.borderWidth,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: NeoTheme.borderWidth,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: NeoTheme.borderWidth,
                ),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}
