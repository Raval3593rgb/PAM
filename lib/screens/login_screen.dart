
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/auth_api.dart';
import '../data/result.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isRegister = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Настоящая авторизация через FastAPI
  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _busy = true);

    try {
      final auth = context.read<AuthApi>();

      final Result<void> result = _isRegister
          ? await auth.register(
              _emailController.text.trim(),
              _passwordController.text,
              _nameController.text.trim(),
            )
          : await auth.login(
              _emailController.text.trim(),
              _passwordController.text,
            );

      if (!mounted) return;

      switch (result) {
        case Ok():
          // JWT уже сохранён в TokenStore
          context.go('/pets');

        case Err(:final msg):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _switchMode() {
    if (_busy) return;

    setState(() {
      _isRegister = !_isRegister;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegister ? 'Register' : 'Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pets,
                  size: 80,
                  color: Colors.lightGreen,
                ),
                const SizedBox(height: 16),

                Text(
                  'Welcome to PetCare',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),

                // Имя нужно только при регистрации
                if (_isRegister) ...[
                  TextFormField(
                    controller: _nameController,
                    enabled: !_busy,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_isRegister &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _emailController,
                  enabled: !_busy,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }

                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  enabled: !_busy,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }

                    if (value.length < 6) {
                      return 'Password must have at least 6 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _submit,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _isRegister
                                ? Icons.person_add
                                : Icons.login,
                          ),
                    label: Text(
                      _busy
                          ? 'Please wait...'
                          : _isRegister
                              ? 'Register'
                              : 'Sign In',
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: _busy ? null : _switchMode,
                  child: Text(
                    _isRegister
                        ? 'Already have an account? Sign In'
                        : "Don't have an account? Register",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
