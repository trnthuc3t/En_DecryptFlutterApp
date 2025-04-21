import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart' as pc;
import '../services/crypto_service.dart';

class ManHinhBatDoiXung extends StatefulWidget {
  const ManHinhBatDoiXung({super.key});

  @override
  State<ManHinhBatDoiXung> createState() => _ManHinhBatDoiXungState();
}

class _ManHinhBatDoiXungState extends State<ManHinhBatDoiXung> {
  final DichVuMaHoa _dichVuMaHoa = DichVuMaHoa();
  final _alicePlaintextController = TextEditingController();
  final _bobCiphertextController = TextEditingController();
  final _eveCiphertextController = TextEditingController();
  final _evePrivateKeyController = TextEditingController();
  final _alicePrivateKeyController = TextEditingController();
  final _alicePublicKeyController = TextEditingController();
  final _bobPrivateKeyController = TextEditingController();
  final _bobPublicKeyController = TextEditingController();
  final _aliceReceivedBobPublicKeyController = TextEditingController();
  final _bobReceivedAlicePublicKeyController = TextEditingController();
  pc.RSAPrivateKey? _alicePrivateKey;
  pc.RSAPublicKey? _alicePublicKey;
  pc.RSAPrivateKey? _bobPrivateKey;
  pc.RSAPublicKey? _bobPublicKey;
  pc.RSAPublicKey? _aliceReceivedBobPublicKey;
  pc.RSAPublicKey? _bobReceivedAlicePublicKey;
  String _aliceCiphertext = '';
  String _bobPlaintext = '';
  String _evePlaintext = '';

  Future<void> _generateAliceKeys() async {
    try {
      final keys = await _dichVuMaHoa.taoCapKhoaRSA();
      setState(() {
        _alicePrivateKey = keys['khoaBiMat'] as pc.RSAPrivateKey;
        _alicePublicKey = keys['khoaCongKhai'] as pc.RSAPublicKey;
        _alicePrivateKeyController.text = keys['khoaBiMatStr'] as String;
        _alicePublicKeyController.text = keys['khoaCongKhaiStr'] as String;
        _aliceCiphertext = '';
        _bobPlaintext = '';
        _evePlaintext = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo cặp khóa: $e')),
      );
    }
  }

  Future<void> _generateBobKeys() async {
    try {
      final keys = await _dichVuMaHoa.taoCapKhoaRSA();
      setState(() {
        _bobPrivateKey = keys['khoaBiMat'] as pc.RSAPrivateKey;
        _bobPublicKey = keys['khoaCongKhai'] as pc.RSAPublicKey;
        _bobPrivateKeyController.text = keys['khoaBiMatStr'] as String;
        _bobPublicKeyController.text = keys['khoaCongKhaiStr'] as String;
        _bobPlaintext = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tạo cặp khóa: $e')),
      );
    }
  }

  void _sendPublicKeyToBob() {
    if (_alicePublicKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng tạo khóa của Alice trước')),
      );
      return;
    }
    setState(() {
      _bobReceivedAlicePublicKey = _alicePublicKey;
      _bobReceivedAlicePublicKeyController.text = _alicePublicKeyController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi khóa công khai của Alice cho Bob')),
    );
  }

  void _sendPublicKeyToAlice() {
    if (_bobPublicKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng tạo khóa của Bob trước')),
      );
      return;
    }
    setState(() {
      _aliceReceivedBobPublicKey = _bobPublicKey;
      _aliceReceivedBobPublicKeyController.text = _bobPublicKeyController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi khóa công khai của Bob cho Alice')),
    );
  }

  void _encrypt() {
    if (_alicePlaintextController.text.isEmpty || _aliceReceivedBobPublicKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản và nhận khóa công khai của Bob')),
      );
      return;
    }
    try {
      setState(() {
        _aliceCiphertext = _dichVuMaHoa.maHoaRSA(
          _alicePlaintextController.text,
          _aliceReceivedBobPublicKey!,
        );
        _bobCiphertextController.text = _aliceCiphertext;
        _eveCiphertextController.text = _aliceCiphertext;
      });
    } catch (e) {
      setState(() {
        _aliceCiphertext = 'Lỗi: $e';
      });
    }
  }

  void _decryptBob() {
    if (_bobCiphertextController.text.isEmpty || _bobPrivateKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản mã hóa và tạo khóa của Bob')),
      );
      return;
    }
    try {
      final plaintext = _dichVuMaHoa.giaiMaRSA(
        _bobCiphertextController.text,
        _bobPrivateKey!,
      );
      setState(() {
        _bobPlaintext = plaintext;
      });
    } catch (e) {
      setState(() {
        _bobPlaintext = 'Lỗi: $e';
      });
    }
  }

  void _decryptEve() {
    if (_eveCiphertextController.text.isEmpty || _evePrivateKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản mã hóa và khóa bí mật')),
      );
      return;
    }
    try {
      final plaintext = _dichVuMaHoa.giaiMaRSA(
        _eveCiphertextController.text,
        _bobPrivateKey!,
      );
      setState(() {
        _evePlaintext = plaintext;
      });
    } catch (e) {
      setState(() {
        _evePlaintext = 'Lỗi: Khóa không đúng hoặc văn bản mã hóa không hợp lệ';
      });
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép')),
    );
  }

  void _pasteText(TextEditingController controller) async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        controller.text = clipboardData.text!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có dữ liệu để dán')),
      );
    }
  }

  @override
  void dispose() {
    _alicePlaintextController.dispose();
    _bobCiphertextController.dispose();
    _eveCiphertextController.dispose();
    _evePrivateKeyController.dispose();
    _alicePrivateKeyController.dispose();
    _alicePublicKeyController.dispose();
    _bobPrivateKeyController.dispose();
    _bobPublicKeyController.dispose();
    _aliceReceivedBobPublicKeyController.dispose();
    _bobReceivedAlicePublicKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã Hóa Bất Đối Xứng'),
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
                      controller: _alicePrivateKeyController,
                      decoration: InputDecoration(
                        labelText: 'Khóa Bí Mật',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyText(_alicePrivateKeyController.text),
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _generateAliceKeys,
                      child: const Text('Tạo Cặp Khóa'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _alicePublicKeyController,
                      decoration: InputDecoration(
                        labelText: 'Khóa Công Khai',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyText(_alicePublicKeyController.text),
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _sendPublicKeyToBob,
                      child: const Text('Gửi Khóa Công Khai Cho Bob'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _aliceReceivedBobPublicKeyController,
                      decoration: InputDecoration(
                        labelText: 'Khóa Công Khai Của Bob',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste, size: 20),
                          onPressed: () => _pasteText(_aliceReceivedBobPublicKeyController),
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _alicePlaintextController,
                      decoration: const InputDecoration(
                        labelText: 'Văn Bản Gốc Cho Bob',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _encrypt,
                      child: const Text('Mã Hóa'),
                    ),
                    const SizedBox(height: 8),
                    Text('Văn Bản Mã Hóa Cho Bob: $_aliceCiphertext', style: const TextStyle(fontSize: 16)),
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
                      controller: _bobPrivateKeyController,
                      decoration: InputDecoration(
                        labelText: 'Khóa Bí Mật',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyText(_bobPrivateKeyController.text),
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _generateBobKeys,
                      child: const Text('Tạo Cặp Khóa'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bobPublicKeyController,
                      decoration: InputDecoration(
                        labelText: 'Khóa Công Khai',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyText(_bobPublicKeyController.text),
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _sendPublicKeyToAlice,
                      child: const Text('Gửi Khóa Công Khai Cho Alice'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bobReceivedAlicePublicKeyController,
                      decoration: InputDecoration(
                        labelText: 'Khóa Công Khai Của Alice',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste, size: 20),
                          onPressed: () => _pasteText(_bobReceivedAlicePublicKeyController),
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bobCiphertextController,
                      decoration: const InputDecoration(
                        labelText: 'Văn Bản Mã Hóa Từ Alice',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _decryptBob,
                      child: const Text('Giải Mã'),
                    ),
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
                      controller: _evePrivateKeyController,
                      decoration: InputDecoration(
                        labelText: 'Khóa Bí Mật (Giả Lập)',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste, size: 20),
                          onPressed: () => _pasteText(_evePrivateKeyController),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _eveCiphertextController,
                      decoration: InputDecoration(
                        labelText: 'Văn Bản Mã Hóa Từ Alice',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste, size: 20),
                          onPressed: () => _pasteText(_eveCiphertextController),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _decryptEve,
                      child: const Text('Giải Mã'),
                    ),
                    const SizedBox(height: 8),
                    Text('Văn Bản Gốc: $_evePlaintext', style: const TextStyle(fontSize: 16)),
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