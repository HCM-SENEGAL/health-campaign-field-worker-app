import 'package:freezed_annotation/freezed_annotation.dart';

part 'ineligibility_reasons_model.freezed.dart';
part 'ineligibility_reasons_model.g.dart';

@freezed
class IneligibilityReasonsWrapperModel with _$IneligibilityReasonsWrapperModel {
  const factory IneligibilityReasonsWrapperModel({
    @JsonKey(name: 'ineligibilityReasons')
    List<IneligibilityReasonType>? ineligibilityReasonsList,
  }) = _IneligibilityReasonsWrapperModel;

  factory IneligibilityReasonsWrapperModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$IneligibilityReasonsWrapperModelFromJson(json);
}

@freezed
class IneligibilityReasonsWrapperModelSMC
    with _$IneligibilityReasonsWrapperModelSMC {
  const factory IneligibilityReasonsWrapperModelSMC({
    @JsonKey(name: 'ineligibilityReasonsSmc')
    List<IneligibilityReasonType>? ineligibilityReasonsList,
  }) = _IneligibilityReasonsWrapperModelSMC;

  factory IneligibilityReasonsWrapperModelSMC.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$IneligibilityReasonsWrapperModelSMCFromJson(json);
}

@freezed
class IneligibilityReasonType with _$IneligibilityReasonType {
  const factory IneligibilityReasonType({
    required String code,
    required String name,
    required bool active,
  }) = _IneligibilityReasonType;

  factory IneligibilityReasonType.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$IneligibilityReasonTypeFromJson(json);
}
