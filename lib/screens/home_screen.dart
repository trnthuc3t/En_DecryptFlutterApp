import 'package:flutter/material.dart';
import 'package:encryptflutterapp/models/algorithm.dart';
import 'package:encryptflutterapp/widgets/algorithm_card.dart';
import 'symmetric_screen.dart';
import 'asymmetric_screen.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Mã Hóa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: thuatToan.length,
          itemBuilder: (context, index) {
            return AlgorithmCard(
              thuatToan: thuatToan[index],
              onTap: () {
                if (thuatToan[index].loai == LoaiThuatToan.doiXung) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManHinhDoiXung()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManHinhBatDoiXung()),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}