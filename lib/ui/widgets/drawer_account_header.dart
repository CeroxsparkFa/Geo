
import 'package:flutter/material.dart';
import 'package:geoblast/data/login_state.dart';
import 'package:provider/provider.dart';

class DrawerAccountHeader extends StatelessWidget {
  const DrawerAccountHeader({super.key, required this.title, this.subtitles = const [], this.img, this.backgroundColor, this.foregroundColor});

  final String title;
  final List<String> subtitles;
  final String? img;
  final Color? backgroundColor;
  final Color? foregroundColor;


  List<Widget> getHeaderElements(Color color) {
    var result = <Widget>[];
    result.add(
      img != null ?
      Image.asset(
        img!,
        width: 70,
        height: 70,
      ) :
      Icon(
        Icons.account_circle,
        size: 70,
        color: color
      ),
    );
    result.add(
      Tooltip(
        message: title,
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 22
          ),
        )
      )
    );
    for (var subtitle in subtitles) {
      result.add(
        Tooltip(
          message: subtitle,
          child: Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: color.withOpacity(0.5),
                fontSize: 14
            ),
          )
        )
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor_ = backgroundColor?? Theme.of(context).colorScheme.primary;
    Color foregroundColor_ = backgroundColor?? Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.only(top: 16 + MediaQuery.of(context).padding.top, bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: backgroundColor_,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getHeaderElements(foregroundColor_),
            )
          ),
          IconButton(
            onPressed: () {
              // context.read<LoginState>().logout();
              _showLogOutDialog(context);
            },
            tooltip: "Cerrar sesión",
            icon: Icon(
              Icons.logout, 
              color: Theme.of(context).colorScheme.surface)
          )
        ]
      )
    );
  }

  Future<void> _showLogOutDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Deseas salir de tu cuenta?",
          style: TextStyle(
            fontSize: 20
          )),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No")
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Colors.red
                )
              ),
              onPressed: () {
                Navigator.of(context).popAndPushNamed("/login");
                context.read<LoginState>().logout();
              },
              child: const Text("Sí")
            )
          ],
        );
      },
    );
  }
}