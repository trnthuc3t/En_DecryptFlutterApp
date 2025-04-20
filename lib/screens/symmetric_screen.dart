import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/crypto_service.dart';

class ManHinhDoiXung extends StatefulWidget {
  const ManHinhDoiXung({super.key});

  @override
  State<ManHinhDoiXung> createState() => _ManHinhDoiXungState();
}

class _ManHinhDoiXungState extends State<ManHinhDoiXung> {
  final DichVuMaHoa _dichVuMaHoa = DichVuMaHoa();
  final _aliceKeyController = TextEditingController();
  final _alicePlaintextController = TextEditingController();
  final _bobKeyController = TextEditingController();
  final _bobCiphertextController = TextEditingController();
  final _eveKeyController = TextEditingController();
  final _eveCiphertextController = TextEditingController();
  String _aliceCiphertext = '';
  String _aliceIv = '';
  String _bobPlaintext = '';
  String _evePlaintext = '';
  Map<String, int> _plaintextFreq = {};
  Map<String, int> _ciphertextFreq = {};

  void _generateKey() {
    setState(() {
      _aliceKeyController.text = _dichVuMaHoa.taoKhoaNgauNhien();
      _aliceCiphertext = '';
      _aliceIv = '';
      _bobPlaintext = '';
      _evePlaintext = '';
      _plaintextFreq = {};
      _ciphertextFreq = {};
    });
  }

  void _encrypt() {
    if (_aliceKeyController.text.isEmpty || _alicePlaintextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập khóa và văn bản gốc')),
      );
      return;
    }
    try {
      final result = _dichVuMaHoa.maHoaAES(
        _alicePlaintextController.text,
        _aliceKeyController.text,
      );
      setState(() {
        _aliceCiphertext = result['ciphertext']!;
        _aliceIv = result['iv']!;
        _bobCiphertextController.text = _aliceCiphertext;
        _eveCiphertextController.text = _aliceCiphertext;
        _updateFrequencyAnalysis();
      });
    } catch (e) {
      setState(() {
        _aliceCiphertext = 'Lỗi: $e';
      });
    }
  }

  void _decryptBob() {
    if (_bobKeyController.text.isEmpty || _bobCiphertextController.text.isEmpty || _aliceIv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập khóa, văn bản mã hóa và đảm bảo đã mã hóa trước')),
      );
      return;
    }
    try {
      setState(() {
        _bobPlaintext = _dichVuMaHoa.giaiMaAES(
          _bobCiphertextController.text,
          _bobKeyController.text,
          _aliceIv,
        );
      });
    } catch (e) {
      setState(() {
        _bobPlaintext = 'Lỗi: $e';
      });
    }
  }

  void _decryptEve() {
    if (_eveKeyController.text.isEmpty || _eveCiphertextController.text.isEmpty || _aliceIv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập khóa, văn bản mã hóa và đảm bảo đã mã hóa trước')),
      );
      return;
    }
    try {
      setState(() {
        _evePlaintext = _dichVuMaHoa.giaiMaAES(
          _eveCiphertextController.text,
          _eveKeyController.text,
          _aliceIv,
        );
      });
    } catch (e) {
      setState(() {
        _evePlaintext = 'Lỗi: $e';
      });
    }
  }

  void _copyKey() {
    Clipboard.setData(ClipboardData(text: _aliceKeyController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép khóa')),
    );
  }

  void _pasteKey() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _bobKeyController.text = clipboardData.text!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có dữ liệu để dán')),
      );
    }
  }

  void _updateFrequencyAnalysis() {
    _plaintextFreq = _calculateFrequency(_alicePlaintextController.text);
    _ciphertextFreq = _calculateFrequency(_aliceCiphertext);
  }

  Map<String, int> _calculateFrequency(String text) {
    final freq = <String, int>{};
    for (var char in text.toLowerCase().split('')) {
      if (char.isNotEmpty && RegExp(r'[a-z0-9]').hasMatch(char)) {
        freq[char] = (freq[char] ?? 0) + 1;
      }
    }
    return freq;
  }

  @override
  void dispose() {
    _aliceKeyController.dispose();
    _alicePlaintextController.dispose();
    _bobKeyController.dispose();
    _bobCiphertextController.dispose();
    _eveKeyController.dispose();
    _eveCiphertextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã Hóa Đối Xứng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alice
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Người Gửi (Alice)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _aliceKeyController,
                      decoration: InputDecoration(
                        labelText: 'Khóa Chia Sẻ',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: _copyKey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _generateKey, child: const Text('Tạo Khóa Ngẫu Nhiên')),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _alicePlaintextController,
                      decoration: const InputDecoration(labelText: 'Văn Bản Gốc Cho Bob', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _encrypt, child: const Text('Mã Hóa')),
                    const SizedBox(height: 8),
                    Text('Văn Bản Mã Hóa: $_aliceCiphertext', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Bob
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Người Nhận (Bob)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _bobKeyController,
                      decoration: InputDecoration(
                        labelText: 'Khóa Chia Sẻ',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste, size: 20),
                          onPressed: _pasteKey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bobCiphertextController,
                      decoration: const InputDecoration(labelText: 'Văn Bản Mã Hóa Từ Alice', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _decryptBob, child: const Text('Giải Mã')),
                    const SizedBox(height: 8),
                    Text('Văn Bản Gốc: $_bobPlaintext', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Eve
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kẻ Nghe Lén (Eve)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _eveKeyController,
                      decoration: const InputDecoration(labelText: 'Khóa Bị Đánh Cắp', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _eveCiphertextController,
                      decoration: const InputDecoration(labelText: 'Văn Bản Mã Hóa Từ Alice', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _decryptEve, child: const Text('Giải Mã')),
                    const SizedBox(height: 8),
                    Text('Văn Bản Gốc: $_evePlaintext', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Frequency Analysis
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Phân Tích Tần Suất Ký Tự', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final chars = (_plaintextFreq.keys.toList() + _ciphertextFreq.keys.toList()).toSet().toList();
                                  if (value.toInt() < chars.length) {
                                    return Text(chars[value.toInt()]);
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          ),
                          barGroups: [
                            ..._plaintextFreq.entries.map((e) {
                              return BarChartGroupData(
                                x: (_plaintextFreq.keys.toList() + _ciphertextFreq.keys.toList()).toSet().toList().indexOf(e.key),
                                barRods: [BarChartRodData(toY: e.value.toDouble(), color: Colors.blue)],
                              );
                            }),
                            ..._ciphertextFreq.entries.map((e) {
                              return BarChartGroupData(
                                x: (_plaintextFreq.keys.toList() + _ciphertextFreq.keys.toList()).toSet().toList().indexOf(e.key),
                                barRods: [BarChartRodData(toY: e.value.toDouble(), color: Colors.red)],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const Text('Xanh: Văn bản gốc, Đỏ: Văn bản mã hóa'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}