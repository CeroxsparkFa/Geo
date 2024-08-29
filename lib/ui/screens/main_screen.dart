import 'package:flutter/material.dart';
import 'package:geoblast/ui/screens/standard_view.dart';
import 'package:geoblast/ui/screens/home_page.dart';
import 'package:geoblast/ui/screens/route_screen.dart';
import 'package:geoblast/ui/widgets/geoblast_navigation_sidebar.dart';
import 'package:geoblast/ui/widgets/login_required_widget.dart';

class MainScreen extends StatelessWidget implements RouteScreen {
  const MainScreen({super.key});

  @override
  String get title => "Home";

  @override
  IconData get icon => Icons.home;

  @override
  String get route => "/";

  @override
  Widget build(BuildContext context) {
    return UserVerificationWidget(
      currentRoute: route,
      child: const StandardView(
        screen: HomePage(),
        drawer: GeoblastNavigationSideBar()
      )
    );
  }
}