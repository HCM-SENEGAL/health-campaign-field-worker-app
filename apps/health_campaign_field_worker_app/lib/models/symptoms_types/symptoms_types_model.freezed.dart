// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'symptoms_types_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SymptomsTypesPrimaryWrapperModel _$SymptomsTypesPrimaryWrapperModelFromJson(
    Map<String, dynamic> json) {
  return _SymptomsTypesPrimaryWrapperModel.fromJson(json);
}

/// @nodoc
mixin _$SymptomsTypesPrimaryWrapperModel {
  @JsonKey(name: 'HCM-SYMPTOMS-TYPES')
  SymptomsTypesSecondaryWrapperModel? get symptomsTypes =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SymptomsTypesPrimaryWrapperModelCopyWith<SymptomsTypesPrimaryWrapperModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SymptomsTypesPrimaryWrapperModelCopyWith<$Res> {
  factory $SymptomsTypesPrimaryWrapperModelCopyWith(
          SymptomsTypesPrimaryWrapperModel value,
          $Res Function(SymptomsTypesPrimaryWrapperModel) then) =
      _$SymptomsTypesPrimaryWrapperModelCopyWithImpl<$Res,
          SymptomsTypesPrimaryWrapperModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'HCM-SYMPTOMS-TYPES')
      SymptomsTypesSecondaryWrapperModel? symptomsTypes});

  $SymptomsTypesSecondaryWrapperModelCopyWith<$Res>? get symptomsTypes;
}

/// @nodoc
class _$SymptomsTypesPrimaryWrapperModelCopyWithImpl<$Res,
        $Val extends SymptomsTypesPrimaryWrapperModel>
    implements $SymptomsTypesPrimaryWrapperModelCopyWith<$Res> {
  _$SymptomsTypesPrimaryWrapperModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symptomsTypes = freezed,
  }) {
    return _then(_value.copyWith(
      symptomsTypes: freezed == symptomsTypes
          ? _value.symptomsTypes
          : symptomsTypes // ignore: cast_nullable_to_non_nullable
              as SymptomsTypesSecondaryWrapperModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SymptomsTypesSecondaryWrapperModelCopyWith<$Res>? get symptomsTypes {
    if (_value.symptomsTypes == null) {
      return null;
    }

    return $SymptomsTypesSecondaryWrapperModelCopyWith<$Res>(
        _value.symptomsTypes!, (value) {
      return _then(_value.copyWith(symptomsTypes: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SymptomsTypesPrimaryWrapperModelImplCopyWith<$Res>
    implements $SymptomsTypesPrimaryWrapperModelCopyWith<$Res> {
  factory _$$SymptomsTypesPrimaryWrapperModelImplCopyWith(
          _$SymptomsTypesPrimaryWrapperModelImpl value,
          $Res Function(_$SymptomsTypesPrimaryWrapperModelImpl) then) =
      __$$SymptomsTypesPrimaryWrapperModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'HCM-SYMPTOMS-TYPES')
      SymptomsTypesSecondaryWrapperModel? symptomsTypes});

  @override
  $SymptomsTypesSecondaryWrapperModelCopyWith<$Res>? get symptomsTypes;
}

/// @nodoc
class __$$SymptomsTypesPrimaryWrapperModelImplCopyWithImpl<$Res>
    extends _$SymptomsTypesPrimaryWrapperModelCopyWithImpl<$Res,
        _$SymptomsTypesPrimaryWrapperModelImpl>
    implements _$$SymptomsTypesPrimaryWrapperModelImplCopyWith<$Res> {
  __$$SymptomsTypesPrimaryWrapperModelImplCopyWithImpl(
      _$SymptomsTypesPrimaryWrapperModelImpl _value,
      $Res Function(_$SymptomsTypesPrimaryWrapperModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symptomsTypes = freezed,
  }) {
    return _then(_$SymptomsTypesPrimaryWrapperModelImpl(
      symptomsTypes: freezed == symptomsTypes
          ? _value.symptomsTypes
          : symptomsTypes // ignore: cast_nullable_to_non_nullable
              as SymptomsTypesSecondaryWrapperModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SymptomsTypesPrimaryWrapperModelImpl
    implements _SymptomsTypesPrimaryWrapperModel {
  const _$SymptomsTypesPrimaryWrapperModelImpl(
      {@JsonKey(name: 'HCM-SYMPTOMS-TYPES') this.symptomsTypes});

  factory _$SymptomsTypesPrimaryWrapperModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SymptomsTypesPrimaryWrapperModelImplFromJson(json);

  @override
  @JsonKey(name: 'HCM-SYMPTOMS-TYPES')
  final SymptomsTypesSecondaryWrapperModel? symptomsTypes;

  @override
  String toString() {
    return 'SymptomsTypesPrimaryWrapperModel(symptomsTypes: $symptomsTypes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymptomsTypesPrimaryWrapperModelImpl &&
            (identical(other.symptomsTypes, symptomsTypes) ||
                other.symptomsTypes == symptomsTypes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, symptomsTypes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SymptomsTypesPrimaryWrapperModelImplCopyWith<
          _$SymptomsTypesPrimaryWrapperModelImpl>
      get copyWith => __$$SymptomsTypesPrimaryWrapperModelImplCopyWithImpl<
          _$SymptomsTypesPrimaryWrapperModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SymptomsTypesPrimaryWrapperModelImplToJson(
      this,
    );
  }
}

abstract class _SymptomsTypesPrimaryWrapperModel
    implements SymptomsTypesPrimaryWrapperModel {
  const factory _SymptomsTypesPrimaryWrapperModel(
          {@JsonKey(name: 'HCM-SYMPTOMS-TYPES')
          final SymptomsTypesSecondaryWrapperModel? symptomsTypes}) =
      _$SymptomsTypesPrimaryWrapperModelImpl;

  factory _SymptomsTypesPrimaryWrapperModel.fromJson(
          Map<String, dynamic> json) =
      _$SymptomsTypesPrimaryWrapperModelImpl.fromJson;

  @override
  @JsonKey(name: 'HCM-SYMPTOMS-TYPES')
  SymptomsTypesSecondaryWrapperModel? get symptomsTypes;
  @override
  @JsonKey(ignore: true)
  _$$SymptomsTypesPrimaryWrapperModelImplCopyWith<
          _$SymptomsTypesPrimaryWrapperModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SymptomsTypesPrimaryWrapperModelSMC
    _$SymptomsTypesPrimaryWrapperModelSMCFromJson(Map<String, dynamic> json) {
  return _SymptomsTypesPrimaryWrapperModelSMC.fromJson(json);
}

/// @nodoc
mixin _$SymptomsTypesPrimaryWrapperModelSMC {
  @JsonKey(name: 'HCM-SYMPTOMS-TYPES-SMC')
  SymptomsTypesSecondaryWrapperModel? get symptomsTypesSmc =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SymptomsTypesPrimaryWrapperModelSMCCopyWith<
          SymptomsTypesPrimaryWrapperModelSMC>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SymptomsTypesPrimaryWrapperModelSMCCopyWith<$Res> {
  factory $SymptomsTypesPrimaryWrapperModelSMCCopyWith(
          SymptomsTypesPrimaryWrapperModelSMC value,
          $Res Function(SymptomsTypesPrimaryWrapperModelSMC) then) =
      _$SymptomsTypesPrimaryWrapperModelSMCCopyWithImpl<$Res,
          SymptomsTypesPrimaryWrapperModelSMC>;
  @useResult
  $Res call(
      {@JsonKey(name: 'HCM-SYMPTOMS-TYPES-SMC')
      SymptomsTypesSecondaryWrapperModel? symptomsTypesSmc});

  $SymptomsTypesSecondaryWrapperModelCopyWith<$Res>? get symptomsTypesSmc;
}

/// @nodoc
class _$SymptomsTypesPrimaryWrapperModelSMCCopyWithImpl<$Res,
        $Val extends SymptomsTypesPrimaryWrapperModelSMC>
    implements $SymptomsTypesPrimaryWrapperModelSMCCopyWith<$Res> {
  _$SymptomsTypesPrimaryWrapperModelSMCCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symptomsTypesSmc = freezed,
  }) {
    return _then(_value.copyWith(
      symptomsTypesSmc: freezed == symptomsTypesSmc
          ? _value.symptomsTypesSmc
          : symptomsTypesSmc // ignore: cast_nullable_to_non_nullable
              as SymptomsTypesSecondaryWrapperModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SymptomsTypesSecondaryWrapperModelCopyWith<$Res>? get symptomsTypesSmc {
    if (_value.symptomsTypesSmc == null) {
      return null;
    }

    return $SymptomsTypesSecondaryWrapperModelCopyWith<$Res>(
        _value.symptomsTypesSmc!, (value) {
      return _then(_value.copyWith(symptomsTypesSmc: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SymptomsTypesPrimaryWrapperModelSMCImplCopyWith<$Res>
    implements $SymptomsTypesPrimaryWrapperModelSMCCopyWith<$Res> {
  factory _$$SymptomsTypesPrimaryWrapperModelSMCImplCopyWith(
          _$SymptomsTypesPrimaryWrapperModelSMCImpl value,
          $Res Function(_$SymptomsTypesPrimaryWrapperModelSMCImpl) then) =
      __$$SymptomsTypesPrimaryWrapperModelSMCImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'HCM-SYMPTOMS-TYPES-SMC')
      SymptomsTypesSecondaryWrapperModel? symptomsTypesSmc});

  @override
  $SymptomsTypesSecondaryWrapperModelCopyWith<$Res>? get symptomsTypesSmc;
}

/// @nodoc
class __$$SymptomsTypesPrimaryWrapperModelSMCImplCopyWithImpl<$Res>
    extends _$SymptomsTypesPrimaryWrapperModelSMCCopyWithImpl<$Res,
        _$SymptomsTypesPrimaryWrapperModelSMCImpl>
    implements _$$SymptomsTypesPrimaryWrapperModelSMCImplCopyWith<$Res> {
  __$$SymptomsTypesPrimaryWrapperModelSMCImplCopyWithImpl(
      _$SymptomsTypesPrimaryWrapperModelSMCImpl _value,
      $Res Function(_$SymptomsTypesPrimaryWrapperModelSMCImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symptomsTypesSmc = freezed,
  }) {
    return _then(_$SymptomsTypesPrimaryWrapperModelSMCImpl(
      symptomsTypesSmc: freezed == symptomsTypesSmc
          ? _value.symptomsTypesSmc
          : symptomsTypesSmc // ignore: cast_nullable_to_non_nullable
              as SymptomsTypesSecondaryWrapperModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SymptomsTypesPrimaryWrapperModelSMCImpl
    implements _SymptomsTypesPrimaryWrapperModelSMC {
  const _$SymptomsTypesPrimaryWrapperModelSMCImpl(
      {@JsonKey(name: 'HCM-SYMPTOMS-TYPES-SMC') this.symptomsTypesSmc});

  factory _$SymptomsTypesPrimaryWrapperModelSMCImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SymptomsTypesPrimaryWrapperModelSMCImplFromJson(json);

  @override
  @JsonKey(name: 'HCM-SYMPTOMS-TYPES-SMC')
  final SymptomsTypesSecondaryWrapperModel? symptomsTypesSmc;

  @override
  String toString() {
    return 'SymptomsTypesPrimaryWrapperModelSMC(symptomsTypesSmc: $symptomsTypesSmc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymptomsTypesPrimaryWrapperModelSMCImpl &&
            (identical(other.symptomsTypesSmc, symptomsTypesSmc) ||
                other.symptomsTypesSmc == symptomsTypesSmc));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, symptomsTypesSmc);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SymptomsTypesPrimaryWrapperModelSMCImplCopyWith<
          _$SymptomsTypesPrimaryWrapperModelSMCImpl>
      get copyWith => __$$SymptomsTypesPrimaryWrapperModelSMCImplCopyWithImpl<
          _$SymptomsTypesPrimaryWrapperModelSMCImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SymptomsTypesPrimaryWrapperModelSMCImplToJson(
      this,
    );
  }
}

abstract class _SymptomsTypesPrimaryWrapperModelSMC
    implements SymptomsTypesPrimaryWrapperModelSMC {
  const factory _SymptomsTypesPrimaryWrapperModelSMC(
          {@JsonKey(name: 'HCM-SYMPTOMS-TYPES-SMC')
          final SymptomsTypesSecondaryWrapperModel? symptomsTypesSmc}) =
      _$SymptomsTypesPrimaryWrapperModelSMCImpl;

  factory _SymptomsTypesPrimaryWrapperModelSMC.fromJson(
          Map<String, dynamic> json) =
      _$SymptomsTypesPrimaryWrapperModelSMCImpl.fromJson;

  @override
  @JsonKey(name: 'HCM-SYMPTOMS-TYPES-SMC')
  SymptomsTypesSecondaryWrapperModel? get symptomsTypesSmc;
  @override
  @JsonKey(ignore: true)
  _$$SymptomsTypesPrimaryWrapperModelSMCImplCopyWith<
          _$SymptomsTypesPrimaryWrapperModelSMCImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SymptomsTypesSecondaryWrapperModel _$SymptomsTypesSecondaryWrapperModelFromJson(
    Map<String, dynamic> json) {
  return _SymptomsTypesSecondaryWrapperModel.fromJson(json);
}

/// @nodoc
mixin _$SymptomsTypesSecondaryWrapperModel {
  @JsonKey(name: 'symptomsTypes')
  List<SymptomsType>? get symptomsTypeList =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SymptomsTypesSecondaryWrapperModelCopyWith<
          SymptomsTypesSecondaryWrapperModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SymptomsTypesSecondaryWrapperModelCopyWith<$Res> {
  factory $SymptomsTypesSecondaryWrapperModelCopyWith(
          SymptomsTypesSecondaryWrapperModel value,
          $Res Function(SymptomsTypesSecondaryWrapperModel) then) =
      _$SymptomsTypesSecondaryWrapperModelCopyWithImpl<$Res,
          SymptomsTypesSecondaryWrapperModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'symptomsTypes') List<SymptomsType>? symptomsTypeList});
}

/// @nodoc
class _$SymptomsTypesSecondaryWrapperModelCopyWithImpl<$Res,
        $Val extends SymptomsTypesSecondaryWrapperModel>
    implements $SymptomsTypesSecondaryWrapperModelCopyWith<$Res> {
  _$SymptomsTypesSecondaryWrapperModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symptomsTypeList = freezed,
  }) {
    return _then(_value.copyWith(
      symptomsTypeList: freezed == symptomsTypeList
          ? _value.symptomsTypeList
          : symptomsTypeList // ignore: cast_nullable_to_non_nullable
              as List<SymptomsType>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SymptomsTypesSecondaryWrapperModelImplCopyWith<$Res>
    implements $SymptomsTypesSecondaryWrapperModelCopyWith<$Res> {
  factory _$$SymptomsTypesSecondaryWrapperModelImplCopyWith(
          _$SymptomsTypesSecondaryWrapperModelImpl value,
          $Res Function(_$SymptomsTypesSecondaryWrapperModelImpl) then) =
      __$$SymptomsTypesSecondaryWrapperModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'symptomsTypes') List<SymptomsType>? symptomsTypeList});
}

/// @nodoc
class __$$SymptomsTypesSecondaryWrapperModelImplCopyWithImpl<$Res>
    extends _$SymptomsTypesSecondaryWrapperModelCopyWithImpl<$Res,
        _$SymptomsTypesSecondaryWrapperModelImpl>
    implements _$$SymptomsTypesSecondaryWrapperModelImplCopyWith<$Res> {
  __$$SymptomsTypesSecondaryWrapperModelImplCopyWithImpl(
      _$SymptomsTypesSecondaryWrapperModelImpl _value,
      $Res Function(_$SymptomsTypesSecondaryWrapperModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symptomsTypeList = freezed,
  }) {
    return _then(_$SymptomsTypesSecondaryWrapperModelImpl(
      symptomsTypeList: freezed == symptomsTypeList
          ? _value._symptomsTypeList
          : symptomsTypeList // ignore: cast_nullable_to_non_nullable
              as List<SymptomsType>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SymptomsTypesSecondaryWrapperModelImpl
    implements _SymptomsTypesSecondaryWrapperModel {
  const _$SymptomsTypesSecondaryWrapperModelImpl(
      {@JsonKey(name: 'symptomsTypes')
      final List<SymptomsType>? symptomsTypeList})
      : _symptomsTypeList = symptomsTypeList;

  factory _$SymptomsTypesSecondaryWrapperModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SymptomsTypesSecondaryWrapperModelImplFromJson(json);

  final List<SymptomsType>? _symptomsTypeList;
  @override
  @JsonKey(name: 'symptomsTypes')
  List<SymptomsType>? get symptomsTypeList {
    final value = _symptomsTypeList;
    if (value == null) return null;
    if (_symptomsTypeList is EqualUnmodifiableListView)
      return _symptomsTypeList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SymptomsTypesSecondaryWrapperModel(symptomsTypeList: $symptomsTypeList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymptomsTypesSecondaryWrapperModelImpl &&
            const DeepCollectionEquality()
                .equals(other._symptomsTypeList, _symptomsTypeList));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_symptomsTypeList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SymptomsTypesSecondaryWrapperModelImplCopyWith<
          _$SymptomsTypesSecondaryWrapperModelImpl>
      get copyWith => __$$SymptomsTypesSecondaryWrapperModelImplCopyWithImpl<
          _$SymptomsTypesSecondaryWrapperModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SymptomsTypesSecondaryWrapperModelImplToJson(
      this,
    );
  }
}

abstract class _SymptomsTypesSecondaryWrapperModel
    implements SymptomsTypesSecondaryWrapperModel {
  const factory _SymptomsTypesSecondaryWrapperModel(
          {@JsonKey(name: 'symptomsTypes')
          final List<SymptomsType>? symptomsTypeList}) =
      _$SymptomsTypesSecondaryWrapperModelImpl;

  factory _SymptomsTypesSecondaryWrapperModel.fromJson(
          Map<String, dynamic> json) =
      _$SymptomsTypesSecondaryWrapperModelImpl.fromJson;

  @override
  @JsonKey(name: 'symptomsTypes')
  List<SymptomsType>? get symptomsTypeList;
  @override
  @JsonKey(ignore: true)
  _$$SymptomsTypesSecondaryWrapperModelImplCopyWith<
          _$SymptomsTypesSecondaryWrapperModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SymptomsTypesSecondaryWrapperModelSMC
    _$SymptomsTypesSecondaryWrapperModelSMCFromJson(Map<String, dynamic> json) {
  return _SymptomsTypesSecondaryWrapperModelSMC.fromJson(json);
}

/// @nodoc
mixin _$SymptomsTypesSecondaryWrapperModelSMC {
  @JsonKey(name: 'symptomsTypesSmc')
  List<SymptomsType>? get symptomsTypeSmcList =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SymptomsTypesSecondaryWrapperModelSMCCopyWith<
          SymptomsTypesSecondaryWrapperModelSMC>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SymptomsTypesSecondaryWrapperModelSMCCopyWith<$Res> {
  factory $SymptomsTypesSecondaryWrapperModelSMCCopyWith(
          SymptomsTypesSecondaryWrapperModelSMC value,
          $Res Function(SymptomsTypesSecondaryWrapperModelSMC) then) =
      _$SymptomsTypesSecondaryWrapperModelSMCCopyWithImpl<$Res,
          SymptomsTypesSecondaryWrapperModelSMC>;
  @useResult
  $Res call(
      {@JsonKey(name: 'symptomsTypesSmc')
      List<SymptomsType>? symptomsTypeSmcList});
}

/// @nodoc
class _$SymptomsTypesSecondaryWrapperModelSMCCopyWithImpl<$Res,
        $Val extends SymptomsTypesSecondaryWrapperModelSMC>
    implements $SymptomsTypesSecondaryWrapperModelSMCCopyWith<$Res> {
  _$SymptomsTypesSecondaryWrapperModelSMCCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symptomsTypeSmcList = freezed,
  }) {
    return _then(_value.copyWith(
      symptomsTypeSmcList: freezed == symptomsTypeSmcList
          ? _value.symptomsTypeSmcList
          : symptomsTypeSmcList // ignore: cast_nullable_to_non_nullable
              as List<SymptomsType>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SymptomsTypesSecondaryWrapperModelSMCImplCopyWith<$Res>
    implements $SymptomsTypesSecondaryWrapperModelSMCCopyWith<$Res> {
  factory _$$SymptomsTypesSecondaryWrapperModelSMCImplCopyWith(
          _$SymptomsTypesSecondaryWrapperModelSMCImpl value,
          $Res Function(_$SymptomsTypesSecondaryWrapperModelSMCImpl) then) =
      __$$SymptomsTypesSecondaryWrapperModelSMCImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'symptomsTypesSmc')
      List<SymptomsType>? symptomsTypeSmcList});
}

/// @nodoc
class __$$SymptomsTypesSecondaryWrapperModelSMCImplCopyWithImpl<$Res>
    extends _$SymptomsTypesSecondaryWrapperModelSMCCopyWithImpl<$Res,
        _$SymptomsTypesSecondaryWrapperModelSMCImpl>
    implements _$$SymptomsTypesSecondaryWrapperModelSMCImplCopyWith<$Res> {
  __$$SymptomsTypesSecondaryWrapperModelSMCImplCopyWithImpl(
      _$SymptomsTypesSecondaryWrapperModelSMCImpl _value,
      $Res Function(_$SymptomsTypesSecondaryWrapperModelSMCImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symptomsTypeSmcList = freezed,
  }) {
    return _then(_$SymptomsTypesSecondaryWrapperModelSMCImpl(
      symptomsTypeSmcList: freezed == symptomsTypeSmcList
          ? _value._symptomsTypeSmcList
          : symptomsTypeSmcList // ignore: cast_nullable_to_non_nullable
              as List<SymptomsType>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SymptomsTypesSecondaryWrapperModelSMCImpl
    implements _SymptomsTypesSecondaryWrapperModelSMC {
  const _$SymptomsTypesSecondaryWrapperModelSMCImpl(
      {@JsonKey(name: 'symptomsTypesSmc')
      final List<SymptomsType>? symptomsTypeSmcList})
      : _symptomsTypeSmcList = symptomsTypeSmcList;

  factory _$SymptomsTypesSecondaryWrapperModelSMCImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SymptomsTypesSecondaryWrapperModelSMCImplFromJson(json);

  final List<SymptomsType>? _symptomsTypeSmcList;
  @override
  @JsonKey(name: 'symptomsTypesSmc')
  List<SymptomsType>? get symptomsTypeSmcList {
    final value = _symptomsTypeSmcList;
    if (value == null) return null;
    if (_symptomsTypeSmcList is EqualUnmodifiableListView)
      return _symptomsTypeSmcList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SymptomsTypesSecondaryWrapperModelSMC(symptomsTypeSmcList: $symptomsTypeSmcList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymptomsTypesSecondaryWrapperModelSMCImpl &&
            const DeepCollectionEquality()
                .equals(other._symptomsTypeSmcList, _symptomsTypeSmcList));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_symptomsTypeSmcList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SymptomsTypesSecondaryWrapperModelSMCImplCopyWith<
          _$SymptomsTypesSecondaryWrapperModelSMCImpl>
      get copyWith => __$$SymptomsTypesSecondaryWrapperModelSMCImplCopyWithImpl<
          _$SymptomsTypesSecondaryWrapperModelSMCImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SymptomsTypesSecondaryWrapperModelSMCImplToJson(
      this,
    );
  }
}

abstract class _SymptomsTypesSecondaryWrapperModelSMC
    implements SymptomsTypesSecondaryWrapperModelSMC {
  const factory _SymptomsTypesSecondaryWrapperModelSMC(
          {@JsonKey(name: 'symptomsTypesSmc')
          final List<SymptomsType>? symptomsTypeSmcList}) =
      _$SymptomsTypesSecondaryWrapperModelSMCImpl;

  factory _SymptomsTypesSecondaryWrapperModelSMC.fromJson(
          Map<String, dynamic> json) =
      _$SymptomsTypesSecondaryWrapperModelSMCImpl.fromJson;

  @override
  @JsonKey(name: 'symptomsTypesSmc')
  List<SymptomsType>? get symptomsTypeSmcList;
  @override
  @JsonKey(ignore: true)
  _$$SymptomsTypesSecondaryWrapperModelSMCImplCopyWith<
          _$SymptomsTypesSecondaryWrapperModelSMCImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SymptomsType _$SymptomsTypeFromJson(Map<String, dynamic> json) {
  return _SymptomsType.fromJson(json);
}

/// @nodoc
mixin _$SymptomsType {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SymptomsTypeCopyWith<SymptomsType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SymptomsTypeCopyWith<$Res> {
  factory $SymptomsTypeCopyWith(
          SymptomsType value, $Res Function(SymptomsType) then) =
      _$SymptomsTypeCopyWithImpl<$Res, SymptomsType>;
  @useResult
  $Res call({String code, String name, bool active});
}

/// @nodoc
class _$SymptomsTypeCopyWithImpl<$Res, $Val extends SymptomsType>
    implements $SymptomsTypeCopyWith<$Res> {
  _$SymptomsTypeCopyWithImpl(this._value, this._then);

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
abstract class _$$SymptomsTypeImplCopyWith<$Res>
    implements $SymptomsTypeCopyWith<$Res> {
  factory _$$SymptomsTypeImplCopyWith(
          _$SymptomsTypeImpl value, $Res Function(_$SymptomsTypeImpl) then) =
      __$$SymptomsTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String name, bool active});
}

/// @nodoc
class __$$SymptomsTypeImplCopyWithImpl<$Res>
    extends _$SymptomsTypeCopyWithImpl<$Res, _$SymptomsTypeImpl>
    implements _$$SymptomsTypeImplCopyWith<$Res> {
  __$$SymptomsTypeImplCopyWithImpl(
      _$SymptomsTypeImpl _value, $Res Function(_$SymptomsTypeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? active = null,
  }) {
    return _then(_$SymptomsTypeImpl(
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
class _$SymptomsTypeImpl implements _SymptomsType {
  const _$SymptomsTypeImpl(
      {required this.code, required this.name, required this.active});

  factory _$SymptomsTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$SymptomsTypeImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final bool active;

  @override
  String toString() {
    return 'SymptomsType(code: $code, name: $name, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymptomsTypeImpl &&
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
  _$$SymptomsTypeImplCopyWith<_$SymptomsTypeImpl> get copyWith =>
      __$$SymptomsTypeImplCopyWithImpl<_$SymptomsTypeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SymptomsTypeImplToJson(
      this,
    );
  }
}

abstract class _SymptomsType implements SymptomsType {
  const factory _SymptomsType(
      {required final String code,
      required final String name,
      required final bool active}) = _$SymptomsTypeImpl;

  factory _SymptomsType.fromJson(Map<String, dynamic> json) =
      _$SymptomsTypeImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  bool get active;
  @override
  @JsonKey(ignore: true)
  _$$SymptomsTypeImplCopyWith<_$SymptomsTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
