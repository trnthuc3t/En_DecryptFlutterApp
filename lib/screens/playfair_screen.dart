import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayfairScreen extends StatefulWidget {
  const PlayfairScreen({super.key});

  @override
  State<PlayfairScreen> createState() => _PlayfairScreenState();
}

class _PlayfairScreenState extends State<PlayfairScreen> {
  final _textController = TextEditingController();
  final _keyController = TextEditingController();
  String _result = '';

  List<List<String>> _generateMatrix(String key) {
    List<String> matrix = [];
    String alphabet = 'ABCDEFGHIKLMNOPQRSTUVWXYZ'; // Bỏ J, thay bằng I
    key = key.toUpperCase().replaceAll('J', 'I');

    // Tạo ma trận từ khóa
    for (var char in key.runes) {
      String c = String.fromCharCode(char);
      if (!matrix.contains(c) && c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 90) {
        matrix.add(c);
      }
    }

    // Thêm các chữ cái còn lại
    for (var char in alphabet.runes) {
      String c = String.fromCharCode(char);
      if (!matrix.contains(c)) {
        matrix.add(c);
      }
    }

    // Chuyển thành ma trận 5x5
    List<List<String>> result = [];
    for (int i = 0; i < 5; i++) {
      result.add(matrix.sublist(i * 5, (i + 1) * 5));
    }
    return result;
  }

  List<int> _findPosition(String char, List<List<String>> matrix) {
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        if (matrix[i][j] == char) return [i, j];
      }
    }
    return [0, 0];
  }

  String _playfairCipher(String text, String key, bool encrypt) {
    text = text.toUpperCase().replaceAll('J', 'I');
    text = text.replaceAll(RegExp(r'[^A-Z]'), ''); // Bỏ ký tự không phải chữ cái
    List<List<String>> matrix = _generateMatrix(key);

    // Chuẩn bị cặp ký tự
    List<String> pairs = [];
    for (int i = 0; i < text.length; i += 2) {
      String first = text[i];
      String second = (i + 1 < text.length) ? text[i + 1] : 'X';
      if (first == second) {
        second = 'X';
        i--;
      }
      pairs.add(first + second);
    }

    String result = '';
    int shift = encrypt ? 1 : -1;

    for (var pair in pairs) {
      var pos1 = _findPosition(pair[0], matrix);
      var pos2 = _findPosition(pair[1], matrix);
      int row1 = pos1[0], col1 = pos1[1];
      int row2 = pos2[0], col2 = pos2[1];

      if (row1 == row2) {
        col1 = (col1 + shift) % 5;
        col2 = (col2 + shift) % 5;
        if (col1 < 0) col1 += 5;
        if (col2 < 0) col2 += 5;
        result += matrix[row1][col1] + matrix[row2][col2];
      } else if (col1 == col2) {
        row1 = (row1 + shift) % 5;
        row2 = (row2 + shift) % 5;
        if (row1 < 0) row1 += 5;
        if (row2 < 0) row2 += 5;
        result += matrix[row1][col1] + matrix[row2][col2];
      } else {
        result += matrix[row1][col2] + matrix[row2][col1];
      }
    }

    return result;
  }

  bool _hasDuplicateLetters(String key) {
    key = key.toUpperCase();
    Set<String> seen = {};
    for (var char in key.runes) {
      String c = String.fromCharCode(char);
      if (!seen.add(c)) return true;
    }
    return false;
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
    if (_hasDuplicateLetters(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khóa không được chứa chữ cái lặp lại')),
      );
      return;
    }
    setState(() {
      _result = _playfairCipher(text, key, true);
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
    if (_hasDuplicateLetters(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khóa không được chứa chữ cái lặp lại')),
      );
      return;
    }
    setState(() {
      _result = _playfairCipher(text, key, false);
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
        title: const Text('Mã Hóa Playfair'),
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
                labelText: 'Khóa (Chữ Cái, Không Lặp)',
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