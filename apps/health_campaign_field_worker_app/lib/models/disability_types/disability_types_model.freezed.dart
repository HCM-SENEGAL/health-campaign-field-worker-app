// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'disability_types_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DisabilityTypesWrapperModel _$DisabilityTypesWrapperModelFromJson(
    Map<String, dynamic> json) {
  return _DisabilityTypesWrapperModel.fromJson(json);
}

/// @nodoc
mixin _$DisabilityTypesWrapperModel {
  @JsonKey(name: 'disabilityTypes')
  List<DisabilityTypes>? get disabilityTypesList =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DisabilityTypesWrapperModelCopyWith<DisabilityTypesWrapperModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisabilityTypesWrapperModelCopyWith<$Res> {
  factory $DisabilityTypesWrapperModelCopyWith(
          DisabilityTypesWrapperModel value,
          $Res Function(DisabilityTypesWrapperModel) then) =
      _$DisabilityTypesWrapperModelCopyWithImpl<$Res,
          DisabilityTypesWrapperModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'disabilityTypes')
          List<DisabilityTypes>? disabilityTypesList});
}

/// @nodoc
class _$DisabilityTypesWrapperModelCopyWithImpl<$Res,
        $Val extends DisabilityTypesWrapperModel>
    implements $DisabilityTypesWrapperModelCopyWith<$Res> {
  _$DisabilityTypesWrapperModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? disabilityTypesList = freezed,
  }) {
    return _then(_value.copyWith(
      disabilityTypesList: freezed == disabilityTypesList
          ? _value.disabilityTypesList
          : disabilityTypesList // ignore: cast_nullable_to_non_nullable
              as List<DisabilityTypes>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DisabilityTypesWrapperModelCopyWith<$Res>
    implements $DisabilityTypesWrapperModelCopyWith<$Res> {
  factory _$$_DisabilityTypesWrapperModelCopyWith(
          _$_DisabilityTypesWrapperModel value,
          $Res Function(_$_DisabilityTypesWrapperModel) then) =
      __$$_DisabilityTypesWrapperModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'disabilityTypes')
          List<DisabilityTypes>? disabilityTypesList});
}

/// @nodoc
class __$$_DisabilityTypesWrapperModelCopyWithImpl<$Res>
    extends _$DisabilityTypesWrapperModelCopyWithImpl<$Res,
        _$_DisabilityTypesWrapperModel>
    implements _$$_DisabilityTypesWrapperModelCopyWith<$Res> {
  __$$_DisabilityTypesWrapperModelCopyWithImpl(
      _$_DisabilityTypesWrapperModel _value,
      $Res Function(_$_DisabilityTypesWrapperModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? disabilityTypesList = freezed,
  }) {
    return _then(_$_DisabilityTypesWrapperModel(
      disabilityTypesList: freezed == disabilityTypesList
          ? _value._disabilityTypesList
          : disabilityTypesList // ignore: cast_nullable_to_non_nullable
              as List<DisabilityTypes>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DisabilityTypesWrapperModel implements _DisabilityTypesWrapperModel {
  const _$_DisabilityTypesWrapperModel(
      {@JsonKey(name: 'disabilityTypes')
          final List<DisabilityTypes>? disabilityTypesList})
      : _disabilityTypesList = disabilityTypesList;

  factory _$_DisabilityTypesWrapperModel.fromJson(Map<String, dynamic> json) =>
      _$$_DisabilityTypesWrapperModelFromJson(json);

  final List<DisabilityTypes>? _disabilityTypesList;
  @override
  @JsonKey(name: 'disabilityTypes')
  List<DisabilityTypes>? get disabilityTypesList {
    final value = _disabilityTypesList;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DisabilityTypesWrapperModel(disabilityTypesList: $disabilityTypesList)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DisabilityTypesWrapperModel &&
            const DeepCollectionEquality()
                .equals(other._disabilityTypesList, _disabilityTypesList));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_disabilityTypesList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DisabilityTypesWrapperModelCopyWith<_$_DisabilityTypesWrapperModel>
      get copyWith => __$$_DisabilityTypesWrapperModelCopyWithImpl<
          _$_DisabilityTypesWrapperModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DisabilityTypesWrapperModelToJson(
      this,
    );
  }
}

abstract class _DisabilityTypesWrapperModel
    implements DisabilityTypesWrapperModel {
  const factory _DisabilityTypesWrapperModel(
          {@JsonKey(name: 'disabilityTypes')
              final List<DisabilityTypes>? disabilityTypesList}) =
      _$_DisabilityTypesWrapperModel;

  factory _DisabilityTypesWrapperModel.fromJson(Map<String, dynamic> json) =
      _$_DisabilityTypesWrapperModel.fromJson;

  @override
  @JsonKey(name: 'disabilityTypes')
  List<DisabilityTypes>? get disabilityTypesList;
  @override
  @JsonKey(ignore: true)
  _$$_DisabilityTypesWrapperModelCopyWith<_$_DisabilityTypesWrapperModel>
      get copyWith => throw _privateConstructorUsedError;
}

DisabilityTypes _$DisabilityTypesFromJson(Map<String, dynamic> json) {
  return _DisabilityTypes.fromJson(json);
}

/// @nodoc
mixin _$DisabilityTypes {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DisabilityTypesCopyWith<DisabilityTypes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisabilityTypesCopyWith<$Res> {
  factory $DisabilityTypesCopyWith(
          DisabilityTypes value, $Res Function(DisabilityTypes) then) =
      _$DisabilityTypesCopyWithImpl<$Res, DisabilityTypes>;
  @useResult
  $Res call({String code, String name, bool active});
}

/// @nodoc
class _$DisabilityTypesCopyWithImpl<$Res, $Val extends DisabilityTypes>
    implements $DisabilityTypesCopyWith<$Res> {
  _$DisabilityTypesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? active = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DisabilityTypesCopyWith<$Res>
    implements $DisabilityTypesCopyWith<$Res> {
  factory _$$_DisabilityTypesCopyWith(
          _$_DisabilityTypes value, $Res Function(_$_DisabilityTypes) then) =
      __$$_DisabilityTypesCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, bool active});
}

/// @nodoc
class __$$_DisabilityTypesCopyWithImpl<$Res>
    extends _$DisabilityTypesCopyWithImpl<$Res, _$_DisabilityTypes>
    implements _$$_DisabilityTypesCopyWith<$Res> {
  __$$_DisabilityTypesCopyWithImpl(
      _$_DisabilityTypes _value, $Res Function(_$_DisabilityTypes) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? active = null,
  }) {
    return _then(_$_DisabilityTypes(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DisabilityTypes implements _DisabilityTypes {
  const _$_DisabilityTypes(
      {required this.code, required this.name, required this.active});

  factory _$_DisabilityTypes.fromJson(Map<String, dynamic> json) =>
      _$$_DisabilityTypesFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final bool active;

  @override
  String toString() {
    return 'DisabilityTypes(code: $code, name: $name, active: $active)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DisabilityTypes &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, code, name, active);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DisabilityTypesCopyWith<_$_DisabilityTypes> get copyWith =>
      __$$_DisabilityTypesCopyWithImpl<_$_DisabilityTypes>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DisabilityTypesToJson(
      this,
    );
  }
}

abstract class _DisabilityTypes implements DisabilityTypes {
  const factory _DisabilityTypes(
      {required final String code,
      required final String name,
      required final bool active}) = _$_DisabilityTypes;

  factory _DisabilityTypes.fromJson(Map<String, dynamic> json) =
      _$_DisabilityTypes.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  bool get active;
  @override
  @JsonKey(ignore: true)
  _$$_DisabilityTypesCopyWith<_$_DisabilityTypes> get copyWith =>
      throw _privateConstructorUsedError;
}
