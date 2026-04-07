import 'package:flutter/material.dart';

class PromoBannerSection extends StatefulWidget {
  const PromoBannerSection({super.key});

  @override
  State<PromoBannerSection> createState() => _PromoBannerSectionState();
}

class _PromoBannerSectionState extends State<PromoBannerSection> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_PromoBannerData> banners = [
    const _PromoBannerData(
      title: '50-40% OFF',
      subtitleLine1: 'Now in (product)',
      subtitleLine2: 'All colours',
      imagePath: 'assets/images/promo_banner_girl.jpg',
    ),
    const _PromoBannerData(
      title: 'Summer Sale',
      subtitleLine1: 'Trending fashion',
      subtitleLine2: 'Best prices today',
      imagePath: 'assets/images/promo_banner_girl.jpg',
    ),
    const _PromoBannerData(
      title: 'New Arrival',
      subtitleLine1: 'Fresh collection',
      subtitleLine2: 'Shop the look',
      imagePath: 'assets/images/promo_banner_girl.jpg',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final banner = banners[index];
                return _PromoBannerCard(banner: banner);
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? const Color(0xFFF48FB1)
                      : const Color(0xFFD9D9D9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBannerCard extends StatelessWidget {
  final _PromoBannerData banner;

  const _PromoBannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              banner.imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),

            // Optional: text clearer করার জন্য খুব হালকা dark overlay
            // এটা না চাইলে পুরো block delete করে দাও
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.28),
                    Color.fromRGBO(0, 0, 0, 0.10),
                    Color.fromRGBO(0, 0, 0, 0.00),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 24,
              top: 24,
              bottom: 24,
              child: SizedBox(
                width: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      banner.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      banner.subtitleLine1,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitleLine2,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: () {
                        debugPrint('Shop Now tapped');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop Now',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 17),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerData {
  final String title;
  final String subtitleLine1;
  final String subtitleLine2;
  final String imagePath;

  const _PromoBannerData({
    required this.title,
    required this.subtitleLine1,
    required this.subtitleLine2,
    required this.imagePath,
  });
}
