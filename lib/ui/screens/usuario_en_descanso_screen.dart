
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoblast/data/login_state.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UsuarioEnDescansoScreen extends StatelessWidget {
  const UsuarioEnDescansoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 256),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "Actualmente no tienes un turno asignado, por lo que no puedes acceder a tu cuenta",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popAndPushNamed("/login");
                      context.read<LoginState>().logout();
                    }, 
                    child: const Text("Cerrar sesión")
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _launchGmail(context);
                    }, 
                    child: const Text("Contactarse con soporte")
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }
  Future<void> _launchGmail(BuildContext context) async {
    final String recipient = dotenv.env["SUPPORT_EMAIL"]!;
    final messenger = ScaffoldMessenger.of(context);
    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: recipient,
      query: 'subject=Solicitar alimentación', // Add subject and body if needed
    );

    if (await canLaunchUrl(mailUri)) {
      await launchUrl(mailUri);
    } else {
      messenger.showSnackBar(const SnackBar(content: Text("No se encontró ninguna aplicación instalada para mandar correos electronicos en el dispositivo")));
    }
  }
}