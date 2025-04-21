import 'package:flutter/material.dart';
import '../models/algorithm.dart';
import '../widgets/algorithm_card.dart';
import 'symmetric_screen.dart';
import 'asymmetric_screen.dart';
import 'caesar_screen.dart';
import 'rail_fence_screen.dart';
import 'vigenere_screen.dart';
import 'playfair_screen.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});

  final List<ThuatToan> thuatToan = [
    ThuatToan(
      ten: 'AES',
      loai: LoaiThuatToan.doiXung,
      moTa: 'Mã hóa đối xứng sử dụng Tiêu chuẩn Mã hóa Nâng cao',
    ),
    ThuatToan(
      ten: 'RSA',
      loai: LoaiThuatToan.batDoiXung,
      moTa: 'Mã hóa bất đối xứng sử dụng cặp khóa công khai/bí mật',
    ),
    ThuatToan(
      ten: 'Caesar',
      loai: LoaiThuatToan.doiXung,
      moTa: 'Mã hóa cổ điển dịch chuyển ký tự theo số bước',
    ),
    ThuatToan(
      ten: 'Rail Fence',
      loai: LoaiThuatToan.doiXung,
      moTa: 'Mã hóa cổ điển sử dụng hàng rào zigzag',
    ),
    ThuatToan(
      ten: 'Vigenère',
      loai: LoaiThuatToan.doiXung,
      moTa: 'Mã hóa cổ điển sử dụng khóa chữ cái',
    ),
    ThuatToan(
      ten: 'Playfair',
      loai: LoaiThuatToan.doiXung,
      moTa: 'Mã hóa cổ điển sử dụng ma trận 5x5',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Mã Hóa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: thuatToan.length,
          itemBuilder: (context, index) {
            return AlgorithmCard(
              thuatToan: thuatToan[index],
              onTap: () {
                switch (thuatToan[index].ten) {
                  case 'AES':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManHinhDoiXung(),
                      ),
                    );
                    break;
                  case 'RSA':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManHinhBatDoiXung(),
                      ),
                    );
                    break;
                  case 'Caesar':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CaesarScreen(),
                      ),
                    );
                    break;
                  case 'Rail Fence':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RailFenceScreen(),
                      ),
                    );
                    break;
                  case 'Vigenère':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VigenereScreen(),
                      ),
                    );
                    break;
                  case 'Playfair':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayfairScreen(),
                      ),
                    );
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }
}
