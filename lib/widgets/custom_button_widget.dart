import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButtonWidget extends StatelessWidget {
  final String title;
  final Color? color;
  final VoidCallback onTap;
  const CustomButtonWidget({
    super.key,
    required this.title,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      color: color ?? Colors.cyan,
      height: 60,
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Text(
        title,
        style: GoogleFonts.dmSerifDisplay(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
