import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoblast/ui/screens/error_screen.dart';
import 'package:geoblast/ui/screens/usuario_en_descanso_screen.dart';
import 'package:provider/provider.dart';
import 'package:geoblast/data/login_state.dart';
import 'package:geoblast/ui/screens/splash_screen.dart';
import 'package:geoblast/ui/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserVerificationWidget extends StatelessWidget {
  const UserVerificationWidget({required this.child, this.currentRoute, super.key});
  final String? currentRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final userState = getUserState(context);
    return FutureBuilder(
      future: userState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return ErrorScreen(exception: snapshot.error!, previousRoute: currentRoute);
          }
          switch (snapshot.data!) {
            case UserState.notLoggedIn:
              return const LoginScreen();
            case UserState.enDescanso:
              return const UsuarioEnDescansoScreen();
            case UserState.activo:
              return child;
          }
        } else {
          return const SplashScreen();
        }
      }
    );
  }

  Future<UserState> getUserState(BuildContext context) async {
    final loginState = context.read<LoginState>();
    if (!loginState.isLoggedIn()) {
      final loggedIn = await context.read<LoginState>().tryLogin();
      if (!loggedIn) {
        return UserState.notLoggedIn;
      }
    }
    Map<String, dynamic> userInDb;
    final url = Uri.parse("${dotenv.env["API_URL"]}/get-user?rut=${loginState.user!.rut}");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      userInDb = jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Hubo un error al intentar recuperar el estado del usuario: ${response.statusCode}");
    }
    //var userInDb = await MySqlTable("users").find(context.read<LoginState>().user!.id);
    return userInDb["user_estado"] == 1 ? UserState.activo : UserState.enDescanso;
  }
}


enum UserState {
  activo,
  notLoggedIn,
  enDescanso
}