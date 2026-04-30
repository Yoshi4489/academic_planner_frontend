import 'package:academic_planner_fe/core/providers/api_providers.dart';
import 'package:academic_planner_fe/core/services/gpa_api_service.dart';
import 'package:academic_planner_fe/features/term/data/gpa_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class GpaState {
  bool isLoading;
  String? error;
  List<GpaModel> gpas;

  GpaState({this.isLoading = false, this.gpas = const [], String? error});

  GpaState copyWith({bool? isLoading, String? error, List<GpaModel>? gpas}) {
    return GpaState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      gpas: gpas ?? this.gpas,
    );
  }
}

class GpaController extends StateNotifier<GpaState> {
  final GpaApiService _apiService;

  GpaController(this._apiService) : super(GpaState());

  Future<void> getGpaByUserId() async {
    if (state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true, error: "");
      final response = await _apiService.findGpaByUserId();
      final gpas = (response['gpas'] as List)
          .map((i) => GpaModel.fromJson(i))
          .toList();
      state = state.copyWith(isLoading: false, error: "", gpas: gpas);
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst("Exception: ", ""),
      );
    }
  }
}

final gpaProvider = StateNotifierProvider<GpaController, GpaState>((ref) {
  return GpaController(ref.read(gpaApiServiceProvider));
});
