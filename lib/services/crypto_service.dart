import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart' as pc;

class DichVuMaHoa {
  // Tạo khóa ngẫu nhiên
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
    final iv = IV.fromSecureRandom(16); // Tạo IV ngẫu nhiên
    final maHoa = Encrypter(AES(khoaBytes));
    final encrypted = maHoa.encrypt(banRo, iv: iv);
    return {
      'ciphertext': encrypted.base64,
      'iv': iv.base64, // Lưu IV để giải mã
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

  // Mã hóa bất đối xứng (RSA)
  Future<Map<String, dynamic>> taoCapKhoaRSA() async {
    final capKhoa = TaoCapKhoaRSA.taoCapKhoa();
    return {
      'khoaCongKhai': capKhoa['khoaCongKhai'],
      'khoaBiMat': capKhoa['khoaBiMat'],
    };
  }

  String maHoaRSA(String banRo, pc.RSAPublicKey khoaCongKhai) {
    final maHoa = Encrypter(RSA(publicKey: khoaCongKhai));
    return maHoa.encrypt(banRo).base64;
  }

  String giaiMaRSA(String banMa, pc.RSAPrivateKey khoaBiMat) {
    final maHoa = Encrypter(RSA(privateKey: khoaBiMat));
    return maHoa.decrypt64(banMa);
  }
}

// Mock tạo cặp khóa RSA
class TaoCapKhoaRSA {
  static Map<String, dynamic> taoCapKhoa() {
    // Giả lập cho demo, thay bằng tạo khóa thật trong sản xuất
    return {
      'khoaCongKhai': pc.RSAPublicKey(
        BigInt.from(65537), // publicExponent
        BigInt.parse('12345678901234567890'), // modulus
      ),
      'khoaBiMat': pc.RSAPrivateKey(
        BigInt.parse('12345678901234567890'), // modulus
        BigInt.from(65537), // privateExponent
        BigInt.parse('9876543210987654321'), // p
        BigInt.parse('1231231231231231231'), // q
      ),
    };
  }
}