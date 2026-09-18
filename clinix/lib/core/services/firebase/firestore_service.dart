import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic Firestore helpers.
///
/// BACKEND INTEGRATION: during the backend phase, decide which collections the
/// app reads directly (low-risk public data) vs. which are only reachable via
/// FastAPI (sensitive data such as stock mutations, donor contacts, admin
/// actions). Firestore security rules will enforce the decision — this client
/// file is just plumbing.
class FirestoreService {
  FirestoreService({FirebaseFirestore? instance})
      : _db = instance ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(
    String collectionPath,
    String docId,
  ) =>
      _db.collection(collectionPath).doc(docId).get();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCollection(
    String collectionPath, {
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        build,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(collectionPath);
    query = build?.call(query) ?? query;
    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<String> addDoc(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    final ref = await _db.collection(collectionPath).add(data);
    return ref.id;
  }

  Future<void> setDoc(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) =>
      _db.collection(collectionPath).doc(docId).set(
            data,
            SetOptions(merge: merge),
          );

  Future<void> deleteDoc(String collectionPath, String docId) =>
      _db.collection(collectionPath).doc(docId).delete();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(
    String collectionPath,
  ) =>
      _db.collection(collectionPath).snapshots();
}
