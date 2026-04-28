class GoalModel {
  String id;
  String name;
  int targetGpa;
  bool isAchieved;
  String targetSemesterId;
  String userId;

  GoalModel({
    required this.id,
    required this.name,
    required this.targetGpa,
    required this.isAchieved,
    required this.targetSemesterId,
    required this.userId,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      targetGpa: json['target_gpa'] ?? 0,
      isAchieved: json['is_achieved'] ?? false,
      targetSemesterId: json['target_semester_id'] ?? "",
      userId: json['user_id'] ?? "",
    );
  }

  GoalModel copyWith({
    String? id,
    String? name,
    int? targetGpa,
    bool? isAchieved,
    String? targetSemesterId,
    String? userId,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetGpa: targetGpa ?? this.targetGpa,
      isAchieved: isAchieved ?? this.isAchieved,
      targetSemesterId: targetSemesterId ?? this.targetSemesterId,
      userId: userId ?? this.userId,
    );
  }
}
