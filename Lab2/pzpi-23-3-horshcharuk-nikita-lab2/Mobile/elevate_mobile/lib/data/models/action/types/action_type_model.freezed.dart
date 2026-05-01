// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action_type_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActionTypeModel _$ActionTypeModelFromJson(Map<String, dynamic> json) {
  return _ActionTypeModel.fromJson(json);
}

/// @nodoc
mixin _$ActionTypeModel {
  int get id => throw _privateConstructorUsedError;
  int get teamId => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get defaultPoints => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this ActionTypeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActionTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActionTypeModelCopyWith<ActionTypeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActionTypeModelCopyWith<$Res> {
  factory $ActionTypeModelCopyWith(
    ActionTypeModel value,
    $Res Function(ActionTypeModel) then,
  ) = _$ActionTypeModelCopyWithImpl<$Res, ActionTypeModel>;
  @useResult
  $Res call({
    int id,
    int teamId,
    String code,
    String name,
    String? description,
    int defaultPoints,
    String? category,
    bool isActive,
  });
}

/// @nodoc
class _$ActionTypeModelCopyWithImpl<$Res, $Val extends ActionTypeModel>
    implements $ActionTypeModelCopyWith<$Res> {
  _$ActionTypeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActionTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? defaultPoints = null,
    Object? category = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as int,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultPoints: null == defaultPoints
                ? _value.defaultPoints
                : defaultPoints // ignore: cast_nullable_to_non_nullable
                      as int,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActionTypeModelImplCopyWith<$Res>
    implements $ActionTypeModelCopyWith<$Res> {
  factory _$$ActionTypeModelImplCopyWith(
    _$ActionTypeModelImpl value,
    $Res Function(_$ActionTypeModelImpl) then,
  ) = __$$ActionTypeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int teamId,
    String code,
    String name,
    String? description,
    int defaultPoints,
    String? category,
    bool isActive,
  });
}

/// @nodoc
class __$$ActionTypeModelImplCopyWithImpl<$Res>
    extends _$ActionTypeModelCopyWithImpl<$Res, _$ActionTypeModelImpl>
    implements _$$ActionTypeModelImplCopyWith<$Res> {
  __$$ActionTypeModelImplCopyWithImpl(
    _$ActionTypeModelImpl _value,
    $Res Function(_$ActionTypeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActionTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teamId = null,
    Object? code = null,
    Object? name = null,
    Object? description = freezed,
    Object? defaultPoints = null,
    Object? category = freezed,
    Object? isActive = null,
  }) {
    return _then(
      _$ActionTypeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as int,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultPoints: null == defaultPoints
            ? _value.defaultPoints
            : defaultPoints // ignore: cast_nullable_to_non_nullable
                  as int,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActionTypeModelImpl extends _ActionTypeModel {
  const _$ActionTypeModelImpl({
    required this.id,
    required this.teamId,
    required this.code,
    required this.name,
    this.description,
    required this.defaultPoints,
    this.category,
    required this.isActive,
  }) : super._();

  factory _$ActionTypeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActionTypeModelImplFromJson(json);

  @override
  final int id;
  @override
  final int teamId;
  @override
  final String code;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int defaultPoints;
  @override
  final String? category;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'ActionTypeModel(id: $id, teamId: $teamId, code: $code, name: $name, description: $description, defaultPoints: $defaultPoints, category: $category, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActionTypeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.defaultPoints, defaultPoints) ||
                other.defaultPoints == defaultPoints) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    teamId,
    code,
    name,
    description,
    defaultPoints,
    category,
    isActive,
  );

  /// Create a copy of ActionTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActionTypeModelImplCopyWith<_$ActionTypeModelImpl> get copyWith =>
      __$$ActionTypeModelImplCopyWithImpl<_$ActionTypeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ActionTypeModelImplToJson(this);
  }
}

abstract class _ActionTypeModel extends ActionTypeModel {
  const factory _ActionTypeModel({
    required final int id,
    required final int teamId,
    required final String code,
    required final String name,
    final String? description,
    required final int defaultPoints,
    final String? category,
    required final bool isActive,
  }) = _$ActionTypeModelImpl;
  const _ActionTypeModel._() : super._();

  factory _ActionTypeModel.fromJson(Map<String, dynamic> json) =
      _$ActionTypeModelImpl.fromJson;

  @override
  int get id;
  @override
  int get teamId;
  @override
  String get code;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get defaultPoints;
  @override
  String? get category;
  @override
  bool get isActive;

  /// Create a copy of ActionTypeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActionTypeModelImplCopyWith<_$ActionTypeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
