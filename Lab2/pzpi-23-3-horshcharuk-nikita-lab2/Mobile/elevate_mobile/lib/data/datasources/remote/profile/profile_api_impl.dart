import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:elevate_mobile/data/datasources/remote/profile/profile_api.dart';
import 'package:elevate_mobile/data/models/user/user_model.dart';

class ProfileApiImpl implements ProfileApi {
  final Dio dio;

  ProfileApiImpl(this.dio);

  @override
  Future<UserModel> getProfile() async {
    final response = await dio.get("/users/me");
    final data = Map<String, dynamic>.from(response.data as Map);
    data['userID'] = data['id'];
    final avatarUrl = data["avatarUrl"] as String?;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      data["avatarUrl"] = _toAbsoluteAvatarUrl(avatarUrl);
    }

    final user = UserModel.fromJson(data);
    final bytes = await _loadAvatarBytesIfExists(data["avatarUrl"] as String?);
    return user.copyWith(avatarBytes: bytes);
  }

  @override
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final response = await dio.put(
      "/users/me",
      data: {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    data['userID'] = data['id'];
    final avatarUrl = data["avatarUrl"] as String?;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      data["avatarUrl"] = _toAbsoluteAvatarUrl(avatarUrl);
    }

    final user = UserModel.fromJson(data);
    final bytes = await _loadAvatarBytesIfExists(data["avatarUrl"] as String?);
    return user.copyWith(avatarBytes: bytes);
  }

  @override
  Future<Uint8List> uploadAvatar(File file) async {
    final formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: file.uri.pathSegments.isEmpty ? "avatar.jpg" : file.uri.pathSegments.last,
      ),
    });

    final response = await dio.post(
      "/users/avatar",
      data: formData,
    );

    final avatarUrl = response.data is Map<String, dynamic>
        ? response.data["avatarUrl"] as String?
        : null;
    final bytes = await _loadAvatarBytesIfExists(avatarUrl ?? "/api/users/avatar");
    return bytes ?? await file.readAsBytes();
  }

  String _toAbsoluteAvatarUrl(String value) {
    if (value.startsWith("http://") || value.startsWith("https://")) {
      return value;
    }

    final base = dio.options.baseUrl;
    final normalizedBase = base.endsWith("/") ? base.substring(0, base.length - 1) : base;
    final normalizedValue = value.startsWith("/") ? value.substring(1) : value;

    if (normalizedBase.endsWith("/api")) {
      return "$normalizedBase/$normalizedValue";
    }

    return "$normalizedBase/api/$normalizedValue";
  }

  Future<Uint8List?> _loadAvatarBytesIfExists(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return null;
    }

    try {
      final response = await dio.get<List<int>>(
        "/users/avatar",
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      return Uint8List.fromList(bytes);
    } catch (_) {
      return null;
    }
  }
}