import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoblast/ui/screens/standard_view.dart';
import 'package:geoblast/ui/screens/route_screen.dart';
import 'package:geoblast/ui/screens/screen.dart';
import 'package:geoblast/ui/widgets/login_required_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geoblast/data/login_state.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuForm extends StatelessWidget implements RouteScreen {
  const MenuForm({super.key});

  @override
  IconData get icon => Icons.format_list_bulleted;
  @override
  String get title => "Formulario de menú";
  @override
  String get route => "/menu_form";

  @override
  Widget build(BuildContext context) {
    return UserVerificationWidget(
      currentRoute: route,
      child: StandardView(
        screen: MenuFormPage()
      )
    );
  }
}

class MenuFormPage extends StatefulWidget implements Screen {
  @override
  IconData get icon => Icons.format_list_bulleted;
  @override
  String get title => "Formulario de menú";

  @override
  State<StatefulWidget> createState() {
    return _MenuFormPageState();
  }
}

class _MenuFormPageState extends State<MenuFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedMenuPrincipal;
  String currentDateTime = '';
  bool showLimitCard = false;
  bool isFormDisabled = false;

  List<String> menuPrincipalOptions = [];
  int ordersToday = 0;

  @override
  void initState() {
    super.initState();
    _loadMenuOptions();
    _fetchCurrentDateTime();
    _checkDailyOrderLimit();
  }

  Future<void> _loadMenuOptions() async {
    // var conn = MySql.connection;
    // var results = await conn.query('SELECT DISTINCT menu_principal FROM menu');
    Iterable results = [];
    final url = Uri.parse("${dotenv.env["API_URL"]}/get-menu-options");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      results = jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Hubo un error al cargar las opciones del menu: ${response.statusCode}");
    }
    setState(() {
      menuPrincipalOptions = results
          .map((row) => row['menu_principal'].toString())
          .toSet()
          .toList();
    });
  }

  Future<void> _fetchCurrentDateTime() async {
    setState(() {
      currentDateTime = _formatDate(tz.TZDateTime.now(tz.getLocation("America/Santiago")));
    });
    // var conn = MySql.connection;
    // var results = await conn.query('SELECT NOW() AS fecha_actual');

    // if (results.isNotEmpty) {
    //   var fechaActual = results.first['fecha_actual'] as DateTime;
    //   setState(() {
    //     currentDateTime = _formatDate(fechaActual);
    //   });
    // }
  }

  Future<void> _checkDailyOrderLimit() async {
    // var conn = MySql.connection;
    var loginState = context.read<LoginState>();
    var user = loginState.user;

    if (user == null) {
      return;
    }
    // Obtener la fecha de hoy en formato 'yyyy-MM-dd'
    //var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var today = DateFormat('yyyy-MM-dd').format(tz.TZDateTime.now(tz.getLocation('America/Santiago')));

    // var results = await conn.query(
    //     'SELECT COUNT(*) AS count FROM pedidos WHERE DATE(fecha_pedido) = ? AND usuario_id = ?',
    //     [today, user.id]);
    //var user = jsonDecode(response.body) as Map<String, dynamic>;
    //Iterable results;
    final Iterable results;
    final url = Uri.parse("${dotenv.env["API_URL"]}/get-pedidos-hechos-count?usuario_id=${user.id}&fecha=$today");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      results = jsonDecode(response.body) as List<dynamic>;
      //results = responseBody.values;
    } else {
      throw Exception("Hubo un error al validar el limite de pedidos: ${response.statusCode}");
    }
    // setState(() {
    //   menuPrincipalOptions = results
    //       .map((row) => row['menu_principal'].toString())
    //       .toSet()
    //       .toList();
    // });

    if (results.isNotEmpty) {
      setState(() {
        ordersToday = results.first['count'] as int;
        showLimitCard = ordersToday >= 3;
        isFormDisabled =
            ordersToday >= 3; // Deshabilitar formulario si hay 3 pedidos
      });
    }
  }

  Future<bool> _canOrder(
      String? menuPrincipal, int userId) async {
    // var conn = MySql.connection;

    // Obtener la fecha y hora actuales
    //DateTime now = DateTime.now();
    var now = tz.TZDateTime.now(tz.getLocation('America/Santiago'));

    // Verificar la hora actual para restringir los pedidos (comentado provisionalmente)

    bool isAllowedTime = _isAllowedTime(menuPrincipal, now);
    if (!isAllowedTime) {
      await _showTimeRestrictionDialog(menuPrincipal);
      return false;
    }

    // Verificar si ya existe un pedido con el mismo menú en el mismo día
    // var results = await conn.query(
    //     'SELECT COUNT(*) AS count FROM pedidos WHERE menu_principal = ? AND DATE(fecha_pedido) = CURDATE() AND usuario_id = ?',
    //     [menuPrincipal, userId]);
    Iterable results;
    final url = Uri.parse("${dotenv.env["API_URL"]}/get-pedidos-hechos-count?usuario_id=$userId&menu_principal=$menuPrincipal");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      results = jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Hubo un error al validar el limite de pedidos: ${response.statusCode}");
    }
    var count = results.isNotEmpty ? results.first['count'] as int : 0;
    if (count > 0) {
      // Mostrar un diálogo en lugar de SnackBar
      await _showDuplicateOrderDialog(menuPrincipal);
      return false;
    }
    return true;
  }
  Future<void> _insertOrder(
      String orderNumber, String? menuPrincipal, int userId) async {
    
    final url = Uri.parse("${dotenv.env["API_URL"]}/insert-pedido");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "numero_pedido": orderNumber,
        "usuario_id": userId,
        "menu_principal": menuPrincipal,
      })
    );
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw Exception("Hubo un error al insertar pedido: ${response.statusCode}");
    }
    // Insertar el nuevo pedido
    // var baseUrl = "http://localhost/proyectos/GeoBlastWeb/public/";
    // var $id = 
    // await conn.query(
    //   'INSERT INTO pedidos (numero_pedido, fecha_pedido, menu_principal, usuario_id) VALUES (?, ?, ?, ?)',
    //   [
    //     orderNumber,
    //     now.toIso8601String(), // Usa el formato ISO 8601 para TIMESTAMP
    //     menuPrincipal,
    //     userId,
    //   ],
    // );

    // Actualizar la cantidad de pedidos del día y verificar el límite
    await _checkDailyOrderLimit();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy HH:mm').format(date);
  }

  bool _isAllowedTime(String? menu, DateTime now) {
    final time = now.hour * 100 + now.minute;
    if (menu == 'Desayuno') {
      return time >= 700 && time <= 830;
    } else if (menu == 'Almuerzo') {
      return time >= 1130 && time <= 1600;
    } else if (menu == 'Cena') {
      return time >= 1930 && time <= 2200;
    }
    return false;
  }
  
  Future<void> _showTimeRestrictionDialog(String? menuPrincipal) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hora No Permitida'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'No se puede realizar un pedido de "$menuPrincipal" fuera del horario permitido.',
              ),
              const SizedBox(
                  height:
                      16.0), // Espacio entre el texto y la sección de horarios
              const Text(
                'Horario permitido:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Desayuno\n'
                '7:00 - 08:30',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0), // Espacio entre los horarios
              const Text(
                'Almuerzo\n'
                '11:30 - 16:00',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0), // Espacio entre los horarios
              const Text(
                'Cena\n'
                '19:30 - 22:00',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _showDuplicateOrderDialog(String? menuPrincipal) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pedido Duplicado'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Ya existe un pedido con el menú "$menuPrincipal" para hoy. No se puede realizar un pedido duplicado.',
              ),
              const SizedBox(
                  height:
                      16.0), // Espacio entre el texto y la sección de horarios
              const Text(
                'Horarios:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Desayuno\n'
                '7:00 - 08:30',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0), // Espacio entre los horarios
              const Text(
                'Almuerzo\n'
                '11:30 - 16:00',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0), // Espacio entre los horarios
              const Text(
                'Cena\n'
                '19:30 - 22:00',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmOrder() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirmación'),
              content: const Text(
                  '¿Estás seguro de que quieres enviar este pedido? Una vez lo hagas este será valido solo en la proxima hora'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // void _clearFields() {
  //   setState(() {
  //     selectedMenuPrincipal = null;
  //     _fetchCurrentDateTime(); // Actualiza la fecha y hora actuales
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var loginState = context.watch<LoginState>();
    var user = loginState.user;

    if (user == null) {
      return const Center(child: Text('No hay usuario logueado'));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Bienvenido, ${user.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Text(
              'Email: ${user.email}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              'Rut: ${user.rut}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              'Área: ${user.cargo}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              'Turno: ${user.turno.nombre}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Fecha y Hora Actual: $currentDateTime',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMenuPrincipal,
                  decoration: const InputDecoration(
                    labelText: 'Menú Principal',
                    border: OutlineInputBorder(),
                  ),
                  items: menuPrincipalOptions
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: isFormDisabled
                      ? null
                      : (String? newValue) {
                          setState(() {
                            selectedMenuPrincipal = newValue;
                          });
                        },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isFormDisabled
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          if (_formKey.currentState?.validate() ?? false) {
                            bool confirmed = await _confirmOrder();
                            if (confirmed) {
                              messenger.showSnackBar(const SnackBar(content: Text("Procesando...")));
                              try {
                                bool canOrder = await _canOrder(
                                  selectedMenuPrincipal,
                                  user.id
                                );
                                if (canOrder) {
                                    await _insertOrder(
                                      'Pedido_${DateTime.now().millisecondsSinceEpoch}',
                                      selectedMenuPrincipal,
                                      user.id
                                    );
                                    messenger.clearSnackBars();
                                    messenger.showSnackBar(const SnackBar(content: Text("Pedido hecho correctamente")));
                                } else {
                                  messenger.clearSnackBars();
                                }
                              } catch (e) {
                                messenger.clearSnackBars();
                                messenger.showSnackBar(SnackBar(content: Text("Ha ocurrido un error, revisa tu conexión o vuelve a intentarlo más tarde $e")));
                              }
                            }
                          }
                        },
                  child: const Text('Enviar Pedido'),
                ),
                const SizedBox(height: 16),
                if (showLimitCard) ...[
                  Card(
                    color: Colors.red[100],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Has alcanzado el límite de pedidos para hoy.',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // ElevatedButton(
                //   onPressed: isFormDisabled ? null : _clearFields,
                //   child: const Text('Limpiar Campos'),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}