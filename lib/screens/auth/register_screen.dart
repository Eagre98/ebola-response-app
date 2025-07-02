import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Medical Team')),
      body: const Center(
          child: Text('Registration Screen Placeholder',
              style: TextStyle(color: Colors.white))),
    );
  }
}
