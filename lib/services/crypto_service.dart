import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart' as pc;
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';

class DichVuMaHoa {
  // Tạo khóa ngẫu nhiên (cho AES)
  String taoKhoaNgauNhien() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(16, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Mã hóa đối xứng (AES)
  Map<String, String> maHoaAES(String banRo, String khoa) {
    final khoaBytes = Key.fromUtf8(khoa.padRight(32));
    final iv = IV.fromSecureRandom(16);
    final maHoa = Encrypter(AES(khoaBytes));
    final encrypted = maHoa.encrypt(banRo, iv: iv);
    return {
      'ciphertext': encrypted.base64,
      'iv': iv.base64,
    };
  }

  String giaiMaAES(String banMa, String khoa, String ivBase64) {
    try {
      final khoaBytes = Key.fromUtf8(khoa.padRight(32));
      final iv = IV.fromBase64(ivBase64);
      final maHoa = Encrypter(AES(khoaBytes));
      return maHoa.decrypt(Encrypted.fromBase64(banMa), iv: iv);
    } catch (e) {
      throw Exception('Khóa không đúng hoặc văn bản mã hóa không hợp lệ');
    }
  }

  // Tạo cặp khóa RSA bằng pointycastle
  Future<Map<String, dynamic>> taoCapKhoaRSA() async {
    final secureRandom = FortunaRandom();
    // Tạo seed 256-bit (32 byte)
    final random = Random.secure();
    final seed = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seed)));

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 128, 64), secureRandom));
    final pair = keyGen.generateKeyPair();
    final publicKey = pair.publicKey as pc.RSAPublicKey;
    final privateKey = pair.privateKey as pc.RSAPrivateKey;

    // Hiển thị đầy đủ chuỗi base64
    final publicKeyStr = base64Encode(utf8.encode(publicKey.exponent.toString() + ':' + publicKey.modulus.toString()));
    final privateKeyStr = base64Encode(utf8.encode(privateKey.exponent.toString() + ':' + privateKey.modulus.toString()));

    return {
      'khoaCongKhai': publicKey,
      'khoaBiMat': privateKey,
      'khoaCongKhaiStr': publicKeyStr,
      'khoaBiMatStr': privateKeyStr,
    };
  }

  String maHoaRSA(String banRo, pc.RSAPublicKey khoaCongKhai) {
    try {
      final maHoa = Encrypter(RSA(publicKey: khoaCongKhai));
      return maHoa.encrypt(banRo).base64;
    } catch (e) {
      throw Exception('Lỗi mã hóa: $e');
    }
  }

  String giaiMaRSA(String banMa, pc.RSAPrivateKey khoaBiMat) {
    try {
      final maHoa = Encrypter(RSA(privateKey: khoaBiMat));
      return maHoa.decrypt64(banMa);
    } catch (e) {
      throw Exception('Lỗi giải mã: $e');
    }
  }
}