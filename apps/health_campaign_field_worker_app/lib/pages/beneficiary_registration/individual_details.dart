import 'package:collection/collection.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/utils/date_utils.dart';
import 'package:digit_components/widgets/atoms/digit_checkbox.dart';
import 'package:digit_components/widgets/digit_dob_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../blocs/app_initialization/app_initialization.dart';
import '../../blocs/beneficiary_registration/beneficiary_registration.dart';
import '../../blocs/search_households/search_households.dart';
import '../../data/local_store/no_sql/schema/app_configuration.dart';
import '../../models/data_model.dart';
import '../../router/app_router.dart';
import '../../utils/environment_config.dart';
import '../../utils/i18_key_constants.dart' as i18;
import '../../utils/utils.dart';
import '../../widgets/header/back_navigation_help_header.dart';
import '../../widgets/localized.dart';
import '../../../utils/validations.dart' as validation;

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
  static const _dobKey = 'dob';
  static const _genderKey = 'gender';
  static const _mobileNumberKey = 'mobileNumber';
  static const _disabilityTypeKey = 'disabilityType';
  static const _heightKey = 'height';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BeneficiaryRegistrationBloc>();
    final router = context.router;
    final theme = Theme.of(context);

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
                  context.read<SearchHouseholdsBloc>().add(
                        SearchHouseholdsByHouseholdsEvent(
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
              header: const Column(children: [
                BackNavigationHelpHeaderWidget(),
              ]),
              footer: SizedBox(
                height: 85,
                child: DigitCard(
                  margin: const EdgeInsets.only(left: 0, right: 0, top: 10),
                  child: DigitElevatedButton(
                    onPressed: () async {
                      if (form.control(_dobKey).value == null) {
                        form.control(_dobKey).setErrors({'': true});
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

                          final boundary = context.boundary;

                          bloc.add(
                            BeneficiaryRegistrationSaveIndividualDetailsEvent(
                              model: individual,
                              isHeadOfHousehold: widget.isHeadOfHousehold,
                            ),
                          );

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
                              BeneficiaryRegistrationCreateEvent(
                                projectId: projectId,
                                userUuid: userId,
                                boundary: boundary,
                              ),
                            );
                          }
                        },
                        editIndividual: (
                          householdModel,
                          individualModel,
                          addressModel,
                          loading,
                        ) {
                          final individual = _getIndividualModel(
                            context,
                            form: form,
                            oldIndividual: individualModel,
                          );

                          bloc.add(
                            BeneficiaryRegistrationUpdateIndividualDetailsEvent(
                              addressModel: addressModel,
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
                                            .clientAuditDetails!.createdBy,
                                        createdTime: individual
                                            .clientAuditDetails!.createdTime,
                                        lastModifiedBy:
                                            context.loggedInUserUuid,
                                        lastModifiedTime:
                                            context.millisecondsSinceEpoch(),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        },
                        addMember: (
                          addressModel,
                          householdModel,
                          loading,
                        ) {
                          final individual = _getIndividualModel(
                            context,
                            form: form,
                          );

                          bloc.add(
                            BeneficiaryRegistrationAddMemberEvent(
                              beneficiaryType: context.beneficiaryType,
                              householdModel: householdModel,
                              individualModel: individual,
                              addressModel: addressModel,
                              userUuid: userId,
                              projectId: context.projectId,
                            ),
                          );
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
                  ),
                ),
              ),
              children: [
                DigitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localizations.translate(
                          i18.individualDetails.individualsDetailsLabelText,
                        ),
                        style: theme.textTheme.displayMedium,
                      ),
                      Column(
                        children: [
                          DigitTextFormField(
                            formControlName: _individualNameKey,
                            label: localizations.translate(
                              i18.individualDetails.firstNameLabelText,
                            ),
                            maxLength: 200,
                            isRequired: true,
                            validationMessages: {
                              'required': (object) => localizations.translate(
                                    i18.individualDetails
                                        .firstNameIsRequiredError,
                                  ),
                              'min3': (object) => localizations.translate(
                                    i18.individualDetails.firstNameLengthError,
                                  ),
                              'maxLength': (object) => localizations.translate(
                                    i18.individualDetails.firstNameLengthError,
                                  ),
                            },
                          ),
                          DigitTextFormField(
                            formControlName: _individualLastNameKey,
                            label: localizations.translate(
                              i18.individualDetails.lastNameLabelText,
                            ),
                            maxLength: 200,
                            isRequired: true,
                            validationMessages: {
                              'required': (object) => localizations.translate(
                                    i18.individualDetails
                                        .lastNameIsRequiredError,
                                  ),
                              'min3': (object) => localizations.translate(
                                    i18.individualDetails.lastNameLengthError,
                                  ),
                              'maxLength': (object) => localizations.translate(
                                    i18.individualDetails.lastNameLengthError,
                                  ),
                            },
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
                          DigitDobPicker(
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
                                    (age.years >= 150 && age.months > 0)) {
                                  formControl.setErrors({'': true});
                                } else {
                                  formControl.removeError('');
                                }
                              }
                            },
                          ),
                          BlocBuilder<AppInitializationBloc,
                              AppInitializationState>(
                            builder: (context, state) => state.maybeWhen(
                              orElse: () => const Offstage(),
                              initialized: (appConfiguration, _) {
                                final genderOptions =
                                    appConfiguration.genderOptions ??
                                        <GenderOptions>[];

                                return DigitDropdown<String>(
                                  label: localizations.translate(
                                    i18.individualDetails.genderLabelText,
                                  ),
                                  valueMapper: (value) =>
                                      localizations.translate(value),
                                  initialValue: genderOptions.firstOrNull?.name,
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
                                );
                              },
                            ),
                          ),
                          DigitTextFormField(
                            keyboardType: TextInputType.number,
                            formControlName: _mobileNumberKey,
                            label: localizations.translate(
                              i18.individualDetails.mobileNumberLabelText,
                            ),
                            maxLength: 11,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp("[0-9]"),
                              ),
                            ],
                            validationMessages: {
                              'mobileNumber': (object) =>
                                  localizations.translate(i18.individualDetails
                                      .mobileNumberInvalidFormatValidationMessage),
                            },
                          ),
                          DigitTextFormField(
                            keyboardType: TextInputType.number,
                            formControlName: _heightKey,
                            label: localizations.translate(
                              i18.individualDetails.heightLabelText,
                            ),
                            maxLength: 10,
                          ),
                          BlocBuilder<AppInitializationBloc,
                              AppInitializationState>(
                            builder: (context, state) {
                              if (state is! AppInitialized) {
                                return const Offstage();
                              }

                              final disabilityTypes =
                                  state.appConfiguration.disabilityTypes ??
                                      <DisabilityTypes>[];

                              return DigitReactiveDropdown<String>(
                                label: localizations.translate(
                                  i18.deliverIntervention.disabilityLabel,
                                ),
                                isRequired: true,
                                valueMapper: (value) =>
                                    localizations.translate(value),
                                initialValue: disabilityTypes.firstOrNull?.code,
                                menuItems: disabilityTypes.map((e) {
                                  return e.code;
                                }).toList(),
                                formControlName: _disabilityTypeKey,
                                validationMessages: {
                                  'required': (object) => localizations
                                      .translate(i18.common.corecommonRequired),
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
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

    final disabilityType = form.control(_disabilityTypeKey).value;

    final height = form.control(_heightKey).value;

    individual = individual.copyWith(
      name: name.copyWith(
        givenName: form.control(_individualNameKey).value,
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
          identifierId: 'DEFAULT',
          identifierType: 'DEFAULT',
        ),
      ],
      additionalFields: disabilityType != null
          ? IndividualAdditionalFields(
              version: 1,
              fields: [
                AdditionalField(
                  _disabilityTypeKey,
                  disabilityType,
                ),
                AdditionalField(
                  _heightKey,
                  height,
                ),
              ],
            )
          : null,
    );

    return individual;
  }

  FormGroup buildForm(BeneficiaryRegistrationState state) {
    final individual = state.mapOrNull<IndividualModel>(
      editIndividual: (value) {
        return value.individualModel;
      },
    );

    final searchQuery = state.mapOrNull<String>(
      create: (value) {
        return value.searchQuery;
      },
    );

    final disabilityType = individual?.additionalFields?.fields
        .firstWhereOrNull((element) => element.key == _disabilityTypeKey)
        ?.value;

    final height = individual?.additionalFields?.fields
        .firstWhereOrNull((element) => element.key == _heightKey)
        ?.value;

    return fb.group(<String, Object>{
      _individualNameKey: FormControl<String>(
        validators: [
          Validators.required,
          CustomValidator.requiredMin3,
          Validators.maxLength(validation.individual.nameMaxLength),
        ],
        value: individual?.name?.givenName ?? searchQuery?.trim(),
      ),
      _individualLastNameKey: FormControl<String>(
        validators: [
          Validators.required,
          CustomValidator.requiredMin3,
          Validators.maxLength(validation.individual.nameMaxLength),
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
      _heightKey: FormControl<String>(
        value: height,
        validators: [Validators.required],
      ),
      _mobileNumberKey:
          FormControl<String>(value: individual?.mobileNumber, validators: [
        CustomValidator.validMobileNumber,
      ]),
      _disabilityTypeKey:
          FormControl<String>(value: disabilityType, validators: [
        Validators.required,
      ]),
    });
  }
}
