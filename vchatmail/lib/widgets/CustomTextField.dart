import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final Size size;
  final String hintText;
  final IconData icon;
  final TextEditingController cont;
  final bool isPass;

  const CustomTextField({
    Key? key,
    required this.size,
    required this.hintText,
    required this.icon,
    required this.cont,
    this.isPass = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: cont,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      obscureText: isPass,
    );
  }
}
