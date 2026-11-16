import 'package:cloud_firestore/cloud_firestore.dart';

int _int(dynamic value) => ((value ?? 0) as num).toInt();

String _str(dynamic value) => (value ?? '') as String;

class AppUser {
  final String uid;
  final String name;
  final String role;
  final int points;
  final int streak;
  final int approvedCount;

  const AppUser({
    required this.uid,
    required this.name,
    required this.role,
    required this.points,
    required this.streak,
    required this.approvedCount,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      name: _str(d['name']),
      role: d['role'] == 'organization' ? 'organization' : 'volunteer',
      points: _int(d['points']),
      streak: _int(d['streak']),
      approvedCount: _int(d['approvedCount']),
    );
  }

  String get badge {
    if (approvedCount >= 60) return 'Forest Guardian';
    if (approvedCount >= 30) return 'Tree Keeper';
    if (approvedCount >= 15) return 'Sapling Guardian';
    if (approvedCount >= 5) return 'Sprout';
    if (approvedCount >= 1) return 'Seedling';
    return 'New Planter';
  }
}

class Drive {
  final String id;
  final String orgId;
  final String orgName;
  final String title;
  final String description;
  final double lat;
  final double lng;
  final int saplings;
  final String? caretakerId;
  final String? caretakerName;

  const Drive({
    required this.id,
    required this.orgId,
    required this.orgName,
    required this.title,
    required this.description,
    required this.lat,
    required this.lng,
    required this.saplings,
    required this.caretakerId,
    required this.caretakerName,
  });

  factory Drive.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Drive(
      id: doc.id,
      orgId: _str(d['orgId']),
      orgName: _str(d['orgName']),
      title: _str(d['title']),
      description: _str(d['description']),
      lat: ((d['lat'] ?? 0) as num).toDouble(),
      lng: ((d['lng'] ?? 0) as num).toDouble(),
      saplings: _int(d['saplings']),
      caretakerId: d['caretakerId'] as String?,
      caretakerName: d['caretakerName'] as String?,
    );
  }
}

class PlantUpdate {
  final String id;
  final String driveId;
  final String driveTitle;
  final String orgId;
  final String volunteerId;
  final String volunteerName;
  final String condition;
  final String note;
  final String photo;
  final String status;
  final String dayKey;

  const PlantUpdate({
    required this.id,
    required this.driveId,
    required this.driveTitle,
    required this.orgId,
    required this.volunteerId,
    required this.volunteerName,
    required this.condition,
    required this.note,
    required this.photo,
    required this.status,
    required this.dayKey,
  });

  factory PlantUpdate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return PlantUpdate(
      id: doc.id,
      driveId: _str(d['driveId']),
      driveTitle: _str(d['driveTitle']),
      orgId: _str(d['orgId']),
      volunteerId: _str(d['volunteerId']),
      volunteerName: _str(d['volunteerName']),
      condition: _str(d['condition']),
      note: _str(d['note']),
      photo: _str(d['photo']),
      status: _str(d['status']),
      dayKey: _str(d['dayKey']),
    );
  }
}