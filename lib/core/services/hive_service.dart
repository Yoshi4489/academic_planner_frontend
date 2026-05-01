import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() => _instance;

  HiveService._internal();

  static const _termBox = 'guest_terms';
  static const _courseBox = 'guest_courses';

  late final Box terms;
  late final Box courses;

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_termBox);
    await Hive.openBox(_courseBox);
  }

  void setupBoxes() {
    terms = Hive.box(_termBox);
    courses = Hive.box(_courseBox);
  }
}