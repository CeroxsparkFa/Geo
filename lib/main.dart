
import 'package:flutter/material.dart';
import 'package:geoblast/utils/helpers/route_generator.dart';
import 'package:geoblast/ui/themes/main_theme.dart';
import 'package:geoblast/data/login_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:geoblast/utils/constants/globals.dart' as globals;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}


// Future<void> _requestPermissions() async {
//   if (await Permission.notification.isDenied) {
//     await Permission.notification.request();
//   }
//   if (await Permission.scheduleExactAlarm.isDenied) {
//     await Permission.scheduleExactAlarm.request();
//   }
// }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static late SharedPreferences preferences;
  static retrievePreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginState()),
      ],
      builder: (context, child) => MaterialApp(
        navigatorObservers: [globals.routeObserver],
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: "/initial_route",
        title: 'Geoblast',
        theme: MainTheme.getTheme()
      )
    );  
  }
}


Future<void> initialize() async {
  // await dotenv.load(fileName: "assets/.env");
  // final url = Uri.parse("${dotenv.env["BASE_URL"]}mobile/insert-pedido");
  // final postResponse = await http.post(
  //   url,
  //   headers: {
  //     'Content-Type': 'application/json',
  //   },
  //   body: jsonEncode({
  //     'numero_pedido': 'Test_93923938',
  //     'usuario_id': 9,
  //     'menu_principal': 'Desayuno',
  //     'fecha_pedido': DateTime.now().toIso8601String()
  //   }),
  // );

  // if (postResponse.statusCode == 200) {
  //   print('Request successful: ${postResponse.body}');
  // } else {
  //   print('Request failed with status: ${postResponse.statusCode}');
  // }




  tz.initializeTimeZones();
  await dotenv.load(fileName: "assets/.env");
  //await MySql.stablishConnection(dotenv.env["DB_HOST"], int.parse(dotenv.env["DB_PORT"]!), dotenv.env["DB_USERNAME"], dotenv.env["DB_PASSWORD"], dotenv.env["DB_DATABASE"]);
  await MyApp.retrievePreferences();
  await initializeDateFormatting('es_CL', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(provisional: true);



  // final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  // if (apnsToken != null) {
  //   print(apnsToken);
  // }
  // FirebaseMessaging.instance.getToken().then((token) {
  //   MySqlTable("users").update({"tokens": "$token"}, "id", 10);
  //   print("FCM Token: $token");
  // });
}
