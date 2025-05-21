class FamilyMember {
  String fromPersonId;
  final String uid;
  String relationshipType;
  final String name;
  final String? lastname;
  final String gender;
  final DateTime birthdate;
  final DateTime? diedate;
  final String? biography;
  final Map<String, dynamic>? birthplace;
  final Map<String, dynamic>? generation;
  final Map<String, dynamic>? urgiinovog;

  FamilyMember({
    required this.fromPersonId,
    required this.uid,
    required this.relationshipType,
    required this.name,
    this.lastname,
    required this.gender,
    required this.birthdate,
    this.diedate,
    this.biography,
    this.birthplace,
    this.generation,
    this.urgiinovog,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromPersonId': fromPersonId,
      'uid': uid,
      'relationshipType': relationshipType,
      'name': name,
      'lastname': lastname,
      'gender': gender,
      'birthdate': birthdate.toIso8601String(),
      'diedate': diedate?.toIso8601String(),
      'biography': biography,
      'birthplace': birthplace,
      'generation': generation,
      'urgiinovog': urgiinovog,
    };
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      fromPersonId: json['fromPersonId'] ?? '',
      uid: json['uid'] ?? '',
      relationshipType: json['relationshipType'] ?? '',
      name: json['name'] ?? '',
      lastname: json['lastname'],
      gender: json['gender'] ?? '',
      birthdate: DateTime.parse(json['birthdate']),
      diedate: json['diedate'] != null ? DateTime.parse(json['diedate']) : null,
      biography: json['biography'],
      birthplace: json['birthplace'],
      generation: json['generation'],
      urgiinovog: json['urgiinovog'],
    );
  }
}
