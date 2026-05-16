// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamModel _$TeamModelFromJson(Map<String, dynamic> json) {
  return _TeamModel.fromJson(json);
}

/// @nodoc
mixin _$TeamModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get level => throw _privateConstructorUsedError;
  String? get tierName => throw _privateConstructorUsedError;
  int? get points => throw _privateConstructorUsedError;
  int? get createdByUserId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _levelPointsModeFromJson)
  int get levelPointsMode => throw _privateConstructorUsedError;
  List<TeamLevelRowModel> get levelRows => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _teamBadgesFromJson, includeToJson: false)
  List<TeamBadgeModel> get badges => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  int? get maxMembers => throw _privateConstructorUsedError;

  /// Serializes this TeamModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamModelCopyWith<TeamModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamModelCopyWith<$Res> {
  factory $TeamModelCopyWith(TeamModel value, $Res Function(TeamModel) then) =
      _$TeamModelCopyWithImpl<$Res, TeamModel>;
  @useResult
  $Res call({
    int id,
    String name,
    String? description,
    int? level,
    String? tierName,
    int? points,
    int? createdByUserId,
    @JsonKey(fromJson: _levelPointsModeFromJson) int levelPointsMode,
    List<TeamLevelRowModel> levelRows,
    @JsonKey(fromJson: _teamBadgesFromJson, includeToJson: false)
    List<TeamBadgeModel> badges,
    int memberCount,
    int? maxMembers,
  });
}

/// @nodoc
class _$TeamModelCopyWithImpl<$Res, $Val extends TeamModel>
    implements $TeamModelCopyWith<$Res> {
  _$TeamModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? level = freezed,
    Object? tierName = freezed,
    Object? points = freezed,
    Object? createdByUserId = freezed,
    Object? levelPointsMode = null,
    Object? levelRows = null,
    Object? badges = null,
    Object? memberCount = null,
    Object? maxMembers = freezed,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            level: freezed == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int?,
            tierName: freezed == tierName
                ? _value.tierName
                : tierName // ignore: cast_nullable_to_non_nullable
                      as String?,
            points: freezed == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdByUserId: freezed == createdByUserId
                ? _value.createdByUserId
                : createdByUserId // ignore: cast_nullable_to_non_nullable
                      as int?,
            levelPointsMode: null == levelPointsMode
                ? _value.levelPointsMode
                : levelPointsMode // ignore: cast_nullable_to_non_nullable
                      as int,
            levelRows: null == levelRows
                ? _value.levelRows
                : levelRows // ignore: cast_nullable_to_non_nullable
                      as List<TeamLevelRowModel>,
            badges: null == badges
                ? _value.badges
                : badges // ignore: cast_nullable_to_non_nullable
                      as List<TeamBadgeModel>,
            memberCount: null == memberCount
                ? _value.memberCount
                : memberCount // ignore: cast_nullable_to_non_nullable
                      as int,
            maxMembers: freezed == maxMembers
                ? _value.maxMembers
                : maxMembers // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamModelImplCopyWith<$Res>
    implements $TeamModelCopyWith<$Res> {
  factory _$$TeamModelImplCopyWith(
    _$TeamModelImpl value,
    $Res Function(_$TeamModelImpl) then,
  ) = __$$TeamModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String? description,
    int? level,
    String? tierName,
    int? points,
    int? createdByUserId,
    @JsonKey(fromJson: _levelPointsModeFromJson) int levelPointsMode,
    List<TeamLevelRowModel> levelRows,
    @JsonKey(fromJson: _teamBadgesFromJson, includeToJson: false)
    List<TeamBadgeModel> badges,
    int memberCount,
    int? maxMembers,
  });
}

/// @nodoc
class __$$TeamModelImplCopyWithImpl<$Res>
    extends _$TeamModelCopyWithImpl<$Res, _$TeamModelImpl>
    implements _$$TeamModelImplCopyWith<$Res> {
  __$$TeamModelImplCopyWithImpl(
    _$TeamModelImpl _value,
    $Res Function(_$TeamModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? level = freezed,
    Object? tierName = freezed,
    Object? points = freezed,
    Object? createdByUserId = freezed,
    Object? levelPointsMode = null,
    Object? levelRows = null,
    Object? badges = null,
    Object? memberCount = null,
    Object? maxMembers = freezed,
  }) {
    return _then(
      _$TeamModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        level: freezed == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int?,
        tierName: freezed == tierName
            ? _value.tierName
            : tierName // ignore: cast_nullable_to_non_nullable
                  as String?,
        points: freezed == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdByUserId: freezed == createdByUserId
            ? _value.createdByUserId
            : createdByUserId // ignore: cast_nullable_to_non_nullable
                  as int?,
        levelPointsMode: null == levelPointsMode
            ? _value.levelPointsMode
            : levelPointsMode // ignore: cast_nullable_to_non_nullable
                  as int,
        levelRows: null == levelRows
            ? _value._levelRows
            : levelRows // ignore: cast_nullable_to_non_nullable
                  as List<TeamLevelRowModel>,
        badges: null == badges
            ? _value._badges
            : badges // ignore: cast_nullable_to_non_nullable
                  as List<TeamBadgeModel>,
        memberCount: null == memberCount
            ? _value.memberCount
            : memberCount // ignore: cast_nullable_to_non_nullable
                  as int,
        maxMembers: freezed == maxMembers
            ? _value.maxMembers
            : maxMembers // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamModelImpl extends _TeamModel {
  const _$TeamModelImpl({
    required this.id,
    required this.name,
    this.description,
    this.level,
    this.tierName,
    this.points,
    this.createdByUserId,
    @JsonKey(fromJson: _levelPointsModeFromJson) this.levelPointsMode = 1,
    final List<TeamLevelRowModel> levelRows = const [],
    @JsonKey(fromJson: _teamBadgesFromJson, includeToJson: false)
    final List<TeamBadgeModel> badges = const [],
    this.memberCount = 0,
    this.maxMembers,
  }) : _levelRows = levelRows,
       _badges = badges,
       super._();

  factory _$TeamModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int? level;
  @override
  final String? tierName;
  @override
  final int? points;
  @override
  final int? createdByUserId;
  @override
  @JsonKey(fromJson: _levelPointsModeFromJson)
  final int levelPointsMode;
  final List<TeamLevelRowModel> _levelRows;
  @override
  @JsonKey()
  List<TeamLevelRowModel> get levelRows {
    if (_levelRows is EqualUnmodifiableListView) return _levelRows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_levelRows);
  }

  final List<TeamBadgeModel> _badges;
  @override
  @JsonKey(fromJson: _teamBadgesFromJson, includeToJson: false)
  List<TeamBadgeModel> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  @override
  @JsonKey()
  final int memberCount;
  @override
  final int? maxMembers;

  @override
  String toString() {
    return 'TeamModel(id: $id, name: $name, description: $description, level: $level, tierName: $tierName, points: $points, createdByUserId: $createdByUserId, levelPointsMode: $levelPointsMode, levelRows: $levelRows, badges: $badges, memberCount: $memberCount, maxMembers: $maxMembers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.tierName, tierName) ||
                other.tierName == tierName) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId) &&
            (identical(other.levelPointsMode, levelPointsMode) ||
                other.levelPointsMode == levelPointsMode) &&
            const DeepCollectionEquality().equals(
              other._levelRows,
              _levelRows,
            ) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.maxMembers, maxMembers) ||
                other.maxMembers == maxMembers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    level,
    tierName,
    points,
    createdByUserId,
    levelPointsMode,
    const DeepCollectionEquality().hash(_levelRows),
    const DeepCollectionEquality().hash(_badges),
    memberCount,
    maxMembers,
  );

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamModelImplCopyWith<_$TeamModelImpl> get copyWith =>
      __$$TeamModelImplCopyWithImpl<_$TeamModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamModelImplToJson(this);
  }
}

abstract class _TeamModel extends TeamModel {
  const factory _TeamModel({
    required final int id,
    required final String name,
    final String? description,
    final int? level,
    final String? tierName,
    final int? points,
    final int? createdByUserId,
    @JsonKey(fromJson: _levelPointsModeFromJson) final int levelPointsMode,
    final List<TeamLevelRowModel> levelRows,
    @JsonKey(fromJson: _teamBadgesFromJson, includeToJson: false)
    final List<TeamBadgeModel> badges,
    final int memberCount,
    final int? maxMembers,
  }) = _$TeamModelImpl;
  const _TeamModel._() : super._();

  factory _TeamModel.fromJson(Map<String, dynamic> json) =
      _$TeamModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  int? get level;
  @override
  String? get tierName;
  @override
  int? get points;
  @override
  int? get createdByUserId;
  @override
  @JsonKey(fromJson: _levelPointsModeFromJson)
  int get levelPointsMode;
  @override
  List<TeamLevelRowModel> get levelRows;
  @override
  @JsonKey(fromJson: _teamBadgesFromJson, includeToJson: false)
  List<TeamBadgeModel> get badges;
  @override
  int get memberCount;
  @override
  int? get maxMembers;

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamModelImplCopyWith<_$TeamModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
