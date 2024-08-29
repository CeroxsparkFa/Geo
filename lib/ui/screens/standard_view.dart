import 'package:flutter/material.dart';
import 'package:geoblast/ui/screens/screen.dart';

class StandardView extends StatelessWidget {
  const StandardView({super.key, required this.screen, this.drawer});
  final Screen screen;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          screen.title
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: screen
        )
      ),
      drawer: drawer,
    );
  }
}
