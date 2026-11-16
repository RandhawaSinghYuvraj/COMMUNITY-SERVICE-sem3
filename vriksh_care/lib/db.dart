import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'models.dart';

String dayKeyOf(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class Db {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<AppUser?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (snap) => snap.exists ? AppUser.fromDoc(snap) : null,
        );
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': role,
      'points': 0,
      'streak': 0,
      'approvedCount': 0,
      'lastApprovedDay': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Drive>> _drives(Query<Map<String, dynamic>> query) {
    return query
        .snapshots()
        .map((snap) => snap.docs.map(Drive.fromDoc).toList());
  }

  static Stream<List<Drive>> allDrives() => _drives(_db.collection('drives'));

  static Stream<List<Drive>> orgDrives(String orgId) =>
      _drives(_db.collection('drives').where('orgId', isEqualTo: orgId));

  static Stream<List<Drive>> myDrives(String volunteerId) => _drives(
        _db.collection('drives').where('caretakerId', isEqualTo: volunteerId),
      );

  static Future<void> createDrive({
    required AppUser org,
    required String title,
    required String description,
    required int saplings,
    required LatLng point,
  }) async {
    await _db.collection('drives').add({
      'orgId': org.uid,
      'orgName': org.name,
      'title': title,
      'description': description,
      'lat': point.latitude,
      'lng': point.longitude,
      'saplings': saplings,
      'caretakerId': null,
      'caretakerName': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> claimDrive(Drive drive, AppUser me) {
    final ref = _db.collection('drives').doc(drive.id);
    return _db.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      if (snap.data()?['caretakerId'] != null) return false;
      tx.update(ref, {'caretakerId': me.uid, 'caretakerName': me.name});
      return true;
    });
  }

  static Stream<PlantUpdate?> todayUpdate(String driveId) {
    final key = dayKeyOf(DateTime.now());
    return _db
        .collection('updates')
        .doc('${driveId}_$key')
        .snapshots()
        .map((snap) => snap.exists ? PlantUpdate.fromDoc(snap) : null);
  }

  static Future<String?> submitUpdate({
    required Drive drive,
    required AppUser me,
    required String condition,
    required String note,
    required String photo,
  }) async {
    final key = dayKeyOf(DateTime.now());
    final ref = _db.collection('updates').doc('${drive.id}_$key');
    final existing = await ref.get();
    if (existing.exists && existing.data()?['status'] != 'rejected') {
      return 'You already sent an update for this location today.';
    }
    await ref.set({
      'driveId': drive.id,
      'driveTitle': drive.title,
      'orgId': drive.orgId,
      'volunteerId': me.uid,
      'volunteerName': me.name,
      'condition': condition,
      'note': note,
      'photo': photo,
      'status': 'pending',
      'dayKey': key,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return null;
  }

  static Stream<List<PlantUpdate>> pendingFor(String orgId) {
    return _db
        .collection('updates')
        .where('orgId', isEqualTo: orgId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map(PlantUpdate.fromDoc).toList());
  }

  static Future<void> reject(PlantUpdate update) {
    return _db.collection('updates').doc(update.id).update({'status': 'rejected'});
  }

  static Future<void> approve(PlantUpdate update) {
    final updateRef = _db.collection('updates').doc(update.id);
    final userRef = _db.collection('users').doc(update.volunteerId);
    return _db.runTransaction<void>((tx) async {
      final updateSnap = await tx.get(updateRef);
      if (updateSnap.data()?['status'] != 'pending') return;
      final userSnap = await tx.get(userRef);
      final data = userSnap.data() ?? {};
      final lastDay = (data['lastApprovedDay'] ?? '') as String;
      var streak = ((data['streak'] ?? 0) as num).toInt();
      var newLastDay = lastDay;
      if (lastDay.compareTo(update.dayKey) < 0) {
        final yesterday = dayKeyOf(
          DateTime.parse('${update.dayKey}T00:00:00Z')
              .subtract(const Duration(days: 1)),
        );
        streak = lastDay == yesterday ? streak + 1 : 1;
        newLastDay = update.dayKey;
      }
      tx.update(updateRef, {'status': 'approved'});
      tx.update(userRef, {
        'points': ((data['points'] ?? 0) as num).toInt() + 10,
        'approvedCount': ((data['approvedCount'] ?? 0) as num).toInt() + 1,
        'streak': streak,
        'lastApprovedDay': newLastDay,
      });
    });
  }

  static Stream<List<AppUser>> leaderboard() {
    return _db
        .collection('users')
        .orderBy('points', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(AppUser.fromDoc)
              .where((user) => user.role == 'volunteer')
              .toList(),
        );
  }
}