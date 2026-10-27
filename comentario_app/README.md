# Comentários em Tempo Real (Flutter + Firebase)

## Como rodar
1. Descompacte e, dentro da pasta, gere as pastas de plataforma: `flutter create .`
2. `flutter pub get`
3. Configure o Firebase (gera o `lib/firebase_options.dart` real):
   - `npm install -g firebase-tools` e `firebase login`
   - `dart pub global activate flutterfire_cli`
   - `dart pub global run flutterfire_cli:flutterfire configure`
4. No Console do Firebase: ative **Authentication > E-mail/senha** e crie o **Cloud Firestore**.
5. Cole o conteúdo de `firestore.rules` em Firestore > Regras e publique.
6. `flutter run` (para testar com 2 contas: dois navegadores/janelas anônimas com `flutter run -d chrome`, ou dois dispositivos).

## Estrutura de dados
- `posts/{id}`: text, authorName, authorUid, createdAt
- `comments/{id}`: text, authorName, authorUid, **postId**, createdAt

## Respostas das questões
1. **Como o Firebase identifica quem escreveu o comentário?** Pelo Firebase Authentication: ao logar, o usuário recebe um UID único. Salvamos esse `authorUid` (e o nome) no comentário. Nas regras, `request.auth.uid` é comparado com `authorUid`, então não dá para fingir ser outra pessoa.
2. **Como relacionar um comentário a uma publicação?** Guardando o id do documento da publicação no campo `postId` do comentário e consultando com `.where('postId', isEqualTo: postId)`.
3. **Por que usar StreamBuilder?** Porque `snapshots()` do Firestore devolve um Stream que emite um novo valor a cada mudança no banco. O StreamBuilder escuta esse Stream e reconstrói a tela sozinho, sem precisar de botão de atualizar ou `setState` manual.
4. **Como garantir que os comentários apareçam automaticamente em contas diferentes?** Todas as contas escutam a mesma consulta (`comments` filtrada por `postId`) via `snapshots()`. Quando alguém grava um comentário no Firestore, o servidor notifica todos os listeners ativos, e cada StreamBuilder atualiza a UI.

## Teste obrigatório
Siga os 6 passos do enunciado: duas contas, publicar na conta A, comentar na conta B com a discussão aberta na A, conferir que aparece sozinho, comentar em outra publicação para validar o filtro e excluir um comentário próprio (o botão de lixeira só aparece nos seus comentários; as regras bloqueiam exclusão de comentários alheios mesmo se tentarem pela API).
