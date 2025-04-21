import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VigenereScreen extends StatefulWidget {
  const VigenereScreen({super.key});

  @override
  State<VigenereScreen> createState() => _VigenereScreenState();
}

class _VigenereScreenState extends State<VigenereScreen> {
  final _textController = TextEditingController();
  final _keyController = TextEditingController();
  String _result = '';

  String _vigenereCipher(String text, String key, bool encrypt) {
    text = text.toUpperCase();
    key = key.toUpperCase();
    String result = '';
    int keyIndex = 0;

    for (var char in text.runes) {
      if (char >= 65 && char <= 90) {
        int keyChar = key.runes.elementAt(keyIndex % key.length) - 65;
        int shift = encrypt ? keyChar : -keyChar;
        int shifted = (char - 65 + shift) % 26;
        if (shifted < 0) shifted += 26;
        result += String.fromCharCode(shifted + 65);
        keyIndex++;
      } else {
        result += String.fromCharCode(char);
      }
    }
    return result;
  }

  void _encrypt() {
    final text = _textController.text;
    final key = _keyController.text;
    if (text.isEmpty || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản và khóa')),
      );
      return;
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khóa chỉ được chứa chữ cái')),
      );
      return;
    }
    setState(() {
      _result = _vigenereCipher(text, key, true);
    });
  }

  void _decrypt() {
    final text = _textController.text;
    final key = _keyController.text;
    if (text.isEmpty || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản và khóa')),
      );
      return;
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khóa chỉ được chứa chữ cái')),
      );
      return;
    }
    setState(() {
      _result = _vigenereCipher(text, key, false);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã Hóa Vigenère'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Văn Bản',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Khóa (Chữ Cái)',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _encrypt,
                  child: const Text('Mã Hóa'),
                ),
                ElevatedButton(
                  onPressed: _decrypt,
                  child: const Text('Giải Mã'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Kết Quả: $_result',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}