// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaderboardUserModel _$LeaderboardUserModelFromJson(Map<String, dynamic> json) {
  return _LeaderboardUserModel.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardUserModel {
  int get position => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardUserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardUserModelCopyWith<LeaderboardUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardUserModelCopyWith<$Res> {
  factory $LeaderboardUserModelCopyWith(
    LeaderboardUserModel value,
    $Res Function(LeaderboardUserModel) then,
  ) = _$LeaderboardUserModelCopyWithImpl<$Res, LeaderboardUserModel>;
  @useResult
  $Res call({int position, String name, int points});
}

/// @nodoc
class _$LeaderboardUserModelCopyWithImpl<
  $Res,
  $Val extends LeaderboardUserModel
>
    implements $LeaderboardUserModelCopyWith<$Res> {
  _$LeaderboardUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? name = null,
    Object? points = null,
  }) {
    return _then(
      _value.copyWith(
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaderboardUserModelImplCopyWith<$Res>
    implements $LeaderboardUserModelCopyWith<$Res> {
  factory _$$LeaderboardUserModelImplCopyWith(
    _$LeaderboardUserModelImpl value,
    $Res Function(_$LeaderboardUserModelImpl) then,
  ) = __$$LeaderboardUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int position, String name, int points});
}

/// @nodoc
class __$$LeaderboardUserModelImplCopyWithImpl<$Res>
    extends _$LeaderboardUserModelCopyWithImpl<$Res, _$LeaderboardUserModelImpl>
    implements _$$LeaderboardUserModelImplCopyWith<$Res> {
  __$$LeaderboardUserModelImplCopyWithImpl(
    _$LeaderboardUserModelImpl _value,
    $Res Function(_$LeaderboardUserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? name = null,
    Object? points = null,
  }) {
    return _then(
      _$LeaderboardUserModelImpl(
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardUserModelImpl extends _LeaderboardUserModel {
  const _$LeaderboardUserModelImpl({
    required this.position,
    required this.name,
    required this.points,
  }) : super._();

  factory _$LeaderboardUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardUserModelImplFromJson(json);

  @override
  final int position;
  @override
  final String name;
  @override
  final int points;

  @override
  String toString() {
    return 'LeaderboardUserModel(position: $position, name: $name, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardUserModelImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, position, name, points);

  /// Create a copy of LeaderboardUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardUserModelImplCopyWith<_$LeaderboardUserModelImpl>
  get copyWith =>
      __$$LeaderboardUserModelImplCopyWithImpl<_$LeaderboardUserModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardUserModelImplToJson(this);
  }
}

abstract class _LeaderboardUserModel extends LeaderboardUserModel {
  const factory _LeaderboardUserModel({
    required final int position,
    required final String name,
    required final int points,
  }) = _$LeaderboardUserModelImpl;
  const _LeaderboardUserModel._() : super._();

  factory _LeaderboardUserModel.fromJson(Map<String, dynamic> json) =
      _$LeaderboardUserModelImpl.fromJson;

  @override
  int get position;
  @override
  String get name;
  @override
  int get points;

  /// Create a copy of LeaderboardUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardUserModelImplCopyWith<_$LeaderboardUserModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
