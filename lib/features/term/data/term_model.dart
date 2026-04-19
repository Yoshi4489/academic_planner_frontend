class TermModel {
  String id;
  int year;
  String term;
  int term_no;
  bool is_complete;
  String created_at;
  String user_id;

  TermModel({
    required this.id,
    required this.year,
    required this.term,
    required this.term_no,
    required this.is_complete,
    required this.created_at,
    required this.user_id,
  });

  factory TermModel.fromJson(Map<String, dynamic> json) {
    return TermModel(
      id: json["id"] ?? "",
      year: json["year"] ?? 0,
      term: json['term'] ?? "",
      term_no: json['term_no'] ?? 0,
      is_complete: json["is_complete"],
      created_at: json['created_at'] ?? "",
      user_id: json['user_id'] ?? "",
    );
  }

  TermModel copyWith({
    String? id,
    int? year,
    String? term,
    int? term_no,
    bool? is_complete,
    String? created_at,
    String? user_id,
  }) {
    return TermModel(
      id: id ?? this.id,
      year: year ?? this.year,
      term: term ?? this.term,
      term_no: term_no ?? this.term_no,
      is_complete: is_complete ?? this.is_complete,
      created_at: created_at ?? this.created_at,
      user_id: user_id ?? this.user_id,
    );
  }
}
