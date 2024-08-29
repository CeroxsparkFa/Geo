import 'package:flutter/material.dart';

abstract class Screen extends Widget {
  const Screen({super.key});
  String get title;
  IconData get icon;
}