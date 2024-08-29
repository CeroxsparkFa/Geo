
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoblast/data/models/user.dart';
import 'package:geoblast/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginState extends ChangeNotifier {
  LoginState();

  User? _user;
  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    MyApp.preferences.remove("encryptedPassword");
    MyApp.preferences.remove("email");
    notifyListeners();
  }

  bool isLoggedIn() {
    return _user != null;
  }

  Future<bool> tryLogin() async {
    final user = await fetchUser();
    if (user != null) {
      _user = user;
    }
    return user != null;
  }

  Future<User?> fetchUser() async {
    final password = MyApp.preferences.getString("encryptedPassword");
    final rut = MyApp.preferences.getString("rut");
    if (password == null || rut == null) {
      return null;
    }
    final url = Uri.parse("${dotenv.env["API_URL"]}/validate-user-credentials?rut=$rut&password=$password");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body == "") {
        return null;
      } else {
        var user = jsonDecode(response.body) as Map<String, dynamic>;
        return User(rut: user["rut"], cargo: user["cargo"], turnoId: user["turno_id"], email: user["email"], id: user["id"], name: user["name"]);
      }
    } else {
      throw Exception("Hubo un error al intentar recuperar el usuario: ${response.statusCode}");
    }

    // return MySqlTable("users").where("rut", rut).then((user) {
    //   if (user.isEmpty) {
    //     return null;
    //   }
    //   if (user.first["password"] == password) {
    //     return User(rut: user.first["rut"], cargo: user.first["cargo"], turnoId: user.first["turno_id"], email: user.first["email"], id: user.first["id"], name: user.first["name"]);
    //   }
    //   return null;
    // });
  }
}