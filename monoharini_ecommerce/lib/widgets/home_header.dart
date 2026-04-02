import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu Button
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.menu, color: Color(0xFF5E5E5E), size: 22),
        ),

        // Logo + App Name
        Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF5B7F), Color(0xFF4F8CFF)],
                        ),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Monoharini',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F8CFF),
              ),
            ),
          ],
        ),

        // Profile Image
        Container(
          height: 44,
          width: 44,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE56A6A),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 22,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
