// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AchievementModel _$AchievementModelFromJson(Map<String, dynamic> json) {
  return _AchievementModel.fromJson(json);
}

/// @nodoc
mixin _$AchievementModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get earned => throw _privateConstructorUsedError;
  DateTime? get earnedAt => throw _privateConstructorUsedError;
  int? get teamId => throw _privateConstructorUsedError;
  String? get teamName => throw _privateConstructorUsedError;
  String? get requirement => throw _privateConstructorUsedError;

  /// Serializes this AchievementModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementModelCopyWith<AchievementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementModelCopyWith<$Res> {
  factory $AchievementModelCopyWith(
    AchievementModel value,
    $Res Function(AchievementModel) then,
  ) = _$AchievementModelCopyWithImpl<$Res, AchievementModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    bool earned,
    DateTime? earnedAt,
    int? teamId,
    String? teamName,
    String? requirement,
  });
}

/// @nodoc
class _$AchievementModelCopyWithImpl<$Res, $Val extends AchievementModel>
    implements $AchievementModelCopyWith<$Res> {
  _$AchievementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? earned = null,
    Object? earnedAt = freezed,
    Object? teamId = freezed,
    Object? teamName = freezed,
    Object? requirement = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            earned: null == earned
                ? _value.earned
                : earned // ignore: cast_nullable_to_non_nullable
                      as bool,
            earnedAt: freezed == earnedAt
                ? _value.earnedAt
                : earnedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            teamId: freezed == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as int?,
            teamName: freezed == teamName
                ? _value.teamName
                : teamName // ignore: cast_nullable_to_non_nullable
                      as String?,
            requirement: freezed == requirement
                ? _value.requirement
                : requirement // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AchievementModelImplCopyWith<$Res>
    implements $AchievementModelCopyWith<$Res> {
  factory _$$AchievementModelImplCopyWith(
    _$AchievementModelImpl value,
    $Res Function(_$AchievementModelImpl) then,
  ) = __$$AchievementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    bool earned,
    DateTime? earnedAt,
    int? teamId,
    String? teamName,
    String? requirement,
  });
}

/// @nodoc
class __$$AchievementModelImplCopyWithImpl<$Res>
    extends _$AchievementModelCopyWithImpl<$Res, _$AchievementModelImpl>
    implements _$$AchievementModelImplCopyWith<$Res> {
  __$$AchievementModelImplCopyWithImpl(
    _$AchievementModelImpl _value,
    $Res Function(_$AchievementModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? earned = null,
    Object? earnedAt = freezed,
    Object? teamId = freezed,
    Object? teamName = freezed,
    Object? requirement = freezed,
  }) {
    return _then(
      _$AchievementModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        earned: null == earned
            ? _value.earned
            : earned // ignore: cast_nullable_to_non_nullable
                  as bool,
        earnedAt: freezed == earnedAt
            ? _value.earnedAt
            : earnedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        teamId: freezed == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as int?,
        teamName: freezed == teamName
            ? _value.teamName
            : teamName // ignore: cast_nullable_to_non_nullable
                  as String?,
        requirement: freezed == requirement
            ? _value.requirement
            : requirement // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementModelImpl extends _AchievementModel {
  const _$AchievementModelImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.earned,
    this.earnedAt,
    this.teamId,
    this.teamName,
    this.requirement,
  }) : super._();

  factory _$AchievementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final bool earned;
  @override
  final DateTime? earnedAt;
  @override
  final int? teamId;
  @override
  final String? teamName;
  @override
  final String? requirement;

  @override
  String toString() {
    return 'AchievementModel(id: $id, title: $title, description: $description, earned: $earned, earnedAt: $earnedAt, teamId: $teamId, teamName: $teamName, requirement: $requirement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.earned, earned) || other.earned == earned) &&
            (identical(other.earnedAt, earnedAt) ||
                other.earnedAt == earnedAt) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.teamName, teamName) ||
                other.teamName == teamName) &&
            (identical(other.requirement, requirement) ||
                other.requirement == requirement));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    earned,
    earnedAt,
    teamId,
    teamName,
    requirement,
  );

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementModelImplCopyWith<_$AchievementModelImpl> get copyWith =>
      __$$AchievementModelImplCopyWithImpl<_$AchievementModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementModelImplToJson(this);
  }
}

abstract class _AchievementModel extends AchievementModel {
  const factory _AchievementModel({
    required final String id,
    required final String title,
    required final String description,
    required final bool earned,
    final DateTime? earnedAt,
    final int? teamId,
    final String? teamName,
    final String? requirement,
  }) = _$AchievementModelImpl;
  const _AchievementModel._() : super._();

  factory _AchievementModel.fromJson(Map<String, dynamic> json) =
      _$AchievementModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  bool get earned;
  @override
  DateTime? get earnedAt;
  @override
  int? get teamId;
  @override
  String? get teamName;
  @override
  String? get requirement;

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementModelImplCopyWith<_$AchievementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
