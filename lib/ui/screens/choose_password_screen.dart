import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoblast/ui/widgets/icon_text_form_field.dart';
import 'package:http/http.dart' as http;

import 'package:geoblast/utils/helpers/validators.dart' as validators;

class ChoosePasswordScreen extends StatefulWidget {
  const ChoosePasswordScreen(this.email, {super.key});

  final String email;

  @override
  State<StatefulWidget> createState() {
    return _ChoosePasswordScreenState();
  }
}
class _ChoosePasswordScreenState extends State<ChoosePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final passwordFieldController = TextEditingController();
  final confirmPasswordFieldController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    
    var changePasswordButton = ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(const SnackBar(content: Text("Procesando...")));
          try {
            await updatePassword(widget.email, passwordFieldController.text);
          } catch (_) {
            messenger.clearSnackBars();
            messenger.showSnackBar(const SnackBar(content: Text("Ha ocurrido un error, revisa tu conexión o vuelve a intentarlo mas tarde")));
          }
          navigator.popAndPushNamed("/login");
          messenger.clearSnackBars();
          messenger.showSnackBar(const SnackBar(content: Text("Contraseña actualizada correctamente")));
        } 
      },
      child: const Text("Cambiar contraseña")
    );

    return Scaffold(
      body: Stack(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            leading: BackButton(color: Theme.of(context).colorScheme.secondary),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Elige tu nueva contraseña",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconTextFormField(
                        privateField: true,
                        color: Theme.of(context).colorScheme.secondary,
                        focusColor: Theme.of(context).colorScheme.tertiary,
                        validator: validators.passwordValidator,
                        label: "Contraseña",
                        placeholderString: "Introduce tu contraseña",
                        icon: Icons.key,
                        controller: passwordFieldController,
                        onChanged: (text) {
                          setState(() {
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      IconTextFormField(
                        privateField: true,
                        color: Theme.of(context).colorScheme.secondary,
                        focusColor: Theme.of(context).colorScheme.tertiary,
                        validator: validators.getConfirmPasswordValidator(passwordFieldController.text),
                        label: "Confirmar contraseña",
                        placeholderString: "Confirma tu contraseña",
                        icon: Icons.key,
                        controller: confirmPasswordFieldController,
                      ),
                      const SizedBox(height: 30),
                      changePasswordButton
                    ]
                  )
                ),
              ]
            )
          )
        ]
      )
    );
  }

  Future<void> updatePassword(String email, String password) async {
    // var table = MySqlTable("users");
    // var salt = await FlutterBcrypt.saltWithRounds(rounds: 12);
    // var output = await FlutterBcrypt.hashPw(password: password, salt: salt);
    // output = output.replaceFirst(r'$2b$', r'$2y$');
    // await table.update({"password": output}, "email", email);

    final url = Uri.parse("${dotenv.env["API_URL"]}/update-user-password");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email,
        "password": password
      })
    );
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw Exception("Hubo un error al intentar actualizar la contraseña: ${response.statusCode}");
    }
  }
}