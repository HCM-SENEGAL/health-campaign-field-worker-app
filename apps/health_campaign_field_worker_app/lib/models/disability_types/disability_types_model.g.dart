// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disability_types_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DisabilityTypesWrapperModel _$$_DisabilityTypesWrapperModelFromJson(
        Map<String, dynamic> json) =>
    _$_DisabilityTypesWrapperModel(
      disabilityTypesList: (json['disabilityTypes'] as List<dynamic>?)
          ?.map((e) => DisabilityTypes.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_DisabilityTypesWrapperModelToJson(
        _$_DisabilityTypesWrapperModel instance) =>
    <String, dynamic>{
      'disabilityTypes': instance.disabilityTypesList,
    };

_$_DisabilityTypes _$$_DisabilityTypesFromJson(Map<String, dynamic> json) =>
    _$_DisabilityTypes(
      code: json['code'] as String,
      name: json['name'] as String,
      active: json['active'] as bool,
    );

Map<String, dynamic> _$$_DisabilityTypesToJson(_$_DisabilityTypes instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'active': instance.active,
    };
