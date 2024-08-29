import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoblast/ui/screens/route_screen.dart';
import 'package:geoblast/data/login_state.dart';
import 'package:geoblast/ui/screens/screen.dart';
import 'package:geoblast/ui/screens/standard_view.dart';
import 'package:geoblast/ui/widgets/login_required_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:geoblast/utils/helpers/date_time_extension.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';


class MenuVisual extends StatelessWidget implements RouteScreen {
  const MenuVisual({super.key});

  @override
  IconData get icon => Icons.fastfood;
  @override
  String get title => "Pedidos";
  @override
  String get route => "/menu_visual";

  @override
  Widget build(BuildContext context) {
    return UserVerificationWidget(
      currentRoute: route,
      child: const StandardView(
        screen: MenuVisualPage()
      )
    );
  }
}

class MenuVisualPage extends StatefulWidget implements Screen {
  const MenuVisualPage({super.key});
  @override
  IconData get icon => Icons.fastfood;
  @override
  String get title => "Pedidos activos";

  @override
  State<StatefulWidget> createState() {
    return _MenuVisualPage();
  }
}
class _MenuVisualPage extends State<MenuVisualPage> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchPedidos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator())
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return SizedBox(
            width: double.infinity,
            height: MediaQuery.sizeOf(context).height - kToolbarHeight - 99,
            child: Center(
              child: Text(
                'No hay pedidos disponibles',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary
                ),
              )
            )
          );
        }

        final pedidos = snapshot.data as List<Map<String, dynamic>>;
        pedidos.sort((a, b) => _parseDate(b['fecha_pedido'])
            .compareTo(_parseDate(a['fecha_pedido'])));

        final formattedDate = DateFormat('EEEE dd-MM-yyyy', 'es_ES').format(tz.TZDateTime.now(tz.getLocation('America/Santiago')));
        // final formattedDate = DateFormat('EEEE dd-MM-yyyy', 'es_ES').format(DateTime.now());
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSection('Estos son los pedidos del dia de hoy, $formattedDate', pedidos),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> pedidos) {
    if (pedidos.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4, left: 16, right: 16),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
        ),
        ...pedidos.map((pedido) {
          //var estado = pedido["verificado"] == 1 ? EstadoPedido.completado : (DateTime.now().difference(pedido["fecha_pedido"]) > const Duration(hours: 1) ? EstadoPedido.completado : EstadoPedido.enProceso);
          //var estado = pedido["verificado"] == 1 ? EstadoPedido.completado : (tz.TZDateTime.now(tz.getLocation('America/Santiago')).difference(pedido["fecha_pedido"]) > const Duration(hours: 1) ? EstadoPedido.completado : EstadoPedido.enProceso);
          
          var estado = pedido["verificado"] == 1 ? EstadoPedido.completado : (_difference(tz.TZDateTime.now(tz.getLocation('America/Santiago')), _parseDate(pedido["fecha_pedido"])) > const Duration(hours: 1) ? EstadoPedido.completado : EstadoPedido.enProceso);
          return CartaDePedido(estado: estado, pedido: pedido, deleteCallback: () {
            setState(() {
              
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pedido eliminado')),
            );
          });
        }),
      ],
    );
  }

  DateTime _parseDate(dynamic date) {
    if (date is String) {
      return DateTime.parse(date);
    } else if (date is DateTime) {
      return date;
    } else {
      // Manejo de error si el tipo de dato es inesperado
      throw Exception('Formato de fecha inesperado');
    }
  }

  // testing necesario
  Future<List<Map<String, dynamic>>> _fetchPedidos() async {
    Iterable pedidos;
    // Obtener el ID del usuario
    final userId = context.read<LoginState>().user!.id;
    final url = Uri.parse("${dotenv.env["API_URL"]}/get-pedidos-from-user?usuario_id=$userId");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      pedidos = jsonDecode(response.body) as List<dynamic>;
      // return 3 - results.where((element) {
      //   return (tz.TZDateTime.now(tz.getLocation('America/Santiago'))).isAtSameDayAs(element["fecha_pedido"]);
      // }).length;
    } else {
      throw Exception("Hubo un error al contar los pedidos hechos: ${response.statusCode}");
    }
    // final table = MySqlTable("pedidos");

    // Filtrar pedidos por ID de usuario
    // final results = await table.where('usuario_id', userId);
    //final pedidos = results.map((row) => row.fields).toList();
    final todayPedidos = <Map<String, dynamic>>[];
    for (var pedido in pedidos) {
      final fechaPedido = _parseDate(pedido['fecha_pedido']);
      if (fechaPedido.isAtSameDayAs(tz.TZDateTime.now(tz.getLocation('America/Santiago')))) {
        todayPedidos.add(pedido);
      } 
      // if (fechaPedido.isAtSameDayAs(DateTime.now())) {
      //   todayPedidos.add(pedido);
      // } 
    }
    return todayPedidos;
  }
}


class ExpansionCard extends StatefulWidget {

  const ExpansionCard({super.key, this.primaryColor, this.secondaryColor, required this.title, required this.body});
  final String title;
  final Widget body;
  final Color? primaryColor;
  final Color? secondaryColor;

  @override
  State<StatefulWidget> createState() {
    return _ExpansionCardState();
  }
}

class _ExpansionCardState extends State<ExpansionCard> {

  
  
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: double.infinity,
        child:
        Theme(
        data: ThemeData(
          splashColor: Colors.black.withOpacity(0.075),
          highlightColor: Colors.black.withOpacity(0.075)
        ),
        child:
        ExpansionTile(
          shape: const Border(),
          collapsedIconColor: widget.secondaryColor,
          iconColor: Colors.black,
          backgroundColor: widget.secondaryColor,
          collapsedBackgroundColor: widget.primaryColor,
          collapsedTextColor: Colors.white,
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          children: [widget.body]
        ),
      )
      )
    );
  }
}

class CartaDePedido extends StatefulWidget {
  const CartaDePedido({super.key, this.deleteCallback, required this.estado, required this.pedido});

  final VoidCallback? deleteCallback;
  final Map<String, dynamic> pedido;
  final EstadoPedido estado;

  @override
  State<StatefulWidget> createState() {
    return _CartaDePedidoState();
  }
}

class _CartaDePedidoState extends State<CartaDePedido> {
  
  late EstadoPedido estado;
  Duration timeLeft = const Duration(hours: 1);
  late Timer timer;


  String _formatDuration(Duration duration) {
    return duration.toString().substring(0, duration.toString().length - 7);
  }
  @override
  void initState() {
    super.initState();
    estado = widget.estado;
    if (estado == EstadoPedido.enProceso) {

      timeLeft = const Duration(hours: 1) - _difference(tz.TZDateTime.now(tz.getLocation('America/Santiago')), DateTime.parse(widget.pedido["fecha_pedido"]));
      timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimeLeft());
    }
  }

  void _updateTimeLeft() {
    if (!mounted) {
      return;
    }
    setState(() {
      timeLeft = const Duration(hours: 1) - _difference(tz.TZDateTime.now(tz.getLocation('America/Santiago')), DateTime.parse(widget.pedido["fecha_pedido"]));
    
      if (timeLeft <= Duration.zero) {
        timer.cancel();
        estado = EstadoPedido.completado;
      }
    });
  }

  Color _getStatusColor(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.enProceso:
        return Colors.blue;
      case EstadoPedido.completado:
        return Colors.red;
      default:
        return Colors.black87;
    }
  }

  Color _getCardColor(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.enProceso:
        return Colors.yellow[100]!;
      case EstadoPedido.completado:
        return Colors.grey[300]!;
      default:
        return Colors.black87;
    }
  }
  Future<void> _showExpandedQr(BuildContext context, QrImageView qrCode, String numeroPedido) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  numeroPedido,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.secondary)
              )
            ]
          ),
          content: SizedBox.square(
            dimension: 250,
            child: qrCode,
          ),
        );
      },
    );
  }
  String _getStatusName(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.enProceso:
        return "En proceso";
      case EstadoPedido.completado:
        return "Completado";
    }
  }
  List<Widget> _getQrCode(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.enProceso:
        var qr = QrImageView(
          padding: EdgeInsets.zero,
          eyeStyle: const QrEyeStyle(
            color: Colors.black,
            eyeShape: QrEyeShape.square
          ),
          dataModuleStyle: const QrDataModuleStyle(
            color: Colors.black,
            dataModuleShape: QrDataModuleShape.square
          ),
          data: "${dotenv.env["API_URL"]!}pedidos/${widget.pedido["id"]}", // widget.pedido["qr_code"]?? "",
          version: QrVersions.auto,
        );
        return [Expanded(
          flex: 2,
          child: InkWell(
            highlightColor: Colors.black.withOpacity(0.075),
            splashColor: Colors.black.withOpacity(0.075),
            onTap: () {
              _showExpandedQr(context, qr, widget.pedido["numero_pedido"]);
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              width: 80,
              child: Column(
                children: [
                  Text(
                    _formatDuration(timeLeft),
                    style: TextStyle(
                      fontSize: 16,
                      color: _getStatusColor(estado),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  qr,
                  const SizedBox(height: 8),
                  const Icon(Icons.open_in_full)
                ]
              )
            )
          )
        )];
      default:
        return [];
    }
  }
  String _capitalizeFirstLetter(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    var informationTextColor = estado == EstadoPedido.enProceso ? null : Colors.grey;
    var formattedDate = _capitalizeFirstLetter(DateFormat('EEEE dd-MM-yyyy', 'es_ES').format(DateTime.parse(widget.pedido["fecha_pedido"])));
    return ExpansionCard(
      title: "Pedido para ${widget.pedido["menu_principal"].toLowerCase()}",
      primaryColor: _getStatusColor(estado),
      secondaryColor: _getCardColor(estado),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Número de Pedido: ${widget.pedido['numero_pedido']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Tamaño de fuente del subtítulo
                          color: informationTextColor,
                        ),
                      ),
                      Text('Fecha: $formattedDate',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16, // Tamaño de fuente del subtítulo
                          color: informationTextColor,
                        ),
                      ),
                      Text('Menú Principal: ${widget.pedido['menu_principal']}',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16, // Tamaño de fuente del subtítulo
                          color: informationTextColor,
                        ),
                      ),
                    ]
                  ),
                ),
              ] + (_getQrCode(estado))
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  'Estado: ${_getStatusName(estado)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getStatusColor(estado)
                  ),
                ),
              ]
            )
          ],
        )
      )
    );
  }
}
enum EstadoPedido {
  completado,
  enProceso,
}

Duration _difference(DateTime a, DateTime b) {
  var stringA = DateFormat("yyyy-MM-dd HH:mm:ss").format(a);
  var stringB = DateFormat("yyyy-MM-dd HH:mm:ss").format(b);
  var dateA = DateTime.parse(stringA);
  var dateB = DateTime.parse(stringB);
  return dateA.difference(dateB);
}