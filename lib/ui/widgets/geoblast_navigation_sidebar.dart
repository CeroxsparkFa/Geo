import 'package:flutter/material.dart';
import 'package:geoblast/data/login_state.dart';
import 'package:geoblast/ui/screens/form_menu.dart';
import 'package:geoblast/ui/screens/menu_visual.dart';
import 'package:geoblast/ui/widgets/navigation_sidebar.dart';
import 'package:geoblast/ui/widgets/drawer_account_header.dart';
import 'package:provider/provider.dart';

class GeoblastNavigationSideBar extends StatelessWidget {
  const GeoblastNavigationSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationSideBar(
      const [
        MenuForm(),
        MenuVisual(),
      ],
      header: DrawerAccountHeader(
          title:
              "${context.read<LoginState>().user!.name} | ${context.read<LoginState>().user!.cargo}",
          subtitles: [
            "Correo: ${context.read<LoginState>().user!.email}",
            "Rut: ${context.read<LoginState>().user!.rut}",
            "Turno: ${context.read<LoginState>().user!.turno.nombre}"
          ]),
    );
  }
}
