// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActionResultModel _$ActionResultModelFromJson(Map<String, dynamic> json) {
  return _ActionResultModel.fromJson(json);
}

/// @nodoc
mixin _$ActionResultModel {
  int get actionEventId => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  int get teamId => throw _privateConstructorUsedError;
  int get pointsAwarded => throw _privateConstructorUsedError;
  int get totalTeamPoints => throw _privateConstructorUsedError;
  String? get newTeamLevelName => throw _privateConstructorUsedError;
  List<String> get newBadges => throw _privateConstructorUsedError;

  /// Serializes this ActionResultModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionResultModelCopyWith<ActionResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionResultModelCopyWith<$Res> {
  factory $ActionResultModelCopyWith(
    ActionResultModel value,
    $Res Function(ActionResultModel) then,
  ) = _$ActionResultModelCopyWithImpl<$Res, ActionResultModel>;
  @useResult
  $Res call({
    int actionEventId,
    int userId,
    int teamId,
    int pointsAwarded,
    int totalTeamPoints,
    String? newTeamLevelName,
    List<String> newBadges,
  });
}

/// @nodoc
class _$ActionResultModelCopyWithImpl<$Res, $Val extends ActionResultModel>
    implements $ActionResultModelCopyWith<$Res> {
  _$ActionResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionEventId = null,
    Object? userId = null,
    Object? teamId = null,
    Object? pointsAwarded = null,
    Object? totalTeamPoints = null,
    Object? newTeamLevelName = freezed,
    Object? newBadges = null,
  }) {
    return _then(
      _value.copyWith(
            actionEventId: null == actionEventId
                ? _value.actionEventId
                : actionEventId // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as int,
            pointsAwarded: null == pointsAwarded
                ? _value.pointsAwarded
                : pointsAwarded // ignore: cast_nullable_to_non_nullable
                      as int,
            totalTeamPoints: null == totalTeamPoints
                ? _value.totalTeamPoints
                : totalTeamPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            newTeamLevelName: freezed == newTeamLevelName
                ? _value.newTeamLevelName
                : newTeamLevelName // ignore: cast_nullable_to_non_nullable
                      as String?,
            newBadges: null == newBadges
                ? _value.newBadges
                : newBadges // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActionResultModelImplCopyWith<$Res>
    implements $ActionResultModelCopyWith<$Res> {
  factory _$$ActionResultModelImplCopyWith(
    _$ActionResultModelImpl value,
    $Res Function(_$ActionResultModelImpl) then,
  ) = __$$ActionResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int actionEventId,
    int userId,
    int teamId,
    int pointsAwarded,
    int totalTeamPoints,
    String? newTeamLevelName,
    List<String> newBadges,
  });
}

/// @nodoc
class __$$ActionResultModelImplCopyWithImpl<$Res>
    extends _$ActionResultModelCopyWithImpl<$Res, _$ActionResultModelImpl>
    implements _$$ActionResultModelImplCopyWith<$Res> {
  __$$ActionResultModelImplCopyWithImpl(
    _$ActionResultModelImpl _value,
    $Res Function(_$ActionResultModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionEventId = null,
    Object? userId = null,
    Object? teamId = null,
    Object? pointsAwarded = null,
    Object? totalTeamPoints = null,
    Object? newTeamLevelName = freezed,
    Object? newBadges = null,
  }) {
    return _then(
      _$ActionResultModelImpl(
        actionEventId: null == actionEventId
            ? _value.actionEventId
            : actionEventId // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as int,
        pointsAwarded: null == pointsAwarded
            ? _value.pointsAwarded
            : pointsAwarded // ignore: cast_nullable_to_non_nullable
                  as int,
        totalTeamPoints: null == totalTeamPoints
            ? _value.totalTeamPoints
            : totalTeamPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        newTeamLevelName: freezed == newTeamLevelName
            ? _value.newTeamLevelName
            : newTeamLevelName // ignore: cast_nullable_to_non_nullable
                  as String?,
        newBadges: null == newBadges
            ? _value._newBadges
            : newBadges // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionResultModelImpl extends _ActionResultModel {
  const _$ActionResultModelImpl({
    required this.actionEventId,
    required this.userId,
    required this.teamId,
    required this.pointsAwarded,
    required this.totalTeamPoints,
    this.newTeamLevelName,
    required final List<String> newBadges,
  }) : _newBadges = newBadges,
       super._();

  factory _$ActionResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionResultModelImplFromJson(json);

  @override
  final int actionEventId;
  @override
  final int userId;
  @override
  final int teamId;
  @override
  final int pointsAwarded;
  @override
  final int totalTeamPoints;
  @override
  final String? newTeamLevelName;
  final List<String> _newBadges;
  @override
  List<String> get newBadges {
    if (_newBadges is EqualUnmodifiableListView) return _newBadges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_newBadges);
  }

  @override
  String toString() {
    return 'ActionResultModel(actionEventId: $actionEventId, userId: $userId, teamId: $teamId, pointsAwarded: $pointsAwarded, totalTeamPoints: $totalTeamPoints, newTeamLevelName: $newTeamLevelName, newBadges: $newBadges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionResultModelImpl &&
            (identical(other.actionEventId, actionEventId) ||
                other.actionEventId == actionEventId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.pointsAwarded, pointsAwarded) ||
                other.pointsAwarded == pointsAwarded) &&
            (identical(other.totalTeamPoints, totalTeamPoints) ||
                other.totalTeamPoints == totalTeamPoints) &&
            (identical(other.newTeamLevelName, newTeamLevelName) ||
                other.newTeamLevelName == newTeamLevelName) &&
            const DeepCollectionEquality().equals(
              other._newBadges,
              _newBadges,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    actionEventId,
    userId,
    teamId,
    pointsAwarded,
    totalTeamPoints,
    newTeamLevelName,
    const DeepCollectionEquality().hash(_newBadges),
  );

  /// Create a copy of ActionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionResultModelImplCopyWith<_$ActionResultModelImpl> get copyWith =>
      __$$ActionResultModelImplCopyWithImpl<_$ActionResultModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionResultModelImplToJson(this);
  }
}

abstract class _ActionResultModel extends ActionResultModel {
  const factory _ActionResultModel({
    required final int actionEventId,
    required final int userId,
    required final int teamId,
    required final int pointsAwarded,
    required final int totalTeamPoints,
    final String? newTeamLevelName,
    required final List<String> newBadges,
  }) = _$ActionResultModelImpl;
  const _ActionResultModel._() : super._();

  factory _ActionResultModel.fromJson(Map<String, dynamic> json) =
      _$ActionResultModelImpl.fromJson;

  @override
  int get actionEventId;
  @override
  int get userId;
  @override
  int get teamId;
  @override
  int get pointsAwarded;
  @override
  int get totalTeamPoints;
  @override
  String? get newTeamLevelName;
  @override
  List<String> get newBadges;

  /// Create a copy of ActionResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionResultModelImplCopyWith<_$ActionResultModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
