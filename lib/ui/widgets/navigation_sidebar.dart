import 'package:flutter/material.dart';
import 'package:geoblast/ui/screens/route_screen.dart';

class NavigationSideBar extends StatelessWidget {
  const NavigationSideBar(this.screens, {super.key, this.header});

  final Widget? header;
  final List<RouteScreen> screens;

  List<Widget> getDestinations(BuildContext context) {
    var result = <Widget>[];
    for (var screen in screens) {
      result.add(
        ListTile(
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
          horizontalTitleGap: 24,
          textColor: Theme.of(context).colorScheme.secondary,
          iconColor: Theme.of(context).colorScheme.secondary,
          leading: Icon(screen.icon),
          style: ListTileStyle.drawer,
          title: Text(screen.title),
          onTap: () {
            Navigator.pushNamed(context, screen.route);
          },
        ),
      );
      result.add(
        Divider(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.25),
          indent: 16,
          endIndent: 16,
        )
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const ContinuousRectangleBorder(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: 
          header == null ?
          getDestinations(context) :
          <Widget>[header!] + getDestinations(context)
      ),
    );
  }
}
