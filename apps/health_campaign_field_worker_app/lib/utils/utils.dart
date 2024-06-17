library app_utils;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:digit_components/theme/digit_theme.dart';
import 'package:digit_components/utils/date_utils.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_components/widgets/digit_dialog.dart';
import 'package:digit_components/widgets/digit_sync_dialog.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formula_parser/formula_parser.dart';
import 'package:isar/isar.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:uuid/uuid.dart';

import '../blocs/app_initialization/app_initialization.dart';
import '../blocs/search_households/project_beneficiaries_downsync.dart';
import '../blocs/search_households/search_households.dart';
import '../data/local_store/app_shared_preferences.dart';
import '../data/local_store/no_sql/schema/localization.dart';
import '../data/local_store/secure_store/secure_store.dart';
import '../models/data_model.dart';
import '../models/project_type/project_type_model.dart';
import '../router/app_router.dart';
import '../widgets/progress_indicator/progress_indicator.dart';
import 'constants.dart';
import 'extensions/extensions.dart';

export 'app_exception.dart';
export 'constants.dart';
export 'extensions/extensions.dart';

String lessThanSymbol = '<';
String greaterThanSymbol = '>';

Expression<bool> buildAnd(Iterable<Expression<bool>> iterable) {
  if (iterable.isEmpty) return const Constant(true);
  final result = iterable.reduce((value, element) => value & element);

  return result.equals(true);
}

Expression<bool> buildOr(Iterable<Expression<bool>> iterable) {
  if (iterable.isEmpty) return const Constant(true);
  final result = iterable.reduce((value, element) => value | element);

  return result.equals(true);
}

class IdGen {
  static const IdGen _instance = IdGen._internal();

  static IdGen get instance => _instance;

  /// Shorthand for [instance]
  static IdGen get i => instance;

  final Uuid uuid;

  const IdGen._internal() : uuid = const Uuid();

  String get identifier => uuid.v1();
}

class CustomValidator {
  /// Validates that control's value must be `true`
  static Map<String, dynamic>? requiredMin(
    AbstractControl<dynamic> control,
  ) {
    return control.value == null ||
            control.value.toString().length >= 2 ||
            control.value.toString().trim().isEmpty
        ? null
        : {'required': true};
  }

  static Map<String, dynamic>? requiredMin3(
    AbstractControl<dynamic> control,
  ) {
    return control.value == null ||
            control.value.toString().trim().length >= 3 ||
            control.value.toString().trim().isEmpty
        ? null
        : {'min3': true};
  }

  static Map<String, dynamic>? validMobileNumber(
    AbstractControl<dynamic> control,
  ) {
    if (control.value == null || control.value.toString().isEmpty) {
      return null;
    }

    const pattern = r'[0-9]';

    if (control.value.toString().length != 11) {
      return {'mobileNumber': true};
    }

    if (RegExp(pattern).hasMatch(control.value.toString())) return null;

    return {'mobileNumber': true};
  }

  static Map<String, dynamic>? validStockCount(
    AbstractControl<dynamic> control,
  ) {
    if (control.value == null || control.value.toString().isEmpty) {
      return {'required': true};
    }

    var parsed = int.tryParse(control.value) ?? 0;
    if (parsed < 0) {
      return {'min': true};
    } else if (parsed > 10000000) {
      return {'max': true};
    }

    return null;
  }
}

setBgRunning(bool isBgRunning) async {
  final localSecureStore = LocalSecureStore.instance;
  await localSecureStore.setBackgroundService(isBgRunning);
}

performBackgroundService({
  BuildContext? context,
  required bool stopService,
  required bool isBackground,
}) async {
  final connectivityResult = await (Connectivity().checkConnectivity());

  final isOnline = connectivityResult == ConnectivityResult.wifi ||
      connectivityResult == ConnectivityResult.mobile;
  final service = FlutterBackgroundService();
  var isRunning = await service.isRunning();

  if (!stopService) {
    if (isOnline & !isRunning) {
      final isStarted = await service.startService();
      if (!isStarted) {
        await service.startService();
      }
    }
  } else {
    if (isRunning) {
      service.invoke('stopService');
    }
  }
}

String maskString(String input) {
  // Define the character to use for masking (e.g., "*")
  const maskingChar = '*';

  // Create a new string with the same length as the input string
  final maskedString =
      List<String>.generate(input.length, (index) => maskingChar).join();

  return maskedString;
}

class Coordinate {
  final double? latitude;
  final double? longitude;

  Coordinate(this.latitude, this.longitude);
}

double? calculateDistance(Coordinate? start, Coordinate? end) {
  const double earthRadius = 6371.0; // Earth's radius in kilometers

  double toRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  if (start?.latitude != null &&
      start?.longitude != null &&
      end?.latitude != null &&
      end?.longitude != null) {
    double lat1Rad = toRadians(start!.latitude!);
    double lon1Rad = toRadians(start.longitude!);
    double lat2Rad = toRadians(end!.latitude!);
    double lon2Rad = toRadians(end.longitude!);

    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    double a = pow(sin(dLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  return null;
}

Timer makePeriodicTimer(
  Duration duration,
  void Function(Timer timer) callback, {
  bool fireNow = false,
}) {
  var timer = Timer.periodic(duration, callback);
  if (fireNow) {
    callback(timer);
  }

  return timer;
}

final requestData = {
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "age": 30,
      "email": "johndoe@example.com",
      "address": {
        "street": "123 Main Street",
        "city": "New York",
        "state": "NY",
        "zipcode": "10001",
      },
      "orders": [
        {
          "id": 101,
          "product": "Widget A",
          "quantity": 2,
          "price": 10.99,
        },
        {
          "id": 102,
          "product": "Widget B",
          "quantity": 1,
          "price": 19.99,
        },
      ],
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "age": 25,
      "email": "janesmith@example.com",
      "address": {
        "street": "456 Elm Street",
        "city": "Los Angeles",
        "state": "CA",
        "zipcode": "90001",
      },
      "orders": [
        {
          "id": 201,
          "product": "Widget C",
          "quantity": 3,
          "price": 15.99,
        },
        {
          "id": 202,
          "product": "Widget D",
          "quantity": 2,
          "price": 12.99,
        },
      ],
    },
    // ... Repeat the above structure to reach approximately 100KB in size
  ],
};

/// This checks for if the active cycle is a new cycle or its the past cycle,
/// If the active cycle is same as past cycle then all validations for tracking delivery applies, else validations do not get applied
bool checkEligibilityForActiveCycle(
  int activeCycle,
  HouseholdMemberWrapper householdWrapper,
) {
  final pastCycle = (householdWrapper.tasks ?? []).isNotEmpty
      ? householdWrapper.tasks?.last.additionalFields?.fields
              .firstWhereOrNull(
                (e) => e.key == AdditionalFieldsType.cycleIndex.name,
              )
              ?.value ??
          '1'
      : '1';

  return (activeCycle == int.parse(pastCycle));
}

/*Check for if the individual falls on the valid age category*/

///  * Returns [true] if the individual is in the same cycle and is eligible for the next dose,
bool checkEligibilityForAgeAndSideEffect(
  ProjectType? projectType,
  TaskModel? tasks,
  List<SideEffectModel>? sideEffects,
  IndividualModel individual,
) {
  final ageInYears = DigitDateUtils.calculateAge(
    DigitDateUtils.getFormattedDateToDateTime(
          individual.dateOfBirth!,
        ) ??
        DateTime.now(),
  ).years;
  final ageInMonths = DigitDateUtils.calculateAge(
    DigitDateUtils.getFormattedDateToDateTime(
          individual.dateOfBirth!,
        ) ??
        DateTime.now(),
  ).months;

  int totalAgeMonths = ageInYears * 12 + ageInMonths;
  bool skipAge = [
    Status.administeredFailed.toValue(),
    Status.administeredSuccess.toValue(),
    Status.delivered.toValue(),
  ].contains(tasks?.status);
  final currentCycle = projectType?.cycles?.firstWhereOrNull(
    (e) =>
        (e.startDate!) < DateTime.now().millisecondsSinceEpoch &&
        (e.endDate!) > DateTime.now().millisecondsSinceEpoch,
    // Return null when no matching cycle is found
  );
  if (currentCycle != null &&
      currentCycle.startDate != null &&
      currentCycle.endDate != null) {
    bool recordedSideEffect = false;
    if ((tasks != null) && sideEffects != null && sideEffects.isNotEmpty) {
      final lastTaskTime =
          tasks.clientReferenceId == sideEffects.last.taskClientReferenceId
              ? tasks.clientAuditDetails?.createdTime
              : null;
      recordedSideEffect = lastTaskTime != null &&
          (lastTaskTime >= currentCycle.startDate! &&
              lastTaskTime <= currentCycle.endDate!);

      return projectType?.validMinAge != null &&
              projectType?.validMaxAge != null
          ? skipAge ||
                  (totalAgeMonths >= projectType!.validMinAge! &&
                      totalAgeMonths <= projectType.validMaxAge!)
              ? recordedSideEffect && !checkStatus([tasks], currentCycle)
                  ? false
                  : true
              : false
          : false;
    } else {
      return skipAge ||
              (totalAgeMonths >= projectType!.validMinAge! &&
                  totalAgeMonths <= projectType.validMaxAge!)
          ? true
          : false;
    }
  }

  return false;
}

Cycle? getCurrentCycle(ProjectType? projectType) {
  final currentCycle = projectType?.cycles?.firstWhereOrNull(
    (e) =>
        (e.startDate!) < DateTime.now().millisecondsSinceEpoch &&
        (e.endDate!) > DateTime.now().millisecondsSinceEpoch,
  );

  return currentCycle;
}

bool checkIfBeneficiaryRefused(
  List<TaskModel>? tasks,
) {
  final isBeneficiaryRefused = (tasks != null &&
      (tasks ?? []).isNotEmpty &&
      tasks.last.status == Status.beneficiaryRefused.toValue());

  return isBeneficiaryRefused;
}

bool checkIfBeneficiarySick(
  List<TaskModel>? tasks,
) {
  final isBeneficiarySick = (tasks != null &&
      (tasks ?? []).isNotEmpty &&
      tasks.last.status == Status.beneficiarySick.toValue());

  return isBeneficiarySick;
}

bool checkIfBeneficiaryAbsent(
  List<TaskModel>? tasks,
) {
  final isBeneficiaryAbsent = (tasks != null &&
      (tasks ?? []).isNotEmpty &&
      tasks.last.status == Status.beneficiaryAbsent.toValue());

  return isBeneficiaryAbsent;
}

bool checkIfBeneficiaryIneligible(
  List<TaskModel>? tasks,
) {
  final isBeneficiaryIneligible = (tasks != null &&
      (tasks ?? []).isNotEmpty &&
      tasks.last.status == Status.beneficiaryIneligible.toValue());

  return isBeneficiaryIneligible;
}

bool checkIfBeneficiaryReferred(
  List<TaskModel>? tasks,
) {
  final isBeneficiaryReferred = (tasks != null &&
      (tasks ?? []).isNotEmpty &&
      tasks.last.status == Status.beneficiaryReferred.toValue());

  return isBeneficiaryReferred;
}

bool checkStatus(
  List<TaskModel>? tasks,
  Cycle? currentCycle,
) {
  if (currentCycle != null &&
      currentCycle.startDate != null &&
      currentCycle.endDate != null) {
    if (tasks != null && tasks.isNotEmpty) {
      final lastTask = tasks.last;
      final lastTaskCreatedTime = lastTask.clientAuditDetails?.createdTime;
      // final lastDose = lastTask.additionalFields?.fields.where((e) => e.key = AdditionalFieldsType.doseIndex)
      if (lastTaskCreatedTime != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(lastTaskCreatedTime);
        final diff = DateTime.now().difference(date);
        final isLastCycleRunning =
            lastTaskCreatedTime >= currentCycle.startDate! &&
                lastTaskCreatedTime <= currentCycle.endDate!;

        return isLastCycleRunning
            ? lastTask.status == Status.delivered.name
                ? true
                : false
            : true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  } else {
    return false;
  }
}

bool recordedSideEffect(
  Cycle? selectedCycle,
  TaskModel? task,
  List<SideEffectModel>? sideEffects,
) {
  if (selectedCycle != null &&
      selectedCycle.startDate != null &&
      selectedCycle.endDate != null) {
    if ((task != null) && (sideEffects ?? []).isNotEmpty) {
      final lastTaskCreatedTime =
          task.clientReferenceId == sideEffects?.last.taskClientReferenceId
              ? task.clientAuditDetails?.createdTime
              : null;

      return lastTaskCreatedTime != null &&
          lastTaskCreatedTime >= selectedCycle.startDate! &&
          lastTaskCreatedTime <= selectedCycle.endDate!;
    }
  }

  return false;
}

bool allDosesDelivered(
  List<TaskModel>? tasks,
  Cycle? selectedCycle,
  List<SideEffectModel>? sideEffects,
  IndividualModel? individualModel,
) {
  if (selectedCycle == null ||
      selectedCycle.id == 0 ||
      (selectedCycle.deliveries ?? []).isEmpty) {
    return true;
  } else {
    if ((tasks ?? []).isNotEmpty) {
      final lastCycle = int.tryParse(tasks?.last.additionalFields?.fields
              .where(
                (e) => e.key == AdditionalFieldsType.cycleIndex.name,
              )
              .firstOrNull
              ?.value ??
          '');
      final lastDose = int.tryParse(tasks?.last.additionalFields?.fields
              .where(
                (e) => e.key == AdditionalFieldsType.doseIndex.name,
              )
              .firstOrNull
              ?.value ??
          '');
      if (lastDose != null &&
          lastDose == selectedCycle.deliveries?.length &&
          lastCycle != null &&
          lastCycle == selectedCycle.id &&
          tasks?.last.status != Status.delivered.name) {
        return true;
      } else if (selectedCycle.id == lastCycle &&
          tasks?.last.status == Status.delivered.name) {
        return false;
      } else if ((sideEffects ?? []).isNotEmpty) {
        return recordedSideEffect(selectedCycle, tasks?.last, sideEffects);
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}

int getDoseIndex(
  List<TaskModel>? tasks,
  Cycle? currentCycle,
) {
  if (tasks == null || tasks.isEmpty) {
    return 0;
  }

  var doseIndex = tasks.last.additionalFields!.fields
      .where(
        (element) => element.key == AdditionalFieldsType.doseIndex.toValue(),
      )
      .first
      .value;

  return doseIndex is String
      ? int.parse(doseIndex)
      : (doseIndex is int ? doseIndex : 0);
}

DoseCriteriaModel? fetchProductVariant(
  DeliveryModel? currentDelivery,
  IndividualModel? individualModel,
) {
  if (currentDelivery != null && individualModel != null) {
    final individualAge = DigitDateUtils.calculateAge(
      DigitDateUtils.getFormattedDateToDateTime(
            individualModel.dateOfBirth!,
          ) ??
          DateTime.now(),
    );
    final individualAgeInMonths =
        individualAge.years * 12 + individualAge.months;
    final filteredCriteria = currentDelivery.doseCriteria?.where((criteria) {
      final condition = criteria.condition;
      if (condition != null) {
        //{TODO: Expression package need to be parsed
        final ageRange = condition.split("<=age<");
        final minAge = int.parse(ageRange.first);
        final maxAge = int.parse(ageRange.last);

        // temp change for SMC specific use case
        if (maxAge == 120 && individualAgeInMonths > 120) {
          return true;
        }

        return individualAgeInMonths >= minAge &&
            individualAgeInMonths <= maxAge;
      }

      return false;
    }).toList();

    return (filteredCriteria ?? []).isNotEmpty ? filteredCriteria?.first : null;
  }

  return null;
}

String? getAgeConditionString(String condition) {
  String? finalCondition;
  final ageConditions =
      condition.split('and').where((element) => element.contains('age'));
  if (ageConditions.length == 2) {
    String? lessThanCondition = ageConditions.firstWhereOrNull((element) {
      return element.contains(lessThanSymbol);
    });
    String lessThanAge = lessThanCondition?.split(lessThanSymbol).last ?? '0';

    String? greaterThanCondition = ageConditions
        .firstWhereOrNull((element) => element.contains(greaterThanSymbol));

    String greaterThanAge =
        greaterThanCondition?.split(greaterThanSymbol).last ?? '0';

    finalCondition =
        '${(int.parse(greaterThanAge) / 12).round()} - ${(int.parse(lessThanAge) / 12).round()} yrs';
  } else {
    if (ageConditions.first.contains(greaterThanSymbol)) {
      String age = ageConditions.first.split(greaterThanSymbol).last;
      finalCondition = '${(int.parse(age) / 12).round()} yrs and above';
    }
  }

  return finalCondition;
}

String? getHeightConditionString(String condition) {
  String? finalCondition;
  final heightConditions =
      condition.split('and').where((element) => element.contains('height'));
  if (heightConditions.length == 2) {
    String? lessThanCondition = heightConditions
        .firstWhereOrNull((element) => element.contains(lessThanSymbol));
    String lessThan = lessThanCondition?.split(lessThanSymbol).last ?? '0';

    String? greaterThanCondition = heightConditions
        .firstWhereOrNull((element) => element.contains(greaterThanSymbol));

    String greaterThan =
        greaterThanCondition?.split(greaterThanSymbol).last ?? '0';

    finalCondition =
        '${int.parse(greaterThan) + 1} - ${int.parse(lessThan) - 1} cm';
  } else if (heightConditions.length == 1) {
    if (heightConditions.first.contains(greaterThanSymbol)) {
      int height =
          int.parse(heightConditions.first.split(greaterThanSymbol).last) + 1;
      finalCondition = '$height cm and above';
    }
  }

  return finalCondition;
}

Future<bool> getIsConnected() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }

    return false;
  } on SocketException catch (_) {
    return false;
  }
}

void showDownloadDialog(
  BuildContext context, {
  required DownloadBeneficiary model,
  required DigitProgressDialogType dialogType,
  bool isPop = true,
  StreamController<double>? downloadProgressController,
}) {
  if (isPop) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  switch (dialogType) {
    case DigitProgressDialogType.failed:
    case DigitProgressDialogType.checkFailed:
      DigitSyncDialog.show(
        context,
        type: DigitSyncDialogType.failed,
        label: model.title,
        primaryAction: DigitDialogActions(
          label: model.primaryButtonLabel ?? '',
          action: (ctx) {
            if (dialogType == DigitProgressDialogType.failed ||
                dialogType == DigitProgressDialogType.checkFailed) {
              Navigator.of(context, rootNavigator: true).pop();
              context.read<BeneficiaryDownSyncBloc>().add(
                    DownSyncGetBatchSizeEvent(
                      appConfiguration: [model.appConfiguartion!],
                      projectId: context.projectId,
                      boundaryCode: model.boundary,
                      pendingSyncCount: model.pendingSyncCount ?? 0,
                      boundaryName: model.boundaryName,
                    ),
                  );
            } else {
              Navigator.of(context, rootNavigator: true).pop();
              context.router.pop();
            }
          },
        ),
        secondaryAction: DigitDialogActions(
          label: model.secondaryButtonLabel ?? '',
          action: (ctx) {
            Navigator.of(context, rootNavigator: true).pop();
            context.router.pop();
          },
        ),
      );
    case DigitProgressDialogType.dataFound:
    case DigitProgressDialogType.pendingSync:
    case DigitProgressDialogType.insufficientStorage:
      DigitDialog.show(
        context,
        options: DigitDialogOptions(
          titleText: model.title,
          titleIcon: Icon(
            dialogType == DigitProgressDialogType.insufficientStorage
                ? Icons.warning
                : Icons.info_outline_rounded,
            color: dialogType == DigitProgressDialogType.insufficientStorage
                ? DigitTheme.instance.colorScheme.error
                : DigitTheme.instance.colorScheme.surfaceTint,
          ),
          contentText: model.content,
          primaryAction: DigitDialogActions(
            label: model.primaryButtonLabel ?? '',
            action: (ctx) {
              if (dialogType == DigitProgressDialogType.pendingSync) {
                Navigator.of(context, rootNavigator: true).pop();
                context.router.popUntilRouteWithName(HomeRoute.name);
              } else {
                if ((model.totalCount ?? 0) > 0) {
                  context.read<BeneficiaryDownSyncBloc>().add(
                        DownSyncBeneficiaryEvent(
                          projectId: context.projectId,
                          boundaryCode: model.boundary,
                          // Batch Size need to be defined based on Internet speed.
                          batchSize: model.batchSize ?? 1,
                          initialServerCount: model.totalCount ?? 0,
                          boundaryName: model.boundaryName,
                        ),
                      );
                } else {
                  Navigator.of(context, rootNavigator: true).pop();
                  context.read<BeneficiaryDownSyncBloc>().add(
                        const DownSyncResetStateEvent(),
                      );
                }
              }
            },
          ),
          secondaryAction: model.secondaryButtonLabel != null
              ? DigitDialogActions(
                  label: model.secondaryButtonLabel ?? '',
                  action: (ctx) {
                    Navigator.of(context, rootNavigator: true).pop();
                    context.router.popUntilRouteWithName(HomeRoute.name);
                  },
                )
              : null,
        ),
      );
    case DigitProgressDialogType.inProgress:
      DigitDialog.show(
        context,
        options: DigitDialogOptions(
          title: StreamBuilder<double>(
            stream: downloadProgressController?.stream,
            builder: (context, snapshot) {
              return ProgressIndicatorContainer(
                label: '',
                prefixLabel: '',
                suffixLabel:
                    '${(snapshot.data == null ? 0 : snapshot.data! * model.totalCount!.toDouble()).toInt()}/${model.suffixLabel}' ??
                        '',
                value: snapshot.data ?? 0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DigitTheme.instance.colorScheme.secondary,
                ),
                subLabel: model.title,
              );
            },
          ),
        ),
      );
    default:
      return;
  }
}

// Returns value of the Additional Field Model, by passing the key and additional Fields list as <Map<String, dynamic>>
dynamic getValueByKey(List<Map<String, dynamic>> data, String key) {
  for (var map in data) {
    if (map["key"] == key) {
      return map["value"];
    }
  }

  return null; // Key not found
}

//Function to read the localizations from ISAR,
getLocalizationString(Isar isar, String selectedLocale) async {
  List<dynamic> localizationValues = [];

  final List<LocalizationWrapper> localizationList =
      await isar.localizationWrappers
          .filter()
          .localeEqualTo(
            selectedLocale.toString(),
          )
          .findAll();
  if (localizationList.isNotEmpty) {
    localizationValues.addAll(localizationList.first.localization!);
  }

  return localizationValues;
}

getSelectedLanguage(AppInitialized state, int index) {
  if (AppSharedPreferences().getSelectedLocale == null) {
    AppSharedPreferences()
        .setSelectedLocale(state.appConfiguration.languages!.last.value);
  }
  final selectedLanguage = AppSharedPreferences().getSelectedLocale;
  final isSelected =
      state.appConfiguration.languages![index].value == selectedLanguage;

  return isSelected;
}
