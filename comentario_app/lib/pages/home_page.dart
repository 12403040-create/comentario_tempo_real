import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';
import 'post_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _text = TextEditingController();

  Future<void> _publish() async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    _text.clear();
    await context.read<FirestoreService>().addPost(t);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _text,
                decoration: const InputDecoration(
                    hintText: 'No que você está pensando?',
                    border: OutlineInputBorder()),
                onSubmitted: (_) => _publish(),
              ),
            ),
            IconButton(icon: const Icon(Icons.send), onPressed: _publish),
          ]),
        ),
        Expanded(
          child: StreamBuilder(
            stream: service.postsStream(),
            builder: (context, snap) {
              if (snap.hasError) return Center(child: Text('${snap.error}'));
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('Nenhuma publicação ainda.'));
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  final data = d.data();
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(data['text'] ?? ''),
                      subtitle: Text(data['authorName'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        tooltip: 'Comentários',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PostPage(postId: d.id)),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
