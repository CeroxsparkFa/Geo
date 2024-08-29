import 'package:flutter/material.dart';

@Deprecated("Reemplazado por IndexView")
abstract class IndexPage extends StatelessWidget {
  const IndexPage({super.key});
  
  IconData get icon;
  String get title;
}