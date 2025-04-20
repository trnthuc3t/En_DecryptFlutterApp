import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UngDungMaHoa());
}

class UngDungMaHoa extends StatelessWidget {
  const UngDungMaHoa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Mã Hóa',
      theme: AppTheme.lightTheme,
      home: HomeScreen(),
    );
  }
}