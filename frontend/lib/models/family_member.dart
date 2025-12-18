// lib/models/family_member.dart

// 가족 구성원 모델
class FamilyMember {
  final String id;
  final String name;
  final String relation; // ex) father, mother, son 등 문자열로 보관
  final String? profileImageUrl;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    this.profileImageUrl,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'].toString(),
      name: json['name'] as String,
      relation: json['relation'] as String,
      profileImageUrl: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'profile_image': profileImageUrl,
    };
  }
}
