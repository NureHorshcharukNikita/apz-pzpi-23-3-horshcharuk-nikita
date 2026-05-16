import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/data/models/auth/user/auth_user_model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String token,
    required DateTime expiresAt,
    required AuthUserModel user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}