import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';

/// Tela da discussão: mostra a publicação + comentários em tempo real.
class PostPage extends StatefulWidget {
  final String postId;
  const PostPage({super.key, required this.postId});
  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _text = TextEditingController();

  Future<void> _send() async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    _text.clear();
    await context.read<FirestoreService>().addComment(widget.postId, t);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Discussão')),
      body: Column(children: [
        // Publicação selecionada
        StreamBuilder(
          stream: service.postStream(widget.postId),
          builder: (context, snap) {
            final data = snap.data?.data();
            if (data == null) {
              return const Padding(
                  padding: EdgeInsets.all(16),
                  child: LinearProgressIndicator());
            }
            return Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['text'] ?? '',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('por ${data['authorName'] ?? ''}'),
                ],
              ),
            );
          },
        ),
        // Comentários em tempo real (somente desta publicação)
        Expanded(
          child: StreamBuilder(
            stream: service.commentsStream(widget.postId),
            builder: (context, snap) {
              if (snap.hasError) return Center(child: Text('${snap.error}'));
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!;
              if (docs.isEmpty) {
                return const Center(child: Text('Seja o primeiro a comentar!'));
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  final c = d.data();
                  final mine = c['authorUid'] == service.uid;
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(c['authorName'] ?? ''),
                    subtitle: Text(c['text'] ?? ''),
                    // Só o dono do comentário vê o botão de excluir
                    trailing: mine
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => service.deleteComment(d.id),
                          )
                        : null,
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  decoration: const InputDecoration(
                      hintText: 'Escreva um comentário...',
                      border: OutlineInputBorder()),
                  onSubmitted: (_) => _send(),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: _send),
            ]),
          ),
        ),
      ]),
    );
  }
}
