import 'package:flutter/material.dart';

class OwnerLoginPage extends StatelessWidget {
  const OwnerLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Login"),
        backgroundColor: const Color(0xFF1F104B),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Owner Login Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
