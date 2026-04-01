import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: onboard(),
      ),
    );
  }
}

class onboard extends StatelessWidget {
  const onboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("assets/images/onboarding_screen_1.png", height: 250),
        Spacer(),
        Text("fgfd fdgdf gfg dfsd  fg fgdfsgds dfgsd"),
      ],
    );
  }
}
