import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(child: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                Icon(Icons.mp_outlined,color: Colors.black87,size: 70,),
                Icon(Icons.mp_outlined,color: Colors.black87,size: 70,)
              ],
            )
          ],
        ),
      )),
    );
  }
}
