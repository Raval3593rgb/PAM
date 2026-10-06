import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [ 
           TextField(
            decoration: const InputDecoration(
              labelText: 'Email',
              ),
            ),

            TextField(
            obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                ),
            ),
        
          ],
        ),
      ),
    );
  }
}


