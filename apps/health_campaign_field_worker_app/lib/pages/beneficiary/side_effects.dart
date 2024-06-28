import 'package:collection/collection.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/app_initialization/app_initialization.dart';
import '../../blocs/delivery_intervention/deliver_intervention.dart';
import '../../blocs/household_overview/household_overview.dart';
import '../../blocs/product_variant/product_variant.dart';
import '../../blocs/side_effects/side_effects.dart';
import '../../data/local_store/no_sql/schema/app_configuration.dart';
import '../../models/data_model.dart';
import '../../router/app_router.dart';
import '../../utils/environment_config.dart';
import '../../utils/i18_key_constants.dart' as i18;
import '../../utils/utils.dart';
import '../../widgets/component_wrapper/product_variant_bloc_wrapper.dart';
import '../../widgets/header/back_navigation_help_header.dart';
import '../../widgets/localized.dart';

class SideEffectsPage extends LocalizedStatefulWidget {
  final bool isEditing;
  final List<TaskModel> tasks;
  final bool fromSurvey;

  const SideEffectsPage({
    super.key,
    super.appLocalizations,
    required this.tasks,
    this.isEditing = false,
    this.fromSurvey = false,
  });

  @override
  State<SideEffectsPage> createState() => _SideEffectsPageState();
}

class _SideEffectsPageState extends LocalizedState<SideEffectsPage> {
  List<bool> symptomsValues = [];
  List<String> symptomsTypes = [];
  bool symptomsSelected = true;
  bool showOtherTextField = false;
  final TextEditingController otherController = TextEditingController();
  bool symptomsSubmitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProductVariantBlocWrapper(
      child: BlocBuilder<ProductVariantBloc, ProductVariantState>(
        builder: (context, productState) {
          return productState.maybeWhen(
            orElse: () => const Offstage(),
            fetched: (productVariants) {
              return BlocBuilder<HouseholdOverviewBloc, HouseholdOverviewState>(
                builder: (context, state) {
                  return BlocBuilder<DeliverInterventionBloc,
                      DeliverInterventionState>(
                    builder: (context, deliveryState) {
                      return WillPopScope(
                        onWillPop: () =>
                            _onBackPressed(context, widget.fromSurvey),
                        child: Scaffold(
                          body: state.loading
                              ? const Center(child: CircularProgressIndicator())
                              : ScrollableContent(
                                  header: BackNavigationHelpHeaderWidget(
                                    showHelp: false,
                                    showBackNavigation:
                                        widget.fromSurvey ? false : true,
                                  ),
                                  footer: DigitCard(
                                    margin: const EdgeInsets.fromLTRB(
                                        0, kPadding, 0, 0),
                                    padding: const EdgeInsets.fromLTRB(
                                        kPadding, 0, kPadding, 0),
                                    child: DigitElevatedButton(
                                      onPressed: symptomsSubmitted
                                          ? null
                                          : () async {
                                              if (symptomsValues
                                                  .any((e) => e)) {
                                                setState(() {
                                                  symptomsSelected = true;
                                                });

                                                if ((symptomsValues[
                                                            symptomsTypes
                                                                .indexOf(
                                                      'OTHER',
                                                    )]
                                                        ? true
                                                        : false) &&
                                                    otherController
                                                        .text.isEmpty) {
                                                  await DigitToast.show(
                                                    context,
                                                    options: DigitToastOptions(
                                                      localizations.translate(i18
                                                          .common
                                                          .coreCommonOthersRequired),
                                                      true,
                                                      theme,
                                                    ),
                                                  );

                                                  return;
                                                }

                                                final router = context.router;

                                                final shouldSubmit =
                                                    await DigitDialog.show<
                                                        bool>(
                                                  context,
                                                  options: DigitDialogOptions(
                                                    titleText:
                                                        localizations.translate(
                                                      i18.deliverIntervention
                                                          .dialogTitle,
                                                    ),
                                                    contentText:
                                                        localizations.translate(
                                                      i18.deliverIntervention
                                                          .dialogContent,
                                                    ),
                                                    primaryAction:
                                                        DigitDialogActions(
                                                      label: localizations
                                                          .translate(
                                                        i18.common
                                                            .coreCommonSubmit,
                                                      ),
                                                      action: (ctx) {
                                                        if (!symptomsSubmitted) {
                                                          symptomsSubmitted =
                                                              true;
                                                          final List<String>
                                                              symptoms = [];

                                                          for (int i = 0;
                                                              i <
                                                                  symptomsValues
                                                                      .length;
                                                              i++) {
                                                            if (symptomsValues[
                                                                i]) {
                                                              if (symptomsTypes[
                                                                      i] ==
                                                                  'OTHER') {
                                                                symptoms.add(
                                                                  otherController
                                                                      .text,
                                                                );
                                                              } else {
                                                                symptoms.add(
                                                                  symptomsTypes[
                                                                      i],
                                                                );
                                                              }
                                                            }
                                                          }

                                                          final clientReferenceId =
                                                              IdGen
                                                                  .i.identifier;
                                                          context
                                                              .read<
                                                                  SideEffectsBloc>()
                                                              .add(
                                                                SideEffectsSubmitEvent(
                                                                  SideEffectModel(
                                                                    id: null,
                                                                    taskClientReferenceId: widget
                                                                        .tasks
                                                                        .last
                                                                        .clientReferenceId,
                                                                    projectId:
                                                                        context
                                                                            .projectId,
                                                                    symptoms:
                                                                        symptoms,
                                                                    clientReferenceId:
                                                                        clientReferenceId,
                                                                    tenantId: envConfig
                                                                        .variables
                                                                        .tenantId,
                                                                    rowVersion:
                                                                        1,
                                                                    auditDetails:
                                                                        AuditDetails(
                                                                      createdBy:
                                                                          context
                                                                              .loggedInUserUuid,
                                                                      createdTime:
                                                                          context
                                                                              .millisecondsSinceEpoch(),
                                                                      lastModifiedBy:
                                                                          context
                                                                              .loggedInUserUuid,
                                                                      lastModifiedTime:
                                                                          context
                                                                              .millisecondsSinceEpoch(),
                                                                    ),
                                                                    clientAuditDetails:
                                                                        ClientAuditDetails(
                                                                      createdBy:
                                                                          context
                                                                              .loggedInUserUuid,
                                                                      createdTime:
                                                                          context
                                                                              .millisecondsSinceEpoch(),
                                                                      lastModifiedBy:
                                                                          context
                                                                              .loggedInUserUuid,
                                                                      lastModifiedTime:
                                                                          context
                                                                              .millisecondsSinceEpoch(),
                                                                    ),
                                                                  ),
                                                                  false,
                                                                ),
                                                              );
                                                          // todo verify this once , ids and all,address model is also pending here
                                                          final clientReferenceIdReferral =
                                                              IdGen
                                                                  .i.identifier;
                                                          context
                                                              .read<
                                                                  DeliverInterventionBloc>()
                                                              .add(
                                                                DeliverInterventionSubmitEvent(
                                                                  TaskModel(
                                                                    projectBeneficiaryClientReferenceId: widget
                                                                        .tasks
                                                                        .last
                                                                        .projectBeneficiaryClientReferenceId,
                                                                    clientReferenceId:
                                                                        clientReferenceIdReferral,
                                                                    tenantId: envConfig
                                                                        .variables
                                                                        .tenantId,
                                                                    rowVersion:
                                                                        1,
                                                                    auditDetails:
                                                                        AuditDetails(
                                                                      createdBy:
                                                                          context
                                                                              .loggedInUserUuid,
                                                                      createdTime:
                                                                          context
                                                                              .millisecondsSinceEpoch(),
                                                                    ),
                                                                    projectId:
                                                                        context
                                                                            .projectId,
                                                                    status: Status
                                                                        .beneficiaryReferred
                                                                        .toValue(),
                                                                    clientAuditDetails:
                                                                        ClientAuditDetails(
                                                                      createdBy:
                                                                          context
                                                                              .loggedInUserUuid,
                                                                      createdTime:
                                                                          context
                                                                              .millisecondsSinceEpoch(),
                                                                      lastModifiedBy:
                                                                          context
                                                                              .loggedInUserUuid,
                                                                      lastModifiedTime:
                                                                          context
                                                                              .millisecondsSinceEpoch(),
                                                                    ),
                                                                    additionalFields:
                                                                        TaskAdditionalFields(
                                                                      version:
                                                                          1,
                                                                      fields: [
                                                                        AdditionalField(
                                                                          'taskStatus',
                                                                          Status
                                                                              .beneficiaryReferred
                                                                              .toValue(),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  false,
                                                                  context
                                                                      .boundary,
                                                                ),
                                                              );
                                                          Navigator.of(
                                                            context,
                                                            rootNavigator: true,
                                                          ).pop(true);
                                                        }
                                                      },
                                                    ),
                                                    secondaryAction:
                                                        DigitDialogActions(
                                                      label: localizations
                                                          .translate(
                                                        i18.common
                                                            .coreCommonCancel,
                                                      ),
                                                      action: (context) =>
                                                          Navigator.of(
                                                        context,
                                                        rootNavigator: true,
                                                      ).pop(false),
                                                    ),
                                                  ),
                                                );

                                                if ((shouldSubmit ?? false) &&
                                                    context.mounted) {
                                                  final reloadState = context.read<
                                                      HouseholdOverviewBloc>();

                                                  Future.delayed(
                                                    const Duration(
                                                        milliseconds: 500),
                                                    () {
                                                      reloadState.add(
                                                        HouseholdOverviewReloadEvent(
                                                          projectId:
                                                              context.projectId,
                                                          projectBeneficiaryType:
                                                              context
                                                                  .beneficiaryType,
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      context.router.push(
                                                        HouseholdAcknowledgementRoute(
                                                          enableViewHousehold:
                                                              true,
                                                        ),
                                                      ));
                                                }
                                              } else {
                                                setState(() {
                                                  symptomsSelected = false;
                                                });
                                              }
                                            },
                                      child: Center(
                                        child: Text(
                                          localizations.translate(
                                            i18.memberCard
                                                .referBeneficiaryLabel,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: DigitCard(
                                        padding: const EdgeInsets.only(
                                          left: kPadding * 2,
                                          right: kPadding * 2,
                                          top: kPadding * 2,
                                          bottom: kPadding * 2,
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    localizations.translate(
                                                      i18.adverseEvents
                                                          .sideEffectsLabel,
                                                    ),
                                                    style: theme.textTheme
                                                        .displayMedium,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  right: kPadding * 2,
                                                  top: kPadding * 2,
                                                  bottom: kPadding * 2,
                                                ),
                                                child: Text(
                                                  '${localizations.translate(
                                                    i18.adverseEvents
                                                        .selectSymptomsLabel,
                                                  )}*',
                                                  style: theme
                                                      .textTheme.headlineSmall,
                                                ),
                                              ),
                                            ),
                                            BlocBuilder<AppInitializationBloc,
                                                AppInitializationState>(
                                              builder: (context, state) =>
                                                  state.maybeWhen(
                                                orElse: () => const Offstage(),
                                                initialized:
                                                    (appConfiguration, _) {
                                                  final symptomTypesOptions =
                                                      appConfiguration
                                                              .symptomsTypes ??
                                                          <SymptomsTypes>[];
                                                  symptomsTypes =
                                                      symptomTypesOptions
                                                          .map((e) => e.code)
                                                          .toList();

                                                  for (var _
                                                      in symptomTypesOptions) {
                                                    symptomsValues.add(false);
                                                  }

                                                  return StatefulBuilder(
                                                    builder: (
                                                      BuildContext context,
                                                      StateSetter stateSetter,
                                                    ) {
                                                      return Column(
                                                        children: [
                                                          Column(
                                                            children:
                                                                symptomTypesOptions
                                                                    .mapIndexed(
                                                                      (i, e) =>
                                                                          DigitCheckboxTile(
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                        label: localizations
                                                                            .translate(
                                                                          e.code,
                                                                        ),
                                                                        value:
                                                                            symptomsValues[i],
                                                                        onChanged:
                                                                            (value) {
                                                                          stateSetter(
                                                                            () {
                                                                              symptomsValues[i] = !symptomsValues[i];
                                                                              symptomsSelected = symptomsValues.any(
                                                                                (e) => e,
                                                                              );
                                                                              setState(() {
                                                                                showOtherTextField = symptomsValues[symptomsTypes.indexOf('OTHER')] ? true : false;
                                                                              });
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    )
                                                                    .toList(),
                                                          ),
                                                          if (showOtherTextField)
                                                            TextField(
                                                              controller:
                                                                  otherController,
                                                              maxLength: 64,
                                                            ),
                                                          Visibility(
                                                            visible:
                                                                !symptomsSelected,
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                localizations
                                                                    .translate(
                                                                  i18.common
                                                                      .coreCommonRequiredItems,
                                                                ),
                                                                style:
                                                                    TextStyle(
                                                                  color: theme
                                                                      .colorScheme
                                                                      .error,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _onBackPressed(
    BuildContext context,
    bool fromSurvey,
  ) async {
    if (!fromSurvey) {
      return true;
    }

    bool? shouldNavigateBack = await showDialog<bool>(
      context: context,
      builder: (context) => DigitDialog(
        options: DigitDialogOptions(
          titleText: localizations.translate(
            i18.adverseEvents.sideEffectsAlertTitle,
          ),
          content: Text(localizations.translate(
            i18.adverseEvents.sideEffectsAlertContent,
          )),
          primaryAction: DigitDialogActions(
            label: localizations.translate(i18.common.coreCommonOk),
            action: (ctx) {
              Navigator.of(
                context,
                rootNavigator: false,
              ).pop(false);
            },
          ),
        ),
      ),
    );

    return shouldNavigateBack ?? false;
  }
}
