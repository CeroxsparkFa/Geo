import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoblast/data/login_state.dart';
import 'package:geoblast/ui/screens/screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geoblast/utils/helpers/date_time_extension.dart';
import 'package:geoblast/utils/constants/globals.dart' as globals;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatelessWidget implements Screen {
  const HomePage({super.key});
  
  @override
  String get title => "Inicio";

  @override
  IconData get icon => Icons.home;


  @override
  Widget build(BuildContext context) {
    var userFirstName = context.read<LoginState>().user!.name.split(" ")[0];
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Bienvenido, $userFirstName",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.account_circle,
                size: 86,
                color: Theme.of(context).colorScheme.tertiary
              )
              // ClipOval(
              //   child: SizedBox(
              //     width: 86,
              //     height: 86,

              //     // size: Size.fromRadius(32),
              //     child: Image.asset("assets/images/profile_pic.png", fit: BoxFit.cover),
              //   )
              // ),
            ]
          ),
          const Divider(
            thickness: 2,
            height: 32,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Información",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.calendar_today,
                  color: Theme.of(context).colorScheme.secondary
                ),
                title: Text(
                  "Fecha actual: ${DateFormat.yMd("es_CL").format(tz.TZDateTime.now(tz.getLocation('America/Santiago')))}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary
                  )
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person,
                  color: Theme.of(context).colorScheme.secondary
                ),
                title: Text("Nombre completo: ${context.read<LoginState>().user!.name}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary
                  )
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.credit_card,
                  color: Theme.of(context).colorScheme.secondary
                ),
                title: Text(
                  "Rut: ${context.read<LoginState>().user!.rut}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary
                  )
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.email,
                  color: Theme.of(context).colorScheme.secondary
                ),
                title: Text("Correo electrónico: ${context.read<LoginState>().user!.email}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary
                  )
                ),
              ),
            ]
          ),
          const Divider(
            thickness: 2,
            height: 32,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tus pedidos",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900
                ),
              ),
              const SizedBox(height: 8),
              AsyncCounterInformationCard(
                cardColor: Theme.of(context).colorScheme.primary,
                labelBuilder: (counter) {
                  if (counter == 1) {
                    return "Disponible";
                  }
                  return "Disponibles";
                },
                counter: () async {
                  final url = Uri.parse("${dotenv.env["API_URL"]}/get-pedidos-from-user?usuario_id=${context.read<LoginState>().user!.id}");
                  final response = await http.get(
                    url,
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  );
                  if (response.statusCode >= 200 && response.statusCode < 300) {
                    //var pedidos = jsonDecode(response.body) as Map<String, dynamic>;
                    var pedidos = jsonDecode(response.body) as List<dynamic>;
                    return 3 - pedidos.where((element) {
                      var fechaPedidoParsed = DateTime.parse(element["fecha_pedido"]);
                      return (tz.TZDateTime.now(tz.getLocation('America/Santiago'))).isAtSameDayAs(fechaPedidoParsed);
                    }).length;
                  } else {
                    throw Exception("Hubo un error al contar los pedidos disponibles: ${response.statusCode}");
                  }
                },
                rightSideBuilder: (context, counter) {
                  if (counter <= 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      height: double.infinity,
                      width: double.infinity,
                      child: const Center(
                        child: Text(
                          "No tienes pedidos disponibles porque ya hiciste los 3 del día o no estas en tu turno",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          )
                        )
                      )
                    );
                  }
                  return InkWell(
                    highlightColor: Colors.black.withOpacity(0.075),
                    splashColor: Colors.black.withOpacity(0.075),
                    onTap: () {
                      Navigator.of(context).pushNamed("/menu_form");
                    },
                    child: const SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                        child: ListTile(
                          trailing: Icon(
                            Icons.arrow_forward_ios, 
                            color: Colors.white,
                            size: 16
                          ),
                          title: Text(
                            "Accede al formulario",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                            )
                          )
                        )
                      )
                    )
                  );
                }
              ),
              AsyncCounterInformationCard(
                cardColor: Theme.of(context).colorScheme.tertiary,
                labelBuilder: (counter) {
                  if (counter == 1) {
                    return "Hecho";
                  }
                  return "Hechos";
                },
                counter: () async {
                  
                  final url = Uri.parse("${dotenv.env["API_URL"]}/get-pedidos-from-user?usuario_id=${context.read<LoginState>().user!.id}");
                  final response = await http.get(
                    url,
                    headers: {
                      'Content-Type': 'application/json',
                    },
                  );
                  if (response.statusCode >= 200 && response.statusCode < 300) {
                    //var pedidos = jsonDecode(response.body) as Map<String, dynamic>;
                    var pedidos = jsonDecode(response.body) as List<dynamic>;
                    return pedidos.where((element) {
                      var fechaPedidoParsed = DateTime.parse(element["fecha_pedido"]);
                      return (tz.TZDateTime.now(tz.getLocation('America/Santiago'))).isAtSameDayAs(fechaPedidoParsed);
                    }).length;
                  } else {
                    throw Exception("Hubo un error al contar los pedidos hechos: ${response.statusCode}");
                  }
                },
                rightSideBuilder: (context, _) {
                  return InkWell(
                    highlightColor: Colors.black.withOpacity(0.075),
                    splashColor: Colors.black.withOpacity(0.075),
                    onTap: () {
                      Navigator.of(context).pushNamed("/menu_visual");
                    },
                    child: const SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Center(
                        child: ListTile(
                          trailing: Icon(
                            Icons.arrow_forward_ios, 
                            color: Colors.white,
                            size: 16
                          ),
                          title: Text(
                            "Ver detalles",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                            )
                          )
                        )
                      )
                    )
                  );
                }
              ),
            ]
          )
        ],
      ),
    );
  }
}

class AsyncCounterInformationCard extends StatefulWidget {
  const AsyncCounterInformationCard({super.key, required this.labelBuilder, required this.counter, required this.rightSideBuilder, this.cardColor});


  final Future<int> Function() counter;

  final String Function(int) labelBuilder;
  final Widget Function(BuildContext, int) rightSideBuilder;
  final Color? cardColor;

  @override
  State<StatefulWidget> createState() {
    return _AsyncCounterInformationCardState();
  }
}

class _AsyncCounterInformationCardState extends State<AsyncCounterInformationCard> with RouteAware {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    globals.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    globals.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var count = widget.counter();
    return Card.filled(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: widget.cardColor,
      child: SizedBox(
        height: 115,
        width: double.infinity,
        child: FutureBuilder(
          future: count,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Text(
                  "Cargando...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  ),
                )
              );
            } else {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    ),
                  )
                );
              }
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 107,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        snapshot.data.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900
                        ),
                      ),
                      Text(
                        widget.labelBuilder(snapshot.data!),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: widget.rightSideBuilder(context, snapshot.data!)
                )
              ],
            );
          }
        )
      )
    );
  }
}