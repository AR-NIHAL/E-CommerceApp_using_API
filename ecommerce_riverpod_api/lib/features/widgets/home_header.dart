import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.red,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const CircleAvatar(radius: 18),
              ],
            ),

            const SizedBox(height: 6),
            const Text(
              'Your Location',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _showLocationPicker(context),
              child: Row(
                children: const [
                  Icon(Icons.location_on, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'New York, USA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _SearchBar()
            
            // search + right buttons
            

            // Row(
            //   children: [
            //     // Expanded(
            //     //   child: Container(
            //     //     height: 44,
            //     //     padding: const EdgeInsets.symmetric(horizontal: 12),
            //     //     decoration: BoxDecoration(
            //     //       color: Colors.white,
            //     //       borderRadius: BorderRadius.circular(10),
            //     //     ),
            //     //     child: Row(
            //     //       children: const [
            //     //         Icon(Icons.search, color: Colors.grey),
            //     //         SizedBox(width: 8),
            //     //         Expanded(
            //     //           child: TextField(
            //     //             decoration: InputDecoration(
            //     //               hintText: 'Search',
            //     //               border: InputBorder.none,
            //     //             ),
            //     //           ),
            //     //         ),
            //     //       ],
            //     //     ),
            //     //   ),
            //     // ),
            //     // _SearchBar(),
            //     // const SizedBox(width: 10),
            //     // _SquareIconButton(icon: Icons.notifications_none),
            //     // const SizedBox(width: 10),
            //     // _SquareIconButton(icon: Icons.tune),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

// class _SquareIconButton extends StatelessWidget {
//   final IconData icon;
//   const _SquareIconButton({required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 44,
//       width: 44,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Icon(icon, color: Colors.red),
//     );
//   }
// }

void _showLocationPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('New York, USA'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: Text('Dhaka, BD'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),

                // input
                Expanded(
                  child: TextField(
                    // ✅ live update provider
                    onChanged: (text) =>
                        ref.read(searchQueryProvider.notifier).state = text,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // ✅ clear button (UX)
                if (query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      ref.read(searchQueryProvider.notifier).state = '';
                      FocusScope.of(context).unfocus();
                    },
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        const _SquareIconButton(icon: Icons.notifications_none),
        const SizedBox(width: 10),
        const _SquareIconButton(icon: Icons.tune),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  const _SquareIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.red),
    );
  }
}
