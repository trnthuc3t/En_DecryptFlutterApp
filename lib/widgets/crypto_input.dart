import 'package:flutter/material.dart';

class CryptoInput extends StatelessWidget {
  final Function(String, String) onProcess;
  final bool isEncrypting;
  final VoidCallback onToggle;
  final bool showKeyInput;

  const CryptoInput({
    super.key,
    required this.onProcess,
    required this.isEncrypting,
    required this.onToggle,
    this.showKeyInput = true,
  });

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final keyController = TextEditingController();

    return Column(
      children: [
        TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: isEncrypting ? 'Văn Bản Gốc' : 'Văn Bản Mã Hóa',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        if (showKeyInput)
          TextField(
            controller: keyController,
            decoration: const InputDecoration(
              labelText: 'Khóa',
              border: OutlineInputBorder(),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => onProcess(textController.text, keyController.text),
              child: Text(isEncrypting ? 'Mã Hóa' : 'Giải Mã'),
            ),
            ElevatedButton(
              onPressed: onToggle,
              child: Text(isEncrypting ? 'Chuyển sang Giải Mã' : 'Chuyển sang Mã Hóa'),
            ),
          ],
        ),
      ],
    );
  }
}