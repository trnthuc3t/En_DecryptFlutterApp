import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaesarScreen extends StatefulWidget {
  const CaesarScreen({super.key});

  @override
  State<CaesarScreen> createState() => _CaesarScreenState();
}

class _CaesarScreenState extends State<CaesarScreen> {
  final _textController = TextEditingController();
  final _shiftController = TextEditingController();
  String _result = '';

  String _caesarCipher(String text, int shift, bool encrypt) {
    text = text.toUpperCase();
    String result = '';
    shift = encrypt ? shift : -shift;

    for (var char in text.runes) {
      if (char >= 65 && char <= 90) { // Chỉ xử lý chữ cái A-Z
        int shifted = (char - 65 + shift) % 26;
        if (shifted < 0) shifted += 26;
        result += String.fromCharCode(shifted + 65);
      } else {
        result += String.fromCharCode(char);
      }
    }
    return result;
  }

  void _encrypt() {
    final text = _textController.text;
    final shiftText = _shiftController.text;
    if (text.isEmpty || shiftText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản và số dịch chuyển')),
      );
      return;
    }
    final shift = int.tryParse(shiftText);
    if (shift == null || shift < 1 || shift > 26) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số dịch chuyển phải từ 1 đến 26')),
      );
      return;
    }
    setState(() {
      _result = _caesarCipher(text, shift, true);
    });
  }

  void _decrypt() {
    final text = _textController.text;
    final shiftText = _shiftController.text;
    if (text.isEmpty || shiftText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản và số dịch chuyển')),
      );
      return;
    }
    final shift = int.tryParse(shiftText);
    if (shift == null || shift < 1 || shift > 26) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số dịch chuyển phải từ 1 đến 26')),
      );
      return;
    }
    setState(() {
      _result = _caesarCipher(text, shift, false);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã Hóa Caesar'),
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
              controller: _shiftController,
              decoration: const InputDecoration(
                labelText: 'Số Dịch Chuyển (1-26)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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