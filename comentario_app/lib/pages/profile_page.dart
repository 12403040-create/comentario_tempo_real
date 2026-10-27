import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final _name = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.displayName ?? '');

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Text(user.email ?? '', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome')),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await context
                  .read<FirestoreService>()
                  .updateName(_name.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nome atualizado!')));
              }
            },
            child: const Text('Salvar'),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ]),
      ),
    );
  }
}
