import 'package:flutter/material.dart';
import '../models/algorithm.dart';

class AlgorithmCard extends StatelessWidget {
  final ThuatToan thuatToan;
  final VoidCallback onTap;

  const AlgorithmCard({
    super.key,
    required this.thuatToan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(thuatToan.ten),
        subtitle: Text(thuatToan.moTa),
        onTap: onTap,
      ),
    );
  }
}