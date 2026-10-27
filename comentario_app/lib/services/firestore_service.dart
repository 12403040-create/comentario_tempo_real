import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  User get _user => FirebaseAuth.instance.currentUser!;
  String get uid => _user.uid;
  String get _name => (_user.displayName?.isNotEmpty ?? false)
      ? _user.displayName!
      : (_user.email ?? 'Anônimo');

  // ---------- PUBLICAÇÕES ----------
  Stream<QuerySnapshot<Map<String, dynamic>>> postsStream() => _db
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> postStream(String postId) =>
      _db.collection('posts').doc(postId).snapshots();

  Future<void> addPost(String text) => _db.collection('posts').add({
        'text': text,
        'authorName': _name,
        'authorUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

  // ---------- COMENTÁRIOS ----------
  // Só traz os comentários cujo postId é igual ao da publicação aberta.
  // A ordenação é feita no cliente para não exigir índice composto.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> commentsStream(
      String postId) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snap) {
      final docs = snap.docs.toList();
      docs.sort((a, b) {
        final ta = a.data()['createdAt'] as Timestamp?;
        final tb = b.data()['createdAt'] as Timestamp?;
        if (ta == null && tb == null) return 0;
        if (ta == null) return 1; // pendente (acabou de enviar) vai pro fim
        if (tb == null) return -1;
        return ta.compareTo(tb);
      });
      return docs;
    });
  }

  Future<void> addComment(String postId, String text) =>
      _db.collection('comments').add({
        'text': text,
        'authorName': _name,
        'authorUid': uid,
        'postId': postId,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteComment(String commentId) =>
      _db.collection('comments').doc(commentId).delete();

  // ---------- PERFIL ----------
  Future<void> updateName(String name) async {
    await _user.updateDisplayName(name);
    await _db.collection('users').doc(uid).set(
        {'name': name, 'email': _user.email}, SetOptions(merge: true));
  }
}
