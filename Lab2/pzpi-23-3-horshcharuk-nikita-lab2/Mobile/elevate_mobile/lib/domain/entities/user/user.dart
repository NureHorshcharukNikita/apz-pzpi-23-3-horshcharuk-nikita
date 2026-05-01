import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required int userID,
    required String login,
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    required bool isActive,
    required DateTime createdAt,
    DateTime? lastLoginAt,
    String? avatarUrl,
    List<int>? avatarBytes,
  }) = _User;
}