import 'package:elevate_mobile/domain/entities/user/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;

  const factory ProfileState.loading() = _Loading;

  const factory ProfileState.loaded(User user) = _Loaded;

  const factory ProfileState.error(String message) = _Error;
}