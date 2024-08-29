import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.previousRoute = "/initial_route", required this.exception});
  final String? previousRoute;
  final Object exception;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Error: $exception", 
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
              TextButton(
                onPressed: () { 
                  Navigator.of(context).popAndPushNamed(previousRoute!);
                }, 
                child: const Text("Reintentar")
              )
            ]
          )
        )
      ),
    );
  }
}