import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RailFenceScreen extends StatefulWidget {
  const RailFenceScreen({super.key});

  @override
  State<RailFenceScreen> createState() => _RailFenceScreenState();
}

class _RailFenceScreenState extends State<RailFenceScreen> {
  final _textController = TextEditingController();
  final _keyController = TextEditingController();
  String _result = '';

  String _railFenceEncrypt(String text, int key) {
    if (key <= 1) return text;
    List<String> rails = List.generate(key, (_) => '');
    int row = 0;
    int step = 1;

    for (var char in text.runes) {
      rails[row] += String.fromCharCode(char);
      row += step;
      if (row == key - 1 || row == 0) step = -step;
    }

    return rails.join();
  }

  String _railFenceDecrypt(String text, int key) {
    if (key <= 1) return text;
    List<List<int>> rails = List.generate(key, (_) => []);
    int row = 0;
    int step = 1;

    // Tạo mẫu zigzag
    for (int i = 0; i < text.length; i++) {
      rails[row].add(i);
      row += step;
      if (row == key - 1 || row == 0) step = -step;
    }

    // Điền ký tự vào mẫu
    List<String> temp = List.generate(key, (_) => '');
    int pos = 0;
    for (int i = 0; i < key; i++) {
      for (int j = 0; j < rails[i].length; j++) {
        temp[i] += text[pos];
        pos++;
      }
    }

    // Đọc lại theo mẫu zigzag
    String result = '';
    row = 0;
    step = 1;
    List<int> indices = List.generate(key, (_) => 0);
    for (int i = 0; i < text.length; i++) {
      result += temp[row][indices[row]];
      indices[row]++;
      row += step;
      if (row == key - 1 || row == 0) step = -step;
    }

    return result;
  }

  void _encrypt() {
    final text = _textController.text;
    final keyText = _keyController.text;
    if (text.isEmpty || keyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản và số hàng')),
      );
      return;
    }
    final key = int.tryParse(keyText);
    if (key == null || key < 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số hàng phải là số dương')));
      return;
    }
    setState(() {
      _result = _railFenceEncrypt(text, key);
    });
  }

  void _decrypt() {
    final text = _textController.text;
    final keyText = _keyController.text;
    if (text.isEmpty || keyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản và số hàng')),
      );
      return;
    }
    final key = int.tryParse(keyText);
    if (key == null || key < 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số hàng phải là số dương')));
      return;
    }
    setState(() {
      _result = _railFenceDecrypt(text, key);
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
      appBar: AppBar(title: const Text('Mã Hóa Rail Fence')),
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
                labelText: 'Số Hàng',
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
            Text('Kết Quả: $_result', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
