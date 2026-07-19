class GoalModel {
  String id;
  String name;
  double targetGpa;
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
      targetGpa: (json['target_gpa'] as num).toDouble(),
      isAchieved: json['is_achieved'] ?? false,
      targetSemesterId: json['target_semester_id'] ?? "",
      userId: json['user_id'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'target_gpa': targetGpa,
      'is_achieved': isAchieved,
      'target_semester_id': targetSemesterId,
      'user_id': userId,
    };
  }

  GoalModel copyWith({
    String? id,
    String? name,
    double? targetGpa,
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
