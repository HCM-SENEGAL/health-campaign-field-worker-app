// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'beneficiary_type.dart';

class BeneficiaryTypeMapper extends EnumMapper<BeneficiaryType> {
  BeneficiaryTypeMapper._();

  static BeneficiaryTypeMapper? _instance;
  static BeneficiaryTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BeneficiaryTypeMapper._());
    }
    return _instance!;
  }

  static BeneficiaryType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  BeneficiaryType decode(dynamic value) {
    switch (value) {
      case "INDIVIDUAL":
        return BeneficiaryType.individual;
      case "HOUSEHOLD":
        return BeneficiaryType.household;
      case "PRODUCT":
        return BeneficiaryType.product;
      case "3-11MONTH":
        return BeneficiaryType.individual1;
      case "12-59MONTH":
        return BeneficiaryType.individual2;
      case "60-120MONTH":
        return BeneficiaryType.individual3;
      case "3-59MONTH":
        return BeneficiaryType.individual4;
      case "60-119MONTH":
        return BeneficiaryType.individual5;
      case "120-167MONTH":
        return BeneficiaryType.individual6;
      case "168-1800MONTH":
        return BeneficiaryType.individual7;
      case "COBLISTER1":
        return BeneficiaryType.coblister1;
      case "COBLISTER2":
        return BeneficiaryType.coblister2;
      case "IVERMECTIN":
        return BeneficiaryType.ivermectin;
      case "ALBENDAZOLE":
        return BeneficiaryType.albendazole;
      case "SPAQ1":
        return BeneficiaryType.spaq1;
      case "SPAQ2":
        return BeneficiaryType.spaq2;
      case "Plaquette 6":
        return BeneficiaryType.plaquette6;
      case "Plaquette 3":
        return BeneficiaryType.plaquette3;
      case "Plaquette 9":
        return BeneficiaryType.plaquette9;
      case "DHAPQ":
        return BeneficiaryType.dhapq;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(BeneficiaryType self) {
    switch (self) {
      case BeneficiaryType.individual:
        return "INDIVIDUAL";
      case BeneficiaryType.household:
        return "HOUSEHOLD";
      case BeneficiaryType.product:
        return "PRODUCT";
      case BeneficiaryType.individual1:
        return "3-11MONTH";
      case BeneficiaryType.individual2:
        return "12-59MONTH";
      case BeneficiaryType.individual3:
        return "60-120MONTH";
      case BeneficiaryType.individual4:
        return "3-59MONTH";
      case BeneficiaryType.individual5:
        return "60-119MONTH";
      case BeneficiaryType.individual6:
        return "120-167MONTH";
      case BeneficiaryType.individual7:
        return "168-1800MONTH";
      case BeneficiaryType.coblister1:
        return "COBLISTER1";
      case BeneficiaryType.coblister2:
        return "COBLISTER2";
      case BeneficiaryType.ivermectin:
        return "IVERMECTIN";
      case BeneficiaryType.albendazole:
        return "ALBENDAZOLE";
      case BeneficiaryType.spaq1:
        return "SPAQ1";
      case BeneficiaryType.spaq2:
        return "SPAQ2";
      case BeneficiaryType.plaquette6:
        return "Plaquette 6";
      case BeneficiaryType.plaquette3:
        return "Plaquette 3";
      case BeneficiaryType.plaquette9:
        return "Plaquette 9";
      case BeneficiaryType.dhapq:
        return "DHAPQ";
    }
  }
}

extension BeneficiaryTypeMapperExtension on BeneficiaryType {
  dynamic toValue() {
    BeneficiaryTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<BeneficiaryType>(this);
  }
}
