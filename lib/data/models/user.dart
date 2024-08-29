
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoblast/data/models/turno.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  User({id = 0, name = "", email = "", rut = "", cargo = "", turnoId = 1}) {
    _id = id;
    _name = name;
    _email = email;
    _rut = rut;
    _cargo = cargo;
    _turnoId = turnoId;
    setTurno();
  }

  late int _id;
  late String _name;
  late String _email;
  late String _rut;
  late String _cargo;
  late int _turnoId;
  Turno _turno = Turno();
  
  setTurno() async {
    final url = Uri.parse("${dotenv.env["API_URL"]}/get-turno?id=$_turnoId");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var turno = jsonDecode(response.body) as Map<String, dynamic>;
      _turno = Turno(id: turno["id"], nombre: turno["nombre_turno"]);
    } else {
      _turno = Turno(id: 1, nombre: "error");
    }
    //_turno = await MySqlTable("turnos").find(_turnoId).then((value) => Turno(id: value["id"], nombre: value["nombre_turno"]));
  }

  int get id => _id;
  String get name => _name;
  String get email => _email;
  String get rut => _rut;
  String get cargo => _cargo;
  int get turnoId => _turnoId;
  Turno get turno => _turno;
}