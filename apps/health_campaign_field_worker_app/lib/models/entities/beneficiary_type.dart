// Generated using mason. Do not modify by hand
import 'package:dart_mappable/dart_mappable.dart';

part 'beneficiary_type.mapper.dart';
@MappableEnum(caseStyle: CaseStyle.upperCase)
enum BeneficiaryType {
  @MappableValue("INDIVIDUAL") individual,
  @MappableValue("HOUSEHOLD") household,
  @MappableValue("PRODUCT") product,
  @MappableValue("3-11MONTH") individual1,
  @MappableValue("12-60MONTH") individual2,
  @MappableValue("60-120MONTH") individual3,
  @MappableValue("IVERMECTIN") ivermectin,
  @MappableValue("ALBENDAZOLE") albendazole,
  ;
}