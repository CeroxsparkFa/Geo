import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geoblast/ui/widgets/icon_text_form_field.dart';
import 'package:geoblast/utils/helpers/validators.dart' as validators;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChangePasswordScreenState();
  }
}
class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailFieldController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
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
    var sendVerificationCodeButton = ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(const SnackBar(content: Text("Procesando...")));
          try {
            final emailInDB = await isEmailInDatabase(emailFieldController.text);
            if (emailInDB) {
              final code = await sendVerificationCode(emailFieldController.text);
              messenger.clearSnackBars();
              navigator.pushNamed("/verification_code", arguments: {"verificationCode": code, "email": emailFieldController.text});
            } else {
              messenger.clearSnackBars();
              setState(() {
                error = "No existe ninguna cuenta registrada con ese correo";
              });
            }
          } catch (_) {
            messenger.clearSnackBars();
            messenger.showSnackBar(const SnackBar(content: Text("Ha ocurrido un error, revisa tu conexión o vuelve a intentarlo mas tarde")));
          }

        } 
      },
      child: const Text("Enviar codigo de verificación")
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
                  "Introduce tu correo para que podamos enviarte un código de verificación",
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
                    children: (error == null ? <Widget>[] : errorElements) + [
                      IconTextFormField(
                        color: Theme.of(context).colorScheme.secondary,
                        focusColor: Theme.of(context).colorScheme.tertiary,
                        validator: validators.emailValidator,
                        label: "Correo",
                        placeholderString: "Introduce tu correo electronico",
                        icon: Icons.email,
                        controller: emailFieldController
                      ),
                      const SizedBox(height: 30),
                      sendVerificationCodeButton
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

  Future<int> sendVerificationCode(String mail) async {
    final int verifCode = Random().nextInt(8999) + 1000;

    String username = dotenv.env["EMAIL_USERNAME"]!;
    String password = dotenv.env["EMAIL_PASSWORD"]!;

    final smtpServer = gmail(username, password);
    final message = Message()
     ..from = Address(username)
     ..recipients.add(mail)
     ..ccRecipients.add(mail)
     ..subject = 'Recuperación de contraseña de Geoblast'
     ..text = 'Tu código de verificación es: $verifCode';
    await send(message, smtpServer);
    return verifCode;
  }
  Future<bool> isEmailInDatabase(String email) async {
    final url = Uri.parse("${dotenv.env["API_URL"]}/email-in-db?email=$email");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(response.body);
      return response.body == "1";
    } else {
      throw Exception("Hubo un error al intentar recuperar el usuario: ${response.statusCode}");
    }
  }
}
