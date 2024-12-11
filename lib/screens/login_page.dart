import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Importa shared_preferences
import '../services/database_service.dart';
import 'club_screen.dart';  // Importa la pantalla del club

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true;  // Inicialmente, la contraseña está oculta
  bool _keepLoggedIn = false;  // Inicialmente, no mantener la sesión iniciada

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          if (_keepLoggedIn) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('keepLoggedIn', true);
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClubScreen(email: _emailController.text),  // Navegar a la pantalla del club con el email del usuario
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario o contraseña incorrecta.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: _obscureText,  // Usar el estado para mostrar/ocultar la contraseña
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Checkbox(
                    value: !_obscureText,
                    onChanged: (value) {
                      setState(() {
                        _obscureText = !value!;
                      });
                    },
                  ),
                  const Text('Mostrar contraseña'),
                ],
              ),
              CheckboxListTile(
                title: const Text('Mantener sesión iniciada'),
                value: _keepLoggedIn,
                onChanged: (bool? value) {
                  setState(() {
                    _keepLoggedIn = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
