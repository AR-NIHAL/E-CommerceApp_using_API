import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_providers.dart';
import 'product_card.dart';

class FlashSaleGrid extends ConsumerWidget {
  const FlashSaleGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProductsProvider);

    return filteredAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No products found')),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final p = products[index];
              return ProductCard(
                title: p.title,
                imageUrl: p.image,
                price: p.price,
                rating: p.rating,
                discountPercent: 16,
                onAdd: () {},
                onFavorite: () {},
              );
            },
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text('Error: $e')),
      ),
    );
  }
}


// import 'package:ecommerce_riverpod_api/features/widgets/product_card.dart';
// import 'package:flutter/material.dart';

// class FlashSaleGrid extends StatelessWidget {
//   const FlashSaleGrid();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: 4,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 12,
//           crossAxisSpacing: 12,
//           childAspectRatio: 0.72,
//         ),
//         itemBuilder: (context, index) {
//           return ProductCard(
//             title: 'Zipper',
//             imageUrl:
//                 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
//             price: 3.40,
//             rating: 3.5,
//             discountPercent: 16,
//             onAdd: () {
//               print("Add pressed");
//             },
//             onFavorite: () {
//               print("Favorite pressed");
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // class _ProductCard extends StatelessWidget {
// //   const _ProductCard();

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //       ),
// //       child: const Center(child: Text('Product Card')),
// //     );
// //   }
// // }
