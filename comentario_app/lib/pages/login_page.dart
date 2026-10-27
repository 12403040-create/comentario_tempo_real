import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _register = false;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final auth = FirebaseAuth.instance;
      if (_register) {
        final cred = await auth.createUserWithEmailAndPassword(
            email: _email.text.trim(), password: _pass.text);
        await cred.user!.updateDisplayName(_name.text.trim());
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set({'name': _name.text.trim(), 'email': _email.text.trim()});
      } else {
        await auth.signInWithEmailAndPassword(
            email: _email.text.trim(), password: _pass.text);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_register ? 'Cadastro' : 'Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(children: [
              if (_register)
                TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nome')),
              TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail')),
              TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha')),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : FilledButton(
                      onPressed: _submit,
                      child: Text(_register ? 'Cadastrar' : 'Entrar')),
              TextButton(
                onPressed: () => setState(() => _register = !_register),
                child: Text(_register
                    ? 'Já tenho conta'
                    : 'Não tenho conta. Cadastrar'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
