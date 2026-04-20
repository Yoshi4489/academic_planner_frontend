class TermModel {
  String id;
  int year;
  String term;
  int termNo;
  bool isComplete;
  String createdAt;
  String userId;
  List<Map<String, dynamic>> courses;
  List<Map<String, dynamic>> gpas;

  TermModel({
    required this.id,
    required this.year,
    required this.term,
    required this.termNo,
    required this.isComplete,
    required this.createdAt,
    required this.userId,
    required this.courses,
    required this.gpas,
  });

  factory TermModel.fromJson(Map<String, dynamic> json) {
    return TermModel(
      id: json["id"] ?? "",
      year: json["year"] ?? 0,
      term: json['term'] ?? "",
      termNo: json['term_no'] ?? 0,
      isComplete: json["is_complete"] ?? false,
      createdAt: json['created_at'] ?? "",
      userId: json['user_id'] ?? "",
      courses: (json['courses'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      gpas: (json['gpas'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  TermModel copyWith({
    String? id,
    int? year,
    String? term,
    int? termNo,
    bool? isComplete,
    String? createdAt,
    String? userId,
    List<Map<String, dynamic>>? courses,
    List<Map<String, dynamic>>? gpas,
  }) {
    return TermModel(
      id: id ?? this.id,
      year: year ?? this.year,
      term: term ?? this.term,
      termNo: termNo ?? this.termNo,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      courses: courses ?? this.courses,
      gpas: gpas ?? this.gpas,
    );
  }

  void operator [](String other) {}
}
