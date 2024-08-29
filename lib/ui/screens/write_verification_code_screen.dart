import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class WriteVerificationCodeScreen extends StatelessWidget {
  WriteVerificationCodeScreen(this.verificationCode, this.email, {super.key});

  final int verificationCode;
  final String email;
  final verifCodeFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                  "Introduce el código de verificación que te enviamos por correo",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 50),
                _VerificationCodeField(verificationCode, email: email)
              ]
            )
          )
        ]
      )
    );
  }
}

class _VerificationCodeField extends StatefulWidget {
  const _VerificationCodeField(this.verificationCode, {required this.email});

  final String email;
  final int verificationCode;

  @override
  State<StatefulWidget> createState() {
    return _VerificationCodeFieldState();
  }
}

class _VerificationCodeFieldState extends State<_VerificationCodeField> {
  List<FocusNode> focusNodes = [];
  List<TextEditingController> controllers = [];
  String? error;

  @override
  void initState() {
    initControllers();
    initFocusNodes();
    super.initState();
  }

  void initFocusNodes() {
    for (var i = 0; i < widget.verificationCode.toString().length; i++) {
      focusNodes.add(
        FocusNode(
          onKeyEvent: (focusNode, keyEvent) {
            if (keyEvent.character != null) {
              if (i+1 < widget.verificationCode.toString().length) {
                focusNodes[i+1].requestFocus();
              } else {
                FocusScope.of(context).unfocus();
              }
              if (controllers[i].text == "") {
                controllers[i].text = keyEvent.character!;
              } else if (i+1 < widget.verificationCode.toString().length) {
                controllers[i+1].text = keyEvent.character!;
              }
            }
            if (keyEvent.logicalKey == LogicalKeyboardKey.backspace && keyEvent.runtimeType.toString() == "KeyUpEvent") {
              if (i > 0) {
                focusNodes[i-1].requestFocus();
              }
              if (controllers[i].text != "") {
                controllers[i].text = "";
              } else if (i > 0) {
                controllers[i-1].text = "";
              }
            }
            return KeyEventResult.handled;
          },
        )
      );
    }
  }

  void initControllers() {
    for (var i = 0; i < widget.verificationCode.toString().length; i++) {
      controllers.add(TextEditingController());
    }
  }

  List<Widget> getFields() {
    var fields = <Widget>[];
    for (var i = 0; i < widget.verificationCode.toString().length; i++) {
      fields.add(
        SizedBox(
          width: 49,
          child: TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            controller: controllers[i],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
              color: Theme.of(context).colorScheme.secondary
            ),
            decoration: InputDecoration(
              counterText: "",
              contentPadding: const EdgeInsets.all(0),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(49)),
                borderSide: BorderSide(width: 3, color: Colors.transparent)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(49)),
                borderSide: BorderSide(width: 3, color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3))
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
            textAlign: TextAlign.center,
            focusNode: focusNodes[i],
            maxLength: 1,
          ),
        )
      );
    }
    return fields;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: (
          error != null ?
          <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              const Spacer()
              ],
            ),
          const SizedBox(height: 20)] : 
          <Widget>[]
        ) + 
        [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: getFields()
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              if (isVerificationCodeCorrect()) {
                Navigator.of(context).pushNamed("/choose_password", arguments: {"email": widget.email});
              } else {
                setState(() {
                  error = "El codigo de verificacion no es correcto";
                });
              }
            },
            child: const Text("Confirmar")
          )
        ]
      )
    );
  }
  bool isVerificationCodeCorrect() {
    String value = "";
    for (var controller in controllers) {
      value += controller.text;
    }
    return value == widget.verificationCode.toString();
  }
}