// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_level_row_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamLevelRowModel _$TeamLevelRowModelFromJson(Map<String, dynamic> json) {
  return _TeamLevelRowModel.fromJson(json);
}

/// @nodoc
mixin _$TeamLevelRowModel {
  int get id => throw _privateConstructorUsedError;
  int get orderIndex => throw _privateConstructorUsedError;
  int get requiredPoints => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this TeamLevelRowModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamLevelRowModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamLevelRowModelCopyWith<TeamLevelRowModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamLevelRowModelCopyWith<$Res> {
  factory $TeamLevelRowModelCopyWith(
    TeamLevelRowModel value,
    $Res Function(TeamLevelRowModel) then,
  ) = _$TeamLevelRowModelCopyWithImpl<$Res, TeamLevelRowModel>;
  @useResult
  $Res call({int id, int orderIndex, int requiredPoints, String name});
}

/// @nodoc
class _$TeamLevelRowModelCopyWithImpl<$Res, $Val extends TeamLevelRowModel>
    implements $TeamLevelRowModelCopyWith<$Res> {
  _$TeamLevelRowModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamLevelRowModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderIndex = null,
    Object? requiredPoints = null,
    Object? name = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            orderIndex: null == orderIndex
                ? _value.orderIndex
                : orderIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            requiredPoints: null == requiredPoints
                ? _value.requiredPoints
                : requiredPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamLevelRowModelImplCopyWith<$Res>
    implements $TeamLevelRowModelCopyWith<$Res> {
  factory _$$TeamLevelRowModelImplCopyWith(
    _$TeamLevelRowModelImpl value,
    $Res Function(_$TeamLevelRowModelImpl) then,
  ) = __$$TeamLevelRowModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, int orderIndex, int requiredPoints, String name});
}

/// @nodoc
class __$$TeamLevelRowModelImplCopyWithImpl<$Res>
    extends _$TeamLevelRowModelCopyWithImpl<$Res, _$TeamLevelRowModelImpl>
    implements _$$TeamLevelRowModelImplCopyWith<$Res> {
  __$$TeamLevelRowModelImplCopyWithImpl(
    _$TeamLevelRowModelImpl _value,
    $Res Function(_$TeamLevelRowModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamLevelRowModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderIndex = null,
    Object? requiredPoints = null,
    Object? name = null,
  }) {
    return _then(
      _$TeamLevelRowModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        orderIndex: null == orderIndex
            ? _value.orderIndex
            : orderIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        requiredPoints: null == requiredPoints
            ? _value.requiredPoints
            : requiredPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamLevelRowModelImpl implements _TeamLevelRowModel {
  const _$TeamLevelRowModelImpl({
    required this.id,
    required this.orderIndex,
    required this.requiredPoints,
    required this.name,
  });

  factory _$TeamLevelRowModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamLevelRowModelImplFromJson(json);

  @override
  final int id;
  @override
  final int orderIndex;
  @override
  final int requiredPoints;
  @override
  final String name;

  @override
  String toString() {
    return 'TeamLevelRowModel(id: $id, orderIndex: $orderIndex, requiredPoints: $requiredPoints, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamLevelRowModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.requiredPoints, requiredPoints) ||
                other.requiredPoints == requiredPoints) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, orderIndex, requiredPoints, name);

  /// Create a copy of TeamLevelRowModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamLevelRowModelImplCopyWith<_$TeamLevelRowModelImpl> get copyWith =>
      __$$TeamLevelRowModelImplCopyWithImpl<_$TeamLevelRowModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamLevelRowModelImplToJson(this);
  }
}

abstract class _TeamLevelRowModel implements TeamLevelRowModel {
  const factory _TeamLevelRowModel({
    required final int id,
    required final int orderIndex,
    required final int requiredPoints,
    required final String name,
  }) = _$TeamLevelRowModelImpl;

  factory _TeamLevelRowModel.fromJson(Map<String, dynamic> json) =
      _$TeamLevelRowModelImpl.fromJson;

  @override
  int get id;
  @override
  int get orderIndex;
  @override
  int get requiredPoints;
  @override
  String get name;

  /// Create a copy of TeamLevelRowModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamLevelRowModelImplCopyWith<_$TeamLevelRowModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
