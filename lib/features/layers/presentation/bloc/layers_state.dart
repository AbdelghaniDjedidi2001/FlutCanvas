import 'package:freezed_annotation/freezed_annotation.dart';

part 'layers_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class LayersState with _$LayersState {
  const factory LayersState({
    @Default('') String searchQuery,
    @Default(0) int activeTab, // 0: Elements, 1: Comments
  }) = _LayersState;
}
