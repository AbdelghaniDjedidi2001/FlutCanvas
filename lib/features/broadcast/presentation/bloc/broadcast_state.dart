import 'package:freezed_annotation/freezed_annotation.dart';

part 'broadcast_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class BroadcastState with _$BroadcastState {
  const factory BroadcastState({
    @Default(false) bool isBroadcasting,
    @Default(false) bool isStarting,
    @Default(4040) int port,
    String? localIp,
    String? serverUrl,
    @Default(0) int viewersCount,
    String? errorMessage,
  }) = _BroadcastState;

  const BroadcastState._();
}
