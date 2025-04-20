enum LoaiThuatToan { doiXung, batDoiXung }

class ThuatToan {
  final String ten;
  final LoaiThuatToan loai;
  final String moTa;

  ThuatToan({
    required this.ten,
    required this.loai,
    required this.moTa,
  });
}