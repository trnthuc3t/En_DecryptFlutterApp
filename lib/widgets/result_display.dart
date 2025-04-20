import 'package:flutter/material.dart';

class ResultDisplay extends StatelessWidget {
  final String result;

  const ResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        result.isEmpty ? 'Kết quả sẽ hiển thị ở đây' : result,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}