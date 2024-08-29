class Turno {
  Turno({id = 0, nombre = ""}) {
    _id = id;
    _nombre = nombre;
  }
  late int _id;
  late String _nombre;

  int get id => _id;
  String get nombre => _nombre;
}