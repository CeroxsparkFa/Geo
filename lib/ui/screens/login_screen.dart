import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoblast/ui/widgets/keyboard_responsive_header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geoblast/main.dart';
import 'package:geoblast/ui/widgets/icon_text_form_field.dart';
import 'package:geoblast/data/models/user.dart';
import 'package:geoblast/data/login_state.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:geoblast/utils/helpers/validators.dart' as validators;


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          KeyboardResponsiveHeader(
            initialSize: MediaQuery.sizeOf(context).height * 3/8,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Bienvenido a",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    textStyle:  TextStyle(
                      fontSize: 35,
                      color: Theme.of(context).colorScheme.surface
                    )
                  )
                ),
                Image.asset("assets/images/GB_inv-1024x246.png")
              ]
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const _LoginForm(includeRegisterButton: false)
            )
          ),
        ]
      )
    );
  }
}

class _LoginForm extends StatefulWidget {

  const _LoginForm({this.includeRegisterButton = true, this.includeChangePasswordButton = true});
  
  final bool includeRegisterButton;
  final bool includeChangePasswordButton;

  @override
  State<StatefulWidget> createState() {
    return _LoginFormState();
  }
}

class _LoginFormState extends State<_LoginForm> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final rutFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {


    var loginButton = ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(const SnackBar(content: Text("Procesando datos...")));
          try {
            bool rutAndPasswordAreCorrect = await login(rutFieldController.text, passwordFieldController.text);
            messenger.clearSnackBars();
            if (rutAndPasswordAreCorrect) {
              navigator.popAndPushNamed("/");
              messenger.showSnackBar(const SnackBar(content: Text("Has iniciado sesión correctamente")));
            } else {
              setState(() {
                error = "Correo o contraseña incorrectos";
              });
            }
          } catch (e) {
            messenger.clearSnackBars();
            messenger.showSnackBar(SnackBar(content: Text("Ha ocurrido un error, revisa tu conexión o vuelve a intentarlo mas tarde $e")));
          }
        } 
      },
      child: const Text("Iniciar Sesión")
    );

    var changePasswordButton = TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed("/change_password");
      },
      child: const Text(
        "Olvidaste tu contraseña?"
      ),
    );

    var errorElements = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            error?? "",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer()
        ],
      ),
      const SizedBox(height: 20)
    ];

    var formBody = Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: (error == null ? <Widget>[] : errorElements) + [
          // IconTextFormField(
          //   color: Theme.of(context).colorScheme.secondary,
          //   focusColor: Theme.of(context).colorScheme.tertiary,
          //   validator: validators.emailValidator,
          //   label: "Correo",
          //   placeholderString: "Introduce tu correo electronico",
          //   icon: Icons.email,
          //   controller: emailFieldController,
          // ),
          IconTextFormField(
            color: Theme.of(context).colorScheme.secondary,
            focusColor: Theme.of(context).colorScheme.tertiary,
            validator: validators.isFieldEmpty,
            label: "Rut",
            placeholderString: "Introduce tu rut",
            icon: Icons.credit_card,
            controller: rutFieldController,
          ),
          const SizedBox(height: 30),
          IconTextFormField(
            color: Theme.of(context).colorScheme.secondary,
            focusColor: Theme.of(context).colorScheme.tertiary,
            validator: validators.isFieldEmpty,
            label: "Contraseña",
            placeholderString: "Introduce tu contraseña",
            icon: Icons.key,
            privateField: true,
            controller: passwordFieldController,
          ),
          const SizedBox(height: 30),
          widget.includeChangePasswordButton ? Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              changePasswordButton,
              loginButton
            ],
          ) : loginButton,
        ],
      ),
    );

    var registerButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("No tienes una cuenta?"),
        TextButton(
          onPressed: () {
            Navigator.of(context).popAndPushNamed("/register");
          },
          child: const Text("Registrate")
        )
      ]
    );
    return widget.includeRegisterButton ? Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        formBody,
        registerButton
      ]
    ) : formBody;
  }
  Future<bool> login(String rut, String password) async {
    final loginState = context.read<LoginState>();
    final url = Uri.parse("${dotenv.env["API_URL"]}/validate-user-credentials?rut=$rut&password=$password");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // print("ok");
      if (response.body != "") {
        var user = jsonDecode(response.body) as Map<String, dynamic>;
        // print(user);
        loginState.setUser(User(rut: rut, cargo: user["cargo"], turnoId: user["turno_id"], email: user["email"], name: user["name"], id: user["id"]));
        MyApp.preferences.setString("encryptedPassword", password);
        MyApp.preferences.setString("rut", rut);
        // FirebaseMessaging.instance.getToken().then((String? token) {
        //   String userDeviceTokens = user["tokens"];
        //   if (MyApp.preferences.getString("tokenFromThisDevice") == null) {
        //     userDeviceTokens += token == null ? "" : " $token";
        //   } else if (MyApp.preferences.getString("tokenFromThisDevice") != token) {
        //     userDeviceTokens += token == null ? "" : " $token";
        //   }
        //   MySqlTable("users").update({"tokens": userDeviceTokens}, "id", user["id"]);
        //   MyApp.preferences.setString("tokenFromThisDevice", token?? "");
        // });
        // FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
        //   String userDeviceTokens = user["tokens"];
        //   userDeviceTokens.replaceAll(MyApp.preferences.getString("tokenFromThisDevice")?? "", token);
        //   MySqlTable("users").update({"tokens": userDeviceTokens}, "id", user["id"]);
        //   MyApp.preferences.setString("tokenFromThisDevice", token);
        // });
      }
      return response.body != "";
    } else {
      throw Exception("Hubo un error al intentar recuperar el usuario: ${response.statusCode}");
    }
    // final user = (await MySqlTable("users").where("rut", rut)).firstOrNull;
    // final bool rutAndPasswordAreCorrect = user == null ? false : await FlutterBcrypt.verify(password: password, hash: user["password"]);
    // if (rutAndPasswordAreCorrect) {
    //   loginState.setUser(User(rut: rut, cargo: user["cargo"], turnoId: user["turno_id"], email: user["email"], name: user["name"], id: user["id"]));
    //   MyApp.preferences.setString("encryptedPassword", user["password"]);
    //   MyApp.preferences.setString("rut", rut);
  }
} 
    // return rutAndPasswordAreCorrect;
  // Future<bool> login(String email, String password) async {
  //   final loginState = context.read<LoginState>();
  //   final user = (await MySqlTable("users").where("email", email)).firstOrNull;
  //   final bool emailAndPasswordAreCorrect = user == null ? false : await FlutterBcrypt.verify(password: password, hash: user["password"]);
  //   if (emailAndPasswordAreCorrect) {
  //     loginState.setUser(User(rut: user["rut"], cargo: user["cargo"], turnoId: user["turno_id"], email: email, name: user["name"], id: user["id"]));
  //     MyApp.preferences.setString("encryptedPassword", user["password"]);
  //     MyApp.preferences.setString("email", email);

  //     FirebaseMessaging.instance.getToken().then((String? token) {
  //       String userDeviceTokens = user["tokens"];
  //       if (MyApp.preferences.getString("tokenFromThisDevice") == null) {
  //         userDeviceTokens += token == null ? "" : " $token";
  //       } else if (MyApp.preferences.getString("tokenFromThisDevice") != token) {
  //         userDeviceTokens += token == null ? "" : " $token";
  //       }
  //       MySqlTable("users").update({"tokens": userDeviceTokens}, "id", user["id"]);
  //       MyApp.preferences.setString("tokenFromThisDevice", token?? "");
  //     });
  //     FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
  //       String userDeviceTokens = user["tokens"];
  //       userDeviceTokens.replaceAll(MyApp.preferences.getString("tokenFromThisDevice")?? "", token);
  //       MySqlTable("users").update({"tokens": userDeviceTokens}, "id", user["id"]);
  //       MyApp.preferences.setString("tokenFromThisDevice", token);
  //     });
  //   }
  //   return emailAndPasswordAreCorrect;
    
    // if (!result) {
    //   setState(() {
    //     error = "Correo o contraseña incorrectos";
    //   });
    //   return;
    // }
    // loginState.setUser(User(rut: user["rut"], cargo: user["cargo"], turnoId: user["turno_id"], email: email, name: user["name"], id: user["id"]));
    // MyApp.preferences.setString("encryptedPassword", user["password"]);
    // MyApp.preferences.setString("email", email);
    // navigator.popAndPushNamed("/");
    // messenger.showSnackBar(const SnackBar(content: Text("Has iniciado sesión correctamente")));


