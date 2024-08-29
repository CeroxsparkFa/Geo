
@Deprecated("Actualmente no esta siendo usado para nada")
class Pedido {
  Pedido(
      {id = 0,
      menuPrincipal = "",}) {
    _id = id;
    _menuPrincipal = menuPrincipal;
  }

  late int _id;
  late String _menuPrincipal;

  int get id => _id;
  String get menuPrincipal => _menuPrincipal;
}
