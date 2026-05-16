// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) {
  return _DashboardModel.fromJson(json);
}

/// @nodoc
mixin _$DashboardModel {
  @JsonKey(fromJson: _dashTeamId)
  int get teamId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dashName)
  String get teamName => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dashLevel)
  int get level => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dashXp)
  int get points => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dashIntMin1)
  int get rank => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dashXp)
  int get currentXp => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dashNextLevelXp)
  int get nextLevelXp => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dashAtMaxTier)
  bool get atMaxTier => throw _privateConstructorUsedError;
  String? get tierName => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dashAchievements)
  List<String> get recentAchievements => throw _privateConstructorUsedError;

  /// Serializes this DashboardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardModelCopyWith<DashboardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardModelCopyWith<$Res> {
  factory $DashboardModelCopyWith(
    DashboardModel value,
    $Res Function(DashboardModel) then,
  ) = _$DashboardModelCopyWithImpl<$Res, DashboardModel>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _dashTeamId) int teamId,
    @JsonKey(fromJson: _dashName) String teamName,
    @JsonKey(fromJson: _dashLevel) int level,
    @JsonKey(fromJson: _dashXp) int points,
    @JsonKey(fromJson: _dashIntMin1) int rank,
    @JsonKey(fromJson: _dashXp) int currentXp,
    @JsonKey(fromJson: _dashNextLevelXp) int nextLevelXp,
    @JsonKey(fromJson: _dashAtMaxTier) bool atMaxTier,
    String? tierName,
    @JsonKey(fromJson: _dashAchievements) List<String> recentAchievements,
  });
}

/// @nodoc
class _$DashboardModelCopyWithImpl<$Res, $Val extends DashboardModel>
    implements $DashboardModelCopyWith<$Res> {
  _$DashboardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? teamName = null,
    Object? level = null,
    Object? points = null,
    Object? rank = null,
    Object? currentXp = null,
    Object? nextLevelXp = null,
    Object? atMaxTier = null,
    Object? tierName = freezed,
    Object? recentAchievements = null,
  }) {
    return _then(
      _value.copyWith(
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as int,
            teamName: null == teamName
                ? _value.teamName
                : teamName // ignore: cast_nullable_to_non_nullable
                      as String,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            currentXp: null == currentXp
                ? _value.currentXp
                : currentXp // ignore: cast_nullable_to_non_nullable
                      as int,
            nextLevelXp: null == nextLevelXp
                ? _value.nextLevelXp
                : nextLevelXp // ignore: cast_nullable_to_non_nullable
                      as int,
            atMaxTier: null == atMaxTier
                ? _value.atMaxTier
                : atMaxTier // ignore: cast_nullable_to_non_nullable
                      as bool,
            tierName: freezed == tierName
                ? _value.tierName
                : tierName // ignore: cast_nullable_to_non_nullable
                      as String?,
            recentAchievements: null == recentAchievements
                ? _value.recentAchievements
                : recentAchievements // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardModelImplCopyWith<$Res>
    implements $DashboardModelCopyWith<$Res> {
  factory _$$DashboardModelImplCopyWith(
    _$DashboardModelImpl value,
    $Res Function(_$DashboardModelImpl) then,
  ) = __$$DashboardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _dashTeamId) int teamId,
    @JsonKey(fromJson: _dashName) String teamName,
    @JsonKey(fromJson: _dashLevel) int level,
    @JsonKey(fromJson: _dashXp) int points,
    @JsonKey(fromJson: _dashIntMin1) int rank,
    @JsonKey(fromJson: _dashXp) int currentXp,
    @JsonKey(fromJson: _dashNextLevelXp) int nextLevelXp,
    @JsonKey(fromJson: _dashAtMaxTier) bool atMaxTier,
    String? tierName,
    @JsonKey(fromJson: _dashAchievements) List<String> recentAchievements,
  });
}

/// @nodoc
class __$$DashboardModelImplCopyWithImpl<$Res>
    extends _$DashboardModelCopyWithImpl<$Res, _$DashboardModelImpl>
    implements _$$DashboardModelImplCopyWith<$Res> {
  __$$DashboardModelImplCopyWithImpl(
    _$DashboardModelImpl _value,
    $Res Function(_$DashboardModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? teamName = null,
    Object? level = null,
    Object? points = null,
    Object? rank = null,
    Object? currentXp = null,
    Object? nextLevelXp = null,
    Object? atMaxTier = null,
    Object? tierName = freezed,
    Object? recentAchievements = null,
  }) {
    return _then(
      _$DashboardModelImpl(
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as int,
        teamName: null == teamName
            ? _value.teamName
            : teamName // ignore: cast_nullable_to_non_nullable
                  as String,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        currentXp: null == currentXp
            ? _value.currentXp
            : currentXp // ignore: cast_nullable_to_non_nullable
                  as int,
        nextLevelXp: null == nextLevelXp
            ? _value.nextLevelXp
            : nextLevelXp // ignore: cast_nullable_to_non_nullable
                  as int,
        atMaxTier: null == atMaxTier
            ? _value.atMaxTier
            : atMaxTier // ignore: cast_nullable_to_non_nullable
                  as bool,
        tierName: freezed == tierName
            ? _value.tierName
            : tierName // ignore: cast_nullable_to_non_nullable
                  as String?,
        recentAchievements: null == recentAchievements
            ? _value._recentAchievements
            : recentAchievements // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardModelImpl extends _DashboardModel {
  const _$DashboardModelImpl({
    @JsonKey(fromJson: _dashTeamId) required this.teamId,
    @JsonKey(fromJson: _dashName) required this.teamName,
    @JsonKey(fromJson: _dashLevel) required this.level,
    @JsonKey(fromJson: _dashXp) required this.points,
    @JsonKey(fromJson: _dashIntMin1) required this.rank,
    @JsonKey(fromJson: _dashXp) required this.currentXp,
    @JsonKey(fromJson: _dashNextLevelXp) required this.nextLevelXp,
    @JsonKey(fromJson: _dashAtMaxTier) this.atMaxTier = false,
    this.tierName,
    @JsonKey(fromJson: _dashAchievements)
    required final List<String> recentAchievements,
  }) : _recentAchievements = recentAchievements,
       super._();

  factory _$DashboardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardModelImplFromJson(json);

  @override
  @JsonKey(fromJson: _dashTeamId)
  final int teamId;
  @override
  @JsonKey(fromJson: _dashName)
  final String teamName;
  @override
  @JsonKey(fromJson: _dashLevel)
  final int level;
  @override
  @JsonKey(fromJson: _dashXp)
  final int points;
  @override
  @JsonKey(fromJson: _dashIntMin1)
  final int rank;
  @override
  @JsonKey(fromJson: _dashXp)
  final int currentXp;
  @override
  @JsonKey(fromJson: _dashNextLevelXp)
  final int nextLevelXp;
  @override
  @JsonKey(fromJson: _dashAtMaxTier)
  final bool atMaxTier;
  @override
  final String? tierName;
  final List<String> _recentAchievements;
  @override
  @JsonKey(fromJson: _dashAchievements)
  List<String> get recentAchievements {
    if (_recentAchievements is EqualUnmodifiableListView)
      return _recentAchievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentAchievements);
  }

  @override
  String toString() {
    return 'DashboardModel(teamId: $teamId, teamName: $teamName, level: $level, points: $points, rank: $rank, currentXp: $currentXp, nextLevelXp: $nextLevelXp, atMaxTier: $atMaxTier, tierName: $tierName, recentAchievements: $recentAchievements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardModelImpl &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.teamName, teamName) ||
                other.teamName == teamName) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.currentXp, currentXp) ||
                other.currentXp == currentXp) &&
            (identical(other.nextLevelXp, nextLevelXp) ||
                other.nextLevelXp == nextLevelXp) &&
            (identical(other.atMaxTier, atMaxTier) ||
                other.atMaxTier == atMaxTier) &&
            (identical(other.tierName, tierName) ||
                other.tierName == tierName) &&
            const DeepCollectionEquality().equals(
              other._recentAchievements,
              _recentAchievements,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    teamId,
    teamName,
    level,
    points,
    rank,
    currentXp,
    nextLevelXp,
    atMaxTier,
    tierName,
    const DeepCollectionEquality().hash(_recentAchievements),
  );

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardModelImplCopyWith<_$DashboardModelImpl> get copyWith =>
      __$$DashboardModelImplCopyWithImpl<_$DashboardModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardModelImplToJson(this);
  }
}

abstract class _DashboardModel extends DashboardModel {
  const factory _DashboardModel({
    @JsonKey(fromJson: _dashTeamId) required final int teamId,
    @JsonKey(fromJson: _dashName) required final String teamName,
    @JsonKey(fromJson: _dashLevel) required final int level,
    @JsonKey(fromJson: _dashXp) required final int points,
    @JsonKey(fromJson: _dashIntMin1) required final int rank,
    @JsonKey(fromJson: _dashXp) required final int currentXp,
    @JsonKey(fromJson: _dashNextLevelXp) required final int nextLevelXp,
    @JsonKey(fromJson: _dashAtMaxTier) final bool atMaxTier,
    final String? tierName,
    @JsonKey(fromJson: _dashAchievements)
    required final List<String> recentAchievements,
  }) = _$DashboardModelImpl;
  const _DashboardModel._() : super._();

  factory _DashboardModel.fromJson(Map<String, dynamic> json) =
      _$DashboardModelImpl.fromJson;

  @override
  @JsonKey(fromJson: _dashTeamId)
  int get teamId;
  @override
  @JsonKey(fromJson: _dashName)
  String get teamName;
  @override
  @JsonKey(fromJson: _dashLevel)
  int get level;
  @override
  @JsonKey(fromJson: _dashXp)
  int get points;
  @override
  @JsonKey(fromJson: _dashIntMin1)
  int get rank;
  @override
  @JsonKey(fromJson: _dashXp)
  int get currentXp;
  @override
  @JsonKey(fromJson: _dashNextLevelXp)
  int get nextLevelXp;
  @override
  @JsonKey(fromJson: _dashAtMaxTier)
  bool get atMaxTier;
  @override
  String? get tierName;
  @override
  @JsonKey(fromJson: _dashAchievements)
  List<String> get recentAchievements;

  /// Create a copy of DashboardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardModelImplCopyWith<_$DashboardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
