// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamMemberModel _$TeamMemberModelFromJson(Map<String, dynamic> json) {
  return _TeamMemberModel.fromJson(json);
}

/// @nodoc
mixin _$TeamMemberModel {
  @JsonKey(fromJson: _parseMemberId)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseMemberName)
  String get name => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseMemberLevel)
  int get level => throw _privateConstructorUsedError;
  String? get tierName => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseMemberXp)
  int get currentXp => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseMemberNextXp)
  int get nextLevelXp => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseMemberXp)
  int get points => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseMemberRank)
  int get rank => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseTeamRole)
  String get teamRole => throw _privateConstructorUsedError;

  /// Serializes this TeamMemberModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamMemberModelCopyWith<TeamMemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamMemberModelCopyWith<$Res> {
  factory $TeamMemberModelCopyWith(
    TeamMemberModel value,
    $Res Function(TeamMemberModel) then,
  ) = _$TeamMemberModelCopyWithImpl<$Res, TeamMemberModel>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _parseMemberId) int id,
    @JsonKey(fromJson: _parseMemberName) String name,
    @JsonKey(fromJson: _parseMemberLevel) int level,
    String? tierName,
    @JsonKey(fromJson: _parseMemberXp) int currentXp,
    @JsonKey(fromJson: _parseMemberNextXp) int nextLevelXp,
    @JsonKey(fromJson: _parseMemberXp) int points,
    @JsonKey(fromJson: _parseMemberRank) int rank,
    @JsonKey(fromJson: _parseTeamRole) String teamRole,
  });
}

/// @nodoc
class _$TeamMemberModelCopyWithImpl<$Res, $Val extends TeamMemberModel>
    implements $TeamMemberModelCopyWith<$Res> {
  _$TeamMemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? level = null,
    Object? tierName = freezed,
    Object? currentXp = null,
    Object? nextLevelXp = null,
    Object? points = null,
    Object? rank = null,
    Object? teamRole = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            tierName: freezed == tierName
                ? _value.tierName
                : tierName // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentXp: null == currentXp
                ? _value.currentXp
                : currentXp // ignore: cast_nullable_to_non_nullable
                      as int,
            nextLevelXp: null == nextLevelXp
                ? _value.nextLevelXp
                : nextLevelXp // ignore: cast_nullable_to_non_nullable
                      as int,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            teamRole: null == teamRole
                ? _value.teamRole
                : teamRole // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamMemberModelImplCopyWith<$Res>
    implements $TeamMemberModelCopyWith<$Res> {
  factory _$$TeamMemberModelImplCopyWith(
    _$TeamMemberModelImpl value,
    $Res Function(_$TeamMemberModelImpl) then,
  ) = __$$TeamMemberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _parseMemberId) int id,
    @JsonKey(fromJson: _parseMemberName) String name,
    @JsonKey(fromJson: _parseMemberLevel) int level,
    String? tierName,
    @JsonKey(fromJson: _parseMemberXp) int currentXp,
    @JsonKey(fromJson: _parseMemberNextXp) int nextLevelXp,
    @JsonKey(fromJson: _parseMemberXp) int points,
    @JsonKey(fromJson: _parseMemberRank) int rank,
    @JsonKey(fromJson: _parseTeamRole) String teamRole,
  });
}

/// @nodoc
class __$$TeamMemberModelImplCopyWithImpl<$Res>
    extends _$TeamMemberModelCopyWithImpl<$Res, _$TeamMemberModelImpl>
    implements _$$TeamMemberModelImplCopyWith<$Res> {
  __$$TeamMemberModelImplCopyWithImpl(
    _$TeamMemberModelImpl _value,
    $Res Function(_$TeamMemberModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? level = null,
    Object? tierName = freezed,
    Object? currentXp = null,
    Object? nextLevelXp = null,
    Object? points = null,
    Object? rank = null,
    Object? teamRole = null,
  }) {
    return _then(
      _$TeamMemberModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        tierName: freezed == tierName
            ? _value.tierName
            : tierName // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentXp: null == currentXp
            ? _value.currentXp
            : currentXp // ignore: cast_nullable_to_non_nullable
                  as int,
        nextLevelXp: null == nextLevelXp
            ? _value.nextLevelXp
            : nextLevelXp // ignore: cast_nullable_to_non_nullable
                  as int,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        teamRole: null == teamRole
            ? _value.teamRole
            : teamRole // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamMemberModelImpl extends _TeamMemberModel {
  const _$TeamMemberModelImpl({
    @JsonKey(fromJson: _parseMemberId) required this.id,
    @JsonKey(fromJson: _parseMemberName) required this.name,
    @JsonKey(fromJson: _parseMemberLevel) required this.level,
    this.tierName,
    @JsonKey(fromJson: _parseMemberXp) required this.currentXp,
    @JsonKey(fromJson: _parseMemberNextXp) required this.nextLevelXp,
    @JsonKey(fromJson: _parseMemberXp) required this.points,
    @JsonKey(fromJson: _parseMemberRank) required this.rank,
    @JsonKey(fromJson: _parseTeamRole) this.teamRole = 'Member',
  }) : super._();

  factory _$TeamMemberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamMemberModelImplFromJson(json);

  @override
  @JsonKey(fromJson: _parseMemberId)
  final int id;
  @override
  @JsonKey(fromJson: _parseMemberName)
  final String name;
  @override
  @JsonKey(fromJson: _parseMemberLevel)
  final int level;
  @override
  final String? tierName;
  @override
  @JsonKey(fromJson: _parseMemberXp)
  final int currentXp;
  @override
  @JsonKey(fromJson: _parseMemberNextXp)
  final int nextLevelXp;
  @override
  @JsonKey(fromJson: _parseMemberXp)
  final int points;
  @override
  @JsonKey(fromJson: _parseMemberRank)
  final int rank;
  @override
  @JsonKey(fromJson: _parseTeamRole)
  final String teamRole;

  @override
  String toString() {
    return 'TeamMemberModel(id: $id, name: $name, level: $level, tierName: $tierName, currentXp: $currentXp, nextLevelXp: $nextLevelXp, points: $points, rank: $rank, teamRole: $teamRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamMemberModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.tierName, tierName) ||
                other.tierName == tierName) &&
            (identical(other.currentXp, currentXp) ||
                other.currentXp == currentXp) &&
            (identical(other.nextLevelXp, nextLevelXp) ||
                other.nextLevelXp == nextLevelXp) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.teamRole, teamRole) ||
                other.teamRole == teamRole));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    level,
    tierName,
    currentXp,
    nextLevelXp,
    points,
    rank,
    teamRole,
  );

  /// Create a copy of TeamMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamMemberModelImplCopyWith<_$TeamMemberModelImpl> get copyWith =>
      __$$TeamMemberModelImplCopyWithImpl<_$TeamMemberModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamMemberModelImplToJson(this);
  }
}

abstract class _TeamMemberModel extends TeamMemberModel {
  const factory _TeamMemberModel({
    @JsonKey(fromJson: _parseMemberId) required final int id,
    @JsonKey(fromJson: _parseMemberName) required final String name,
    @JsonKey(fromJson: _parseMemberLevel) required final int level,
    final String? tierName,
    @JsonKey(fromJson: _parseMemberXp) required final int currentXp,
    @JsonKey(fromJson: _parseMemberNextXp) required final int nextLevelXp,
    @JsonKey(fromJson: _parseMemberXp) required final int points,
    @JsonKey(fromJson: _parseMemberRank) required final int rank,
    @JsonKey(fromJson: _parseTeamRole) final String teamRole,
  }) = _$TeamMemberModelImpl;
  const _TeamMemberModel._() : super._();

  factory _TeamMemberModel.fromJson(Map<String, dynamic> json) =
      _$TeamMemberModelImpl.fromJson;

  @override
  @JsonKey(fromJson: _parseMemberId)
  int get id;
  @override
  @JsonKey(fromJson: _parseMemberName)
  String get name;
  @override
  @JsonKey(fromJson: _parseMemberLevel)
  int get level;
  @override
  String? get tierName;
  @override
  @JsonKey(fromJson: _parseMemberXp)
  int get currentXp;
  @override
  @JsonKey(fromJson: _parseMemberNextXp)
  int get nextLevelXp;
  @override
  @JsonKey(fromJson: _parseMemberXp)
  int get points;
  @override
  @JsonKey(fromJson: _parseMemberRank)
  int get rank;
  @override
  @JsonKey(fromJson: _parseTeamRole)
  String get teamRole;

  /// Create a copy of TeamMemberModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamMemberModelImplCopyWith<_$TeamMemberModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
