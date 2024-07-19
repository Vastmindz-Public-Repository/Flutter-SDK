import 'package:flutter/material.dart';
import 'package:rppg_common_example/view/scan/scan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 200,
          height: 60,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(blueColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
            child: Text(
              "Start Camera",
              style: const TextStyle(
                  fontFamily: 'outfit_regular', color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanScreen()),
              );
            },
          ),
        ),
      ),
    );
  }
}

Color blueColor = const Color(0xFF1660b7);
double? fontSizeVar = 14.00;
Color? fontColorVar = Colors.white;
