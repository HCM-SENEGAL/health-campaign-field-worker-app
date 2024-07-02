import 'package:collection/collection.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/utils/date_utils.dart';
import 'package:digit_components/widgets/atoms/digit_checkbox.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_components/widgets/digit_dob_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../blocs/app_initialization/app_initialization.dart';
import '../../blocs/beneficiary_registration/beneficiary_registration.dart';
import '../../blocs/scanner/scanner.dart';
import '../../blocs/search_households/search_bloc_common_wrapper.dart';
import '../../blocs/search_households/search_households.dart';
import '../../data/local_store/no_sql/schema/app_configuration.dart';
import '../../models/data_model.dart';
import '../../router/app_router.dart';
import '../../utils/environment_config.dart';
import '../../utils/i18_key_constants.dart' as i18;
import '../../utils/utils.dart';
import '../../widgets/header/back_navigation_help_header.dart';
import '../../widgets/localized.dart';
import '../../widgets/showcase/config/showcase_constants.dart';
import '../../widgets/showcase/showcase_button.dart';

class IndividualDetailsPage extends LocalizedStatefulWidget {
  final bool isHeadOfHousehold;

  const IndividualDetailsPage({
    super.key,
    super.appLocalizations,
    this.isHeadOfHousehold = false,
  });

  @override
  State<IndividualDetailsPage> createState() => _IndividualDetailsPageState();
}

class _IndividualDetailsPageState
    extends LocalizedState<IndividualDetailsPage> {
  static const _individualNameKey = 'individualName';
  static const _individualLastNameKey = 'individualLastName';
  static const _idTypeKey = 'idType';
  static const _idNumberKey = 'idNumber';
  static const _dobKey = 'dob';
  static const _genderKey = 'gender';
  static const _mobileNumberKey = 'mobileNumber';
  bool isDuplicateTag = false;
  static const maxLength = 200;
  final clickedStatus = ValueNotifier<bool>(false);
  DateTime now = DateTime.now();
  // static const _disabilityTypeKey = 'disabilityType';
  // static const _heightKey = 'height';
  bool isHeadAgeValid = true;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BeneficiaryRegistrationBloc>();
    final router = context.router;
    final theme = Theme.of(context);
    DateTime before150Years = DateTime(now.year - 150, now.month, now.day);

    return Scaffold(
      body: ReactiveFormBuilder(
        form: () => buildForm(bloc.state),
        builder: (context, form, child) => BlocConsumer<
            BeneficiaryRegistrationBloc, BeneficiaryRegistrationState>(
          listener: (context, state) {
            state.mapOrNull(
              persisted: (value) {
                if (value.navigateToRoot) {
                  (router.parent() as StackRouter).pop();
                } else {
                  (router.parent() as StackRouter).pop();
                  context.read<SearchBlocWrapper>().searchHouseholdsBloc.add(
                        SearchHouseholdsEvent.searchByHousehold(
                          householdModel: value.householdModel,
                          projectId: context.projectId,
                          isProximityEnabled: false,
                        ),
                      );
                  router.push(BeneficiaryAcknowledgementRoute(
                    enableViewHousehold: true,
                  ));
                }
              },
            );
          },
          builder: (context, state) {
            return ScrollableContent(
              enableFixedButton: true,
              header: const Column(children: [
                BackNavigationHelpHeaderWidget(
                  showHelp: false,
                  showcaseButton: ShowcaseButton(),
                ),
              ]),
              footer: DigitCard(
                margin: const EdgeInsets.fromLTRB(0, kPadding, 0, 0),
                padding: const EdgeInsets.fromLTRB(kPadding, 0, kPadding, 0),
                child: ValueListenableBuilder(
                  valueListenable: clickedStatus,
                  builder: (context, bool isClicked, _) {
                    return DigitElevatedButton(
                      onPressed: isClicked
                          ? null
                          : () async {
                              if (form.control(_dobKey).value == null) {
                                form.control(_dobKey).setErrors({'': true});
                              }
                              if (!widget.isHeadOfHousehold &&
                                  form.control(_idTypeKey).value == null) {
                                form.control(_idTypeKey).setErrors({'': true});
                              }
                              if (!isHeadAgeValid) {
                                await DigitToast.show(
                                  context,
                                  options: DigitToastOptions(
                                    localizations.translate(i18
                                        .individualDetails.headAgeValidError),
                                    true,
                                    theme,
                                  ),
                                );

                                return;
                              }
                              final userId = context.loggedInUserUuid;
                              final projectId = context.projectId;
                              form.markAllAsTouched();
                              if (!form.valid) return;
                              FocusManager.instance.primaryFocus?.unfocus();

                              state.maybeWhen(
                                orElse: () {
                                  return;
                                },
                                create: (
                                  addressModel,
                                  householdModel,
                                  individualModel,
                                  registrationDate,
                                  searchQuery,
                                  loading,
                                  isHeadOfHousehold,
                                ) async {
                                  final individual = _getIndividualModel(
                                    context,
                                    form: form,
                                    oldIndividual: null,
                                  );

                                  final locationBloc =
                                      context.read<LocationBloc>();
                                  final locationInitialState =
                                      locationBloc.state;
                                  final initialLat =
                                      locationInitialState.latitude;
                                  final initialLng =
                                      locationInitialState.longitude;
                                  final initialAccuracy =
                                      locationInitialState.accuracy;
                                  if (addressModel != null &&
                                      (addressModel.latitude == null ||
                                          addressModel.longitude == null ||
                                          addressModel.locationAccuracy ==
                                              null)) {
                                    bloc.add(
                                      BeneficiaryRegistrationSaveAddressEvent(
                                        addressModel.copyWith(
                                          latitude: initialLat ??
                                              addressModel.locationAccuracy,
                                          longitude: initialLng ??
                                              addressModel.locationAccuracy,
                                          locationAccuracy: initialAccuracy ??
                                              addressModel.locationAccuracy,
                                        ),
                                      ),
                                    );
                                  }

                                  final boundary = context.boundary;

                                  bloc.add(
                                    BeneficiaryRegistrationSaveIndividualDetailsEvent(
                                      model: individual,
                                      isHeadOfHousehold:
                                          widget.isHeadOfHousehold,
                                    ),
                                  );
                                  final scannerBloc =
                                      context.read<ScannerBloc>();

                                  if (!widget.isHeadOfHousehold &&
                                      (scannerBloc.state.duplicate ||
                                          scannerBloc.state.qrcodes.isEmpty)) {
                                    DigitToast.show(
                                      context,
                                      options: DigitToastOptions(
                                        scannerBloc.state.duplicate
                                            ? localizations.translate(
                                                i18.deliverIntervention
                                                    .resourceAlreadyScanned,
                                              )
                                            : localizations.translate(
                                                i18.deliverIntervention
                                                    .resourceScanningMandatory,
                                              ),
                                        true,
                                        theme,
                                      ),
                                    );
                                  } else {
                                    final submit = await DigitDialog.show<bool>(
                                      context,
                                      options: DigitDialogOptions(
                                        titleText: localizations.translate(
                                          i18.deliverIntervention.dialogTitle,
                                        ),
                                        contentText: localizations.translate(
                                          i18.deliverIntervention.dialogContent,
                                        ),
                                        primaryAction: DigitDialogActions(
                                          label: localizations.translate(
                                            i18.common.coreCommonSubmit,
                                          ),
                                          action: (context) {
                                            clickedStatus.value = true;
                                            Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pop(true);
                                          },
                                        ),
                                        secondaryAction: DigitDialogActions(
                                          label: localizations.translate(
                                            i18.common.coreCommonCancel,
                                          ),
                                          action: (context) => Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pop(false),
                                        ),
                                      ),
                                    );

                                    if (submit ?? false) {
                                      if (context.mounted) {
                                        final scannerBloc =
                                            context.read<ScannerBloc>();

                                        bloc.add(
                                          BeneficiaryRegistrationCreateEvent(
                                            projectId: projectId,
                                            userUuid: userId,
                                            boundary: boundary,
                                            tag: scannerBloc
                                                    .state.qrcodes.isNotEmpty
                                                ? scannerBloc
                                                    .state.qrcodes.first
                                                : null,
                                          ),
                                        );

                                        scannerBloc.add(
                                          const ScannerEvent.handleScanner(
                                            [],
                                            [],
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                editIndividual: (
                                  householdModel,
                                  individualModel,
                                  addressModel,
                                  projectBeneficiaryModel,
                                  loading,
                                ) {
                                  final scannerBloc =
                                      context.read<ScannerBloc>();
                                  final individual = _getIndividualModel(
                                    context,
                                    form: form,
                                    oldIndividual: individualModel,
                                  );
                                  final tag =
                                      scannerBloc.state.qrcodes.isNotEmpty
                                          ? scannerBloc.state.qrcodes.first
                                          : null;

                                  if (tag != null &&
                                      tag != projectBeneficiaryModel?.tag &&
                                      !widget.isHeadOfHousehold &&
                                      (scannerBloc.state.duplicate ||
                                          scannerBloc.state.qrcodes.isEmpty)) {
                                    DigitToast.show(
                                      context,
                                      options: DigitToastOptions(
                                        scannerBloc.state.duplicate
                                            ? localizations.translate(
                                                i18.deliverIntervention
                                                    .resourceAlreadyScanned,
                                              )
                                            : localizations.translate(
                                                i18.deliverIntervention
                                                    .resourceScanningMandatory,
                                              ),
                                        true,
                                        theme,
                                      ),
                                    );
                                  } else {
                                    bloc.add(
                                      BeneficiaryRegistrationUpdateIndividualDetailsEvent(
                                        addressModel: addressModel,
                                        householdModel: householdModel,
                                        model: individual.copyWith(
                                          clientAuditDetails: (individual
                                                          .clientAuditDetails
                                                          ?.createdBy !=
                                                      null &&
                                                  individual.clientAuditDetails
                                                          ?.createdTime !=
                                                      null)
                                              ? ClientAuditDetails(
                                                  createdBy: individual
                                                      .clientAuditDetails!
                                                      .createdBy,
                                                  createdTime: individual
                                                      .clientAuditDetails!
                                                      .createdTime,
                                                  lastModifiedBy:
                                                      context.loggedInUserUuid,
                                                  lastModifiedTime: context
                                                      .millisecondsSinceEpoch(),
                                                )
                                              : null,
                                        ),
                                        tag: scannerBloc
                                                .state.qrcodes.isNotEmpty
                                            ? scannerBloc.state.qrcodes.first
                                            : null,
                                      ),
                                    );
                                  }
                                },
                                addMember: (
                                  addressModel,
                                  householdModel,
                                  loading,
                                ) async {
                                  final individual = _getIndividualModel(
                                    context,
                                    form: form,
                                  );

                                  if (context.mounted) {
                                    final scannerBloc =
                                        context.read<ScannerBloc>();

                                    if (!widget.isHeadOfHousehold &&
                                        (scannerBloc.state.duplicate ||
                                            scannerBloc
                                                .state.qrcodes.isEmpty)) {
                                      DigitToast.show(
                                        context,
                                        options: DigitToastOptions(
                                          scannerBloc.state.duplicate
                                              ? localizations.translate(
                                                  i18.deliverIntervention
                                                      .resourceAlreadyScanned,
                                                )
                                              : localizations.translate(
                                                  i18.deliverIntervention
                                                      .resourceScanningMandatory,
                                                ),
                                          true,
                                          theme,
                                        ),
                                      );
                                    } else {
                                      final submit =
                                          await DigitDialog.show<bool>(
                                        context,
                                        options: DigitDialogOptions(
                                          titleText: localizations.translate(
                                            i18.deliverIntervention.dialogTitle,
                                          ),
                                          contentText: localizations.translate(
                                            i18.deliverIntervention
                                                .dialogContent,
                                          ),
                                          primaryAction: DigitDialogActions(
                                            label: localizations.translate(
                                              i18.common.coreCommonSubmit,
                                            ),
                                            action: (context) {
                                              clickedStatus.value = true;
                                              Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).pop(true);
                                            },
                                          ),
                                          secondaryAction: DigitDialogActions(
                                            label: localizations.translate(
                                              i18.common.coreCommonCancel,
                                            ),
                                            action: (context) => Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pop(false),
                                          ),
                                        ),
                                      );

                                      if (submit ?? false) {
                                        bloc.add(
                                          BeneficiaryRegistrationAddMemberEvent(
                                            beneficiaryType:
                                                context.beneficiaryType,
                                            householdModel: householdModel,
                                            individualModel: individual,
                                            addressModel: addressModel,
                                            userUuid: userId,
                                            projectId: context.projectId,
                                            tag: scannerBloc
                                                    .state.qrcodes.isNotEmpty
                                                ? scannerBloc
                                                    .state.qrcodes.first
                                                : null,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              );
                            },
                      child: Center(
                        child: Text(
                          state.mapOrNull(
                                editIndividual: (value) => localizations
                                    .translate(i18.common.coreCommonSave),
                              ) ??
                              localizations
                                  .translate(i18.common.coreCommonSubmit),
                        ),
                      ),
                    );
                  },
                ),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: DigitCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: kPadding),
                          child: Text(
                            localizations.translate(
                              i18.individualDetails.individualsDetailsLabelText,
                            ),
                            style: theme.textTheme.displayMedium,
                          ),
                        ),
                        Column(
                          children: [
                            individualDetailsShowcaseData.nameOfIndividual
                                .buildWith(
                              child: DigitTextFormField(
                                formControlName: _individualNameKey,
                                label: localizations.translate(
                                  i18.individualDetails.firstNameLabelText,
                                ),
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.allow(RegExp(
                                //     "[a-zA-Z ]",
                                //   )),
                                // ],
                                isRequired: true,
                                maxLength: 200,
                                validationMessages: {
                                  'required': (object) =>
                                      localizations.translate(
                                        i18.individualDetails
                                            .firstNameIsRequiredError,
                                      ),
                                  'min3': (object) => localizations.translate(
                                        i18.individualDetails
                                            .firstNameLengthError,
                                      ),
                                  'maxLength': (object) => localizations
                                      .translate(i18.common.maxCharsRequired)
                                      .replaceAll('{}', maxLength.toString()),
                                },
                              ),
                            ),
                            individualDetailsShowcaseData.lastNameOfIndividual
                                .buildWith(
                              child: DigitTextFormField(
                                formControlName: _individualLastNameKey,
                                label: localizations.translate(
                                  i18.individualDetails.lastNameLabelText,
                                ),
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.allow(RegExp(
                                //     "[a-zA-Z ]",
                                //   )),
                                // ],
                                maxLength: 200,
                                isRequired: true,
                                validationMessages: {
                                  'required': (object) =>
                                      localizations.translate(
                                        i18.individualDetails
                                            .lastNameIsRequiredError,
                                      ),
                                  'min3': (object) => localizations.translate(
                                        i18.individualDetails
                                            .lastNameLengthError,
                                      ),
                                  'maxLength': (object) =>
                                      localizations.translate(
                                        i18.individualDetails
                                            .lastNameLengthError,
                                      ),
                                },
                              ),
                            ),
                            Offstage(
                              offstage: widget.isHeadOfHousehold,
                              child: BlocBuilder<AppInitializationBloc,
                                  AppInitializationState>(
                                builder: (context, state) => state.maybeWhen(
                                  orElse: () => const Offstage(),
                                  initialized: (appConfiguration, _) {
                                    final idTypeOptions =
                                        appConfiguration.idTypeOptions ??
                                            <IdTypeOptions>[];

                                    return individualDetailsShowcaseData.idType
                                        .buildWith(
                                      child:
                                          DigitReactiveSearchDropdown<String>(
                                        label: localizations.translate(
                                          i18.individualDetails.idTypeLabelText,
                                        ),
                                        form: form,
                                        menuItems: idTypeOptions.map(
                                          (e) {
                                            return e.code;
                                          },
                                        ).toList(),
                                        formControlName: _idTypeKey,
                                        valueMapper: (value) {
                                          return localizations.translate(value);
                                        },
                                        onSelected: (value) {
                                          setState(() {
                                            if (value == 'DEFAULT') {
                                              form.control(_idNumberKey).value =
                                                  IdGen.i.identifier.toString();
                                            } else {
                                              form.control(_idNumberKey).value =
                                                  null;
                                            }
                                          });
                                        },
                                        isRequired: !widget.isHeadOfHousehold,
                                        validationMessage:
                                            localizations.translate(
                                          i18.common.corecommonRequired,
                                        ),
                                        emptyText: localizations
                                            .translate(i18.common.noMatchFound),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (form.control(_idTypeKey).value != 'DEFAULT' &&
                                form.control(_idTypeKey).value != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ReactiveFormConsumer(
                                    builder: (context, formGroup, child) {
                                      return DigitTextFormField(
                                        readOnly:
                                            form.control(_idTypeKey).value ==
                                                'DEFAULT',
                                        isRequired: form
                                            .control(_idNumberKey)
                                            .validators
                                            .isNotEmpty,
                                        formControlName: _idNumberKey,
                                        label: localizations.translate(
                                          i18.individualDetails
                                              .idNumberLabelText,
                                        ),
                                        maxLength: 24,
                                        validationMessages: {
                                          'required': (object) =>
                                              localizations.translate(
                                                '${i18.individualDetails.idNumberLabelText}_IS_REQUIRED',
                                              ),
                                          'min2': (object) =>
                                              localizations.translate(
                                                i18.individualDetails
                                                    .idNumberLengthError,
                                              ),
                                          'maxLength': (object) =>
                                              localizations.translate(
                                                i18.individualDetails
                                                    .idNumberLengthError,
                                              ),
                                        },
                                        padding: const EdgeInsets.only(
                                          top: kPadding * 2,
                                          left: kPadding / 2,
                                          right: kPadding / 2,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            if (form.control(_idTypeKey).value == 'DEFAULT')
                              const SizedBox(
                                height: kPadding,
                              ),
                            Offstage(
                              offstage: !widget.isHeadOfHousehold,
                              child: DigitCheckbox(
                                label: localizations.translate(
                                  i18.individualDetails.checkboxLabelText,
                                ),
                                value: widget.isHeadOfHousehold,
                              ),
                            ),
                            individualDetailsShowcaseData.dateOfBirth.buildWith(
                              child: DigitDobPicker(
                                datePickerFormControl: _dobKey,
                                datePickerLabel: localizations.translate(
                                  i18.individualDetails.dobLabelText,
                                ),
                                ageFieldLabel: localizations.translate(
                                  i18.individualDetails.ageLabelText,
                                ),
                                yearsHintLabel: localizations.translate(
                                  i18.individualDetails.yearsHintText,
                                ),
                                monthsHintLabel: localizations.translate(
                                  i18.individualDetails.monthsHintText,
                                ),
                                separatorLabel: localizations.translate(
                                  i18.individualDetails.separatorLabelText,
                                ),
                                yearsAndMonthsErrMsg: localizations.translate(
                                  i18.individualDetails.yearsAndMonthsErrorText,
                                ),
                                initialDate: before150Years,
                                onChangeOfFormControl: (formControl) {
                                  // Handle changes to the control's value here
                                  final value = formControl.value;
                                  if (value == null) {
                                    formControl.setErrors({'': true});
                                  } else {
                                    DigitDOBAge age =
                                        DigitDateUtils.calculateAge(value);
                                    if ((age.years == 0 && age.months == 0) ||
                                        age.months > 11 ||
                                        (age.years > 150 ||
                                            (age.years == 150 &&
                                                age.months > 0))) {
                                      formControl.setErrors({'': true});
                                    } else if (widget.isHeadOfHousehold &&
                                        age.years < 18) {
                                      isHeadAgeValid = false;
                                    } else {
                                      if (widget.isHeadOfHousehold) {
                                        isHeadAgeValid = true;
                                      }
                                      formControl.removeError('');
                                    }
                                  }
                                },
                              ),
                            ),
                            BlocBuilder<AppInitializationBloc,
                                AppInitializationState>(
                              builder: (context, state) => state.maybeWhen(
                                orElse: () => const Offstage(),
                                initialized: (appConfiguration, _) {
                                  final genderOptions =
                                      appConfiguration.genderOptions ??
                                          <GenderOptions>[];

                                  return individualDetailsShowcaseData.gender
                                      .buildWith(
                                    child: DigitDropdown<String>(
                                      label: localizations.translate(
                                        i18.individualDetails.genderLabelText,
                                      ),
                                      valueMapper: (value) =>
                                          localizations.translate(value),
                                      initialValue:
                                          genderOptions.firstOrNull?.name,
                                      menuItems: genderOptions
                                          .map(
                                            (e) => e.name,
                                          )
                                          .toList(),
                                      formControlName: _genderKey,
                                      isRequired: true,
                                      validationMessages: {
                                        'required': (object) =>
                                            localizations.translate(
                                              i18.common.corecommonRequired,
                                            ),
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            Offstage(
                              offstage: !widget.isHeadOfHousehold,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  kPadding / 2,
                                  kPadding,
                                  kPadding / 2,
                                  0,
                                ),
                                child: DigitTextFormField(
                                  keyboardType: TextInputType.number,
                                  formControlName: _mobileNumberKey,
                                  label: localizations.translate(
                                    i18.individualDetails.mobileNumberLabelText,
                                  ),
                                  maxLength: 9,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]"),
                                    ),
                                  ],
                                  validationMessages: {
                                    'mobileNumber': (object) =>
                                        localizations.translate(i18
                                            .individualDetails
                                            .mobileNumberInvalidFormatValidationMessage),
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (!widget.isHeadOfHousehold)
                              BlocBuilder<ScannerBloc, ScannerState>(
                                builder: (context, state) => state
                                        .qrcodes.isNotEmpty
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            child: Text(
                                              localizations.translate(
                                                i18.deliverIntervention
                                                    .voucherCode,
                                              ),
                                              style:
                                                  theme.textTheme.headlineSmall,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              overflow: TextOverflow.ellipsis,
                                              localizations.translate(
                                                  state.qrcodes.last),
                                            ),
                                          ),
                                          IconButton(
                                            color: theme.colorScheme.secondary,
                                            icon: const Icon(Icons.qr_code),
                                            onPressed: () {
                                              context.read<ScannerBloc>().add(
                                                    const ScannerEvent
                                                        .handleScanner(
                                                      [],
                                                      [],
                                                    ),
                                                  );
                                              // TODO : [Need to handle the Scanner event];
                                              // context.read<ScannerBloc>().add(ScannerScanEvent())
                                              context.router
                                                  .push(QRScannerRoute(
                                                quantity: 1,
                                                isGS1code: false,
                                                sinlgleValue: true,
                                                isEditEnabled: true,
                                              ));
                                            },
                                          ),
                                        ],

                                        // ignore: no-empty-block
                                      )
                                    : DigitOutlineIconButton(
                                        onPressed: () {
                                          context.read<ScannerBloc>().add(
                                                const ScannerEvent
                                                    .handleScanner(
                                                  [],
                                                  [],
                                                ),
                                              );
                                          context.router.push(QRScannerRoute(
                                            quantity: 1,
                                            isGS1code: false,
                                            sinlgleValue: true,
                                          ));
                                        },
                                        icon: Icons.qr_code,
                                        label: localizations.translate(
                                          i18.individualDetails
                                              .linkVoucherToIndividual,
                                        ),
                                      ),
                              ),
                          ],
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.fromLTRB(
                        //     kPadding / 2,
                        //     0,
                        //     kPadding / 2,
                        //     0,
                        //   ),
                        //   child: DigitTextFormField(
                        //     keyboardType: TextInputType.number,
                        //     isRequired: true,
                        //     formControlName: _heightKey,
                        //     inputFormatters: [
                        //       FilteringTextInputFormatter.allow(
                        //         RegExp("[0-9]"),
                        //       ),
                        //     ],
                        //     label: localizations.translate(
                        //       i18.individualDetails.heightLabelText,
                        //     ),
                        //     maxLength: 3,
                        //     validationMessages: {
                        //       'required': (object) => localizations
                        //           .translate(i18.common.corecommonRequired),
                        //     },
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.fromLTRB(
                        //     kPadding / 2,
                        //     0,
                        //     kPadding / 2,
                        //     0,
                        //   ),
                        //   child: BlocBuilder<AppInitializationBloc,
                        //       AppInitializationState>(
                        //     builder: (context, state) {
                        //       if (state is! AppInitialized) {
                        //         return const Offstage();
                        //       }

                        //       final disabilityTypes =
                        //           state.appConfiguration.disabilityTypes ??
                        //               <DisabilityTypes>[];

                        //       return DigitReactiveDropdown<String>(
                        //         label: localizations.translate(
                        //           i18.deliverIntervention.disabilityLabel,
                        //         ),
                        //         isRequired: true,
                        //         valueMapper: (value) =>
                        //             localizations.translate(value),
                        //         initialValue: disabilityTypes.firstOrNull?.code,
                        //         menuItems: disabilityTypes.map((e) {
                        //           return e.code;
                        //         }).toList(),
                        //         formControlName: _disabilityTypeKey,
                        //         validationMessages: {
                        //           'required': (object) => localizations
                        //               .translate(i18.common.corecommonRequired),
                        //         },
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IndividualModel _getIndividualModel(
    BuildContext context, {
    required FormGroup form,
    IndividualModel? oldIndividual,
  }) {
    final dob = form.control(_dobKey).value as DateTime?;
    String? dobString;
    if (dob != null) {
      dobString = DateFormat('dd/MM/yyyy').format(dob);
    }

    var individual = oldIndividual;
    individual ??= IndividualModel(
      clientReferenceId: IdGen.i.identifier,
      tenantId: envConfig.variables.tenantId,
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: context.loggedInUserUuid,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: context.loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: context.loggedInUserUuid,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: context.loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
    );

    var name = individual.name;
    name ??= NameModel(
      individualClientReferenceId: individual.clientReferenceId,
      tenantId: envConfig.variables.tenantId,
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: context.loggedInUserUuid,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: context.loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: context.loggedInUserUuid,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: context.loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
    );

    var identifier = (individual.identifiers?.isNotEmpty ?? false)
        ? individual.identifiers!.first
        : null;

    identifier ??= IdentifierModel(
      clientReferenceId: individual.clientReferenceId,
      tenantId: envConfig.variables.tenantId,
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: context.loggedInUserUuid,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: context.loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: context.loggedInUserUuid,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: context.loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
    );

    // final disabilityType = form.control(_disabilityTypeKey).value;

    // final height = form.control(_heightKey).value as String;

    final cycleIndex =
        context.selectedCycle.id == 0 ? "" : "0${context.selectedCycle.id}";

    final projectTypeId = context.selectedProjectType == null
        ? ""
        : context.selectedProjectType!.id;

    individual = individual.copyWith(
      name: name.copyWith(
        givenName: (form.control(_individualNameKey).value as String).trim(),
        familyName:
            (form.control(_individualLastNameKey).value as String).trim(),
      ),
      gender: form.control(_genderKey).value == null
          ? null
          : Gender.values
              .byName(form.control(_genderKey).value.toString().toLowerCase()),
      mobileNumber: form.control(_mobileNumberKey).value,
      dateOfBirth: dobString,
      identifiers: [
        identifier.copyWith(
          identifierId: form.control(_idNumberKey).value ?? 'DEFAULT',
          identifierType: form.control(_idTypeKey).value ?? 'DEFAULT',
        ),
      ],
      additionalFields: IndividualAdditionalFields(
        version: 1,
        fields: [
          AdditionalField(
            "projectId",
            context.projectId,
          ),
          if (cycleIndex.isNotEmpty)
            AdditionalField(
              "cycleIndex",
              cycleIndex,
            ),
          if (projectTypeId.isNotEmpty)
            AdditionalField(
              "projectTypeId",
              projectTypeId,
            ),
        ],
      ),
    );

    return individual;
  }

  FormGroup buildForm(BeneficiaryRegistrationState state) {
    final individual = state.mapOrNull<IndividualModel>(
      editIndividual: (value) {
        if (value.projectBeneficiaryModel?.tag != null) {
          context
              .read<ScannerBloc>()
              .add(ScannerScanEvent([], [value.projectBeneficiaryModel!.tag!]));
        }

        return value.individualModel;
      },
    );

    final searchQuery = state.mapOrNull<String>(
      create: (value) {
        return value.searchQuery;
      },
    );

    // final disabilityType = individual?.additionalFields?.fields
    //     .firstWhereOrNull((element) => element.key == _disabilityTypeKey)
    //     ?.value;

    // final height = individual?.additionalFields?.fields
    //     .firstWhereOrNull((element) => element.key == _heightKey)
    //     ?.value;

    return fb.group(<String, Object>{
      _individualNameKey: FormControl<String>(
        validators: [
          Validators.required,
          CustomValidator.requiredMin3,
          Validators.maxLength(200),
        ],
        value: individual?.name?.givenName ?? searchQuery?.trim(),
      ),
      _individualLastNameKey: FormControl<String>(
        validators: [
          Validators.required,
          CustomValidator.requiredMin3,
          Validators.maxLength(200),
        ],
        value: individual?.name?.familyName ?? '',
      ),
      _dobKey: FormControl<DateTime>(
        value: individual?.dateOfBirth != null
            ? DateFormat('dd/MM/yyyy').parse(
                individual!.dateOfBirth!,
              )
            : null,
      ),
      _genderKey: FormControl<String>(
        validators: [
          Validators.required,
        ],
        value: context.read<AppInitializationBloc>().state.maybeWhen(
              orElse: () => null,
              initialized: (appConfiguration, serviceRegistryList) {
                final options =
                    appConfiguration.genderOptions ?? <GenderOptions>[];

                return options.map((e) => e.code).firstWhereOrNull(
                      (element) =>
                          element.toLowerCase() == individual?.gender?.name,
                    );
              },
            ),
      ),
      // _heightKey: FormControl<String>(
      //   value: height,
      //   validators: [Validators.required],
      // ),
      _mobileNumberKey:
          FormControl<String>(value: individual?.mobileNumber, validators: [
        CustomValidator.validMobileNumber,
      ]),
      _idTypeKey: FormControl<String>(
        value: individual?.identifiers?.firstOrNull?.identifierType,
      ),
      _idNumberKey: FormControl<String>(
        validators: widget.isHeadOfHousehold
            ? []
            : [
                Validators.required,
                CustomValidator.requiredMin2,
                Validators.maxLength(64),
              ],
        value: individual?.identifiers?.firstOrNull?.identifierId,
      ),
      // _disabilityTypeKey:
      //     FormControl<String>(value: disabilityType, validators: [
      //   Validators.required,
      // ]),
    });
  }
}
