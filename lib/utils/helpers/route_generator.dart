import 'package:flutter/material.dart';
import 'package:geoblast/main.dart';
import 'package:geoblast/ui/screens/error_screen.dart';
import 'package:geoblast/ui/screens/form_menu.dart';
import 'package:geoblast/ui/screens/menu_visual.dart';
import 'package:geoblast/ui/screens/login_screen.dart';
import 'package:geoblast/ui/screens/change_password_screen.dart';
import 'package:geoblast/ui/screens/splash_screen.dart';
import 'package:geoblast/ui/screens/usuario_en_descanso_screen.dart';
import 'package:geoblast/ui/screens/write_verification_code_screen.dart';
import 'package:geoblast/ui/screens/choose_password_screen.dart';
import 'package:geoblast/ui/screens/main_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var args = settings.arguments != null
      ? settings.arguments as Map<String, dynamic>
      : <String, dynamic>{};
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (context) => const MainScreen());
      case "/login":
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case "/change_password":
        return MaterialPageRoute(builder: (context) => const ChangePasswordScreen());
      case "/verification_code":
        return MaterialPageRoute(builder: (context) => WriteVerificationCodeScreen(args["verificationCode"]?? 0, args["email"]?? ""));
      case "/choose_password":
        return MaterialPageRoute(builder: (context) => ChoosePasswordScreen(args["email"]?? ""));
      case "/menu_form":
        return MaterialPageRoute(builder: (context) => const MenuForm());
      case "/menu_visual":
        return MaterialPageRoute(builder: (context) => const MenuVisual());
      case "/error_screen":
        return MaterialPageRoute(builder: (context) => const UsuarioEnDescansoScreen());
      case "/initial_route":
        return MaterialPageRoute(builder: (context) => FutureBuilder(
          future: initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return ErrorScreen(exception: snapshot.error!);
              } else {
                return const MainScreen();
              }
            } else {
              return const SplashScreen();
            }
          },
        ));
      default:
        return MaterialPageRoute(builder: (context) => const _ErrorRoute());
    }
  }
}

class _ErrorRoute extends StatelessWidget {
  const _ErrorRoute();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Esta ruta no existe")
      )
    );
  }
}