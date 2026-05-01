import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:elevate_mobile/domain/entities/user/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
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
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() {
    return User(
      userID: userID,
      login: login,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      avatarUrl: avatarUrl,
      avatarBytes: avatarBytes,
    );
  }
}