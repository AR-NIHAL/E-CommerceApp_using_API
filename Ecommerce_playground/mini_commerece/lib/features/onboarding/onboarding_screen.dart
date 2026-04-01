import 'package:flutter/material.dart';
import 'package:mini_commerece/features/onboarding/onboarding_data.dart';
import 'package:mini_commerece/features/onboarding/onboarding_page.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == OnboardingData.items.length - 1;

  void _goNext() {
    if (_isLast) return;
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _skip() {
    _controller.animateToPage(
      OnboardingData.items.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // void _getStarted() {
  //   Navigator.pushReplacementNamed(context, AppRoutes.home);
  // } changed to this below module 3

  void _getStarted() {
    Navigator.pushReplacementNamed(context, AppRoutes.root);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Text('ShopEasy', style: AppTextStyles.body16),
                  const Spacer(),
                  if (!_isLast)
                    TextButton(onPressed: _skip, child: const Text('Skip')),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: OnboardingData.items.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) =>
                    OnboardingPage(item: OnboardingData.items[i]),
              ),
            ),

            // Dots + Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DotsIndicator(
                    count: OnboardingData.items.length,
                    activeIndex: _index,
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52, // button height requirement
                    child: ElevatedButton(
                      onPressed: _isLast ? _getStarted : _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(_isLast ? 'Get Started' : 'Next'),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text('Swipe to explore', style: AppTextStyles.caption12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _DotsIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 18 : 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
