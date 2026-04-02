import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onMicTap;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onMicTap,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFB8B8B8),
            size: 22,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB8B8B8),
          ),
          suffixIcon: IconButton(
            onPressed: onMicTap,
            icon: const Icon(
              Icons.mic_none_rounded,
              color: Color(0xFFB8B8B8),
              size: 22,
            ),
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }
}
