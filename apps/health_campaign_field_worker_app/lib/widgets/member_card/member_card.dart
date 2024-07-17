import 'package:digit_components/digit_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/delivery_intervention/deliver_intervention.dart';
import '../../blocs/household_overview/household_overview.dart';
import '../../blocs/localization/app_localization.dart';
import '../../models/data_model.dart';
import '../../router/app_router.dart';
import '../../utils/environment_config.dart';
import '../../utils/i18_key_constants.dart' as i18;
import '../../utils/utils.dart';
import '../action_card/action_card.dart';

class MemberCard extends StatelessWidget {
  final String name;
  final String? gender;
  final int years;
  final int months;
  final bool isHead;
  final IndividualModel individual;
  final bool isDelivered;

  final VoidCallback setAsHeadAction;
  final VoidCallback editMemberAction;
  final VoidCallback deleteMemberAction;
  final AppLocalizations localizations;
  final List<TaskModel>? tasks;
  final List<SideEffectModel>? sideEffects;
  final bool isNotEligible;
  final bool isBeneficiaryRefused;
  final bool isBeneficiaryIneligible;
  final bool isBeneficiaryReferred;
  final bool isBeneficiarySick;
  final bool isBeneficiaryAbsent;
  final String? projectBeneficiaryClientReferenceId;

  const MemberCard({
    super.key,
    required this.individual,
    required this.name,
    this.gender,
    required this.years,
    this.isHead = false,
    this.months = 0,
    required this.localizations,
    required this.isDelivered,
    required this.setAsHeadAction,
    required this.editMemberAction,
    required this.deleteMemberAction,
    this.tasks,
    this.isNotEligible = false,
    this.projectBeneficiaryClientReferenceId,
    this.isBeneficiaryRefused = false,
    this.isBeneficiaryIneligible = false,
    this.isBeneficiaryReferred = false,
    this.sideEffects,
    this.isBeneficiarySick = false,
    this.isBeneficiaryAbsent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final beneficiaryType = context.beneficiaryType;

    final router = context.router;
    const deliveryCommentKey = 'deliveryComment';
    var deliveryComment = getDeliveryComment(tasks, deliveryCommentKey);
    final successfulDelivery =
        isSuccessfulDelivery(tasks, context.selectedCycle);

    final bool lastCycleRunning =
        isLastCycleRunning(tasks, context.selectedCycle);

    final cycleIndex =
        context.selectedCycle.id == 0 ? "" : "0${context.selectedCycle.id}";

    return Container(
      decoration: BoxDecoration(
        color: DigitTheme.instance.colorScheme.background,
        border: Border.all(
          color: DigitTheme.instance.colorScheme.outline,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(4.0),
        ),
      ),
      margin: DigitTheme.instance.containerMargin,
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: kPadding, top: kPadding),
                      child: Text(
                        name,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              ), //solution customisation
              // Positioned(
              //   child: Align(
              //     alignment: Alignment.topRight,
              //     child: DigitIconButton(
              //       onPressed: () => DigitActionDialog.show(
              //         context,
              //         widget: const ActionCard(
              //           items: [
              //             // Solution customization
              //             // ActionCardModel(
              //             //   icon: Icons.person,
              //             //   label: localizations.translate(
              //             //     i18.memberCard.assignAsHouseholdhead,
              //             //   ),
              //             //   action: isHead ? null : setAsHeadAction,
              //             // ),
              //             // solution customisation
              //             // ActionCardModel(
              //             //   icon: Icons.edit,
              //             //   label: localizations.translate(
              //             //     i18.memberCard.editIndividualDetails,
              //             //   ),
              //             //   action: editMemberAction,
              //             // ),
              //             // Solution customization
              //             // ActionCardModel(
              //             //   icon: Icons.delete,
              //             //   label: localizations.translate(
              //             //     i18.memberCard.deleteIndividualActionText,
              //             //   ),
              //             //   action: isHead ? null : deleteMemberAction,
              //             // ),
              //           ],
              //         ),
              //       ),
              //       iconText: localizations.translate(
              //         i18.memberCard.editDetails,
              //       ),
              //       icon: Icons.edit,
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: DigitTheme.instance.containerMargin,
                  child: Text(
                    gender != null
                        ? localizations
                            .translate('CORE_COMMON_${gender?.toUpperCase()}')
                        : ' - ',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: Text(
                    " | $years ${localizations.translate(i18.memberCard.deliverDetailsYearText)} $months ${localizations.translate(i18.memberCard.deliverDetailsMonthsText)}",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: kPadding / 2,
            ),
            child: Offstage(
              offstage: beneficiaryType != BeneficiaryType.individual,
              child: getStatus(
                context,
                theme,
                deliveryComment,
                isHead,
              ),
            ),
          ),
          Offstage(
            offstage: beneficiaryType != BeneficiaryType.individual ||
                (isNotEligible ||
                        isBeneficiaryIneligible ||
                        isBeneficiarySick ||
                        (!successfulDelivery && deliveryComment.isNotEmpty)) &&
                    lastCycleRunning,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  isHead || isNotEligible
                      ? const Offstage()
                      : getButtonType(
                          context,
                          theme,
                          deliveryComment,
                          router,
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  isHead || isNotEligible
                      ? const Offstage()
                      : lastCycleRunning
                          ? (isNotEligible ||
                                  isBeneficiaryIneligible ||
                                  isBeneficiarySick ||
                                  (!successfulDelivery &&
                                      deliveryComment.isNotEmpty) ||
                                  (allDosesDelivered(
                                        tasks,
                                        context.selectedCycle,
                                        sideEffects,
                                        individual,
                                      ) ||
                                      !validDoseDelivery(
                                        tasks,
                                        context.selectedCycle,
                                        context.selectedProjectType,
                                      )))
                              ? const Offstage()
                              : DigitOutLineButton(
                                  label: localizations.translate(
                                    i18.memberCard.unableToDeliverLabel,
                                  ),
                                  buttonStyle: OutlinedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      width: 1.0,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    minimumSize: Size(
                                      MediaQuery.of(context).size.width / 1.15,
                                      50,
                                    ),
                                  ),
                                  onPressed: () async {
                                    await DigitActionDialog.show(
                                      context,
                                      widget: Column(
                                        children: [
                                          DigitOutLineButton(
                                            label: localizations.translate(
                                              i18.memberCard
                                                  .beneficiaryRefusedLabel,
                                            ),
                                            buttonStyle:
                                                OutlinedButton.styleFrom(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              ),
                                              backgroundColor: Colors.white,
                                              side: BorderSide(
                                                width: 1.0,
                                                color:
                                                    theme.colorScheme.secondary,
                                              ),
                                              minimumSize: Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.25,
                                                50,
                                              ),
                                            ),
                                            onPressed: (tasks != null &&
                                                        (tasks ?? [])
                                                            .where((element) =>
                                                                element
                                                                    .status ==
                                                                Status
                                                                    .beneficiaryRefused
                                                                    .toValue())
                                                            .toList()
                                                            .isNotEmpty) &&
                                                    !checkIfValidTimeForDose(
                                                      tasks,
                                                      context.selectedCycle,
                                                    )
                                                ? null
                                                : () {
                                                    Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    ).pop();
                                                    context
                                                        .read<
                                                            DeliverInterventionBloc>()
                                                        .add(
                                                          DeliverInterventionSubmitEvent(
                                                            TaskModel(
                                                              projectBeneficiaryClientReferenceId:
                                                                  projectBeneficiaryClientReferenceId,
                                                              clientReferenceId:
                                                                  IdGen.i
                                                                      .identifier,
                                                              tenantId:
                                                                  envConfig
                                                                      .variables
                                                                      .tenantId,
                                                              rowVersion: 1,
                                                              auditDetails:
                                                                  AuditDetails(
                                                                createdBy: context
                                                                    .loggedInUserUuid,
                                                                createdTime: context
                                                                    .millisecondsSinceEpoch(),
                                                              ),
                                                              projectId: context
                                                                  .projectId,
                                                              status: Status
                                                                  .beneficiaryRefused
                                                                  .toValue(),
                                                              clientAuditDetails:
                                                                  ClientAuditDetails(
                                                                createdBy: context
                                                                    .loggedInUserUuid,
                                                                createdTime: context
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
                                                                version: 1,
                                                                fields: [
                                                                  AdditionalField(
                                                                    'taskStatus',
                                                                    Status
                                                                        .beneficiaryRefused
                                                                        .toValue(),
                                                                  ),
                                                                  if (cycleIndex
                                                                      .isNotEmpty)
                                                                    AdditionalField(
                                                                      'cycleIndex',
                                                                      cycleIndex,
                                                                    ),
                                                                ],
                                                              ),
                                                              address:
                                                                  individual
                                                                      .address
                                                                      ?.first,
                                                            ),
                                                            false,
                                                            context.boundary,
                                                          ),
                                                        );
                                                    final reloadState =
                                                        context.read<
                                                            HouseholdOverviewBloc>();
                                                    Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500),
                                                      () {
                                                        reloadState.add(
                                                          HouseholdOverviewReloadEvent(
                                                            projectId: context
                                                                .projectId,
                                                            projectBeneficiaryType:
                                                                context
                                                                    .beneficiaryType,
                                                          ),
                                                        );
                                                      },
                                                    ).then(
                                                      (value) =>
                                                          context.router.push(
                                                        HouseholdAcknowledgementRoute(
                                                          enableViewHousehold:
                                                              true,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                          ),
                                          const SizedBox(
                                            height: kPadding * 2,
                                          ),
                                          DigitOutLineButton(
                                            label: localizations.translate(
                                              i18.memberCard
                                                  .beneficiarySickLabel,
                                            ),
                                            buttonStyle:
                                                OutlinedButton.styleFrom(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              ),
                                              backgroundColor: Colors.white,
                                              side: BorderSide(
                                                width: 1.0,
                                                color:
                                                    theme.colorScheme.secondary,
                                              ),
                                              minimumSize: Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.25,
                                                50,
                                              ),
                                            ),
                                            onPressed: (tasks != null &&
                                                        (tasks ?? [])
                                                            .where((element) =>
                                                                element
                                                                    .status ==
                                                                Status
                                                                    .beneficiarySick
                                                                    .toValue())
                                                            .toList()
                                                            .isNotEmpty) &&
                                                    !checkIfValidTimeForDose(
                                                      tasks,
                                                      context.selectedCycle,
                                                    )
                                                ? null
                                                : () {
                                                    Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    ).pop();
                                                    context
                                                        .read<
                                                            DeliverInterventionBloc>()
                                                        .add(
                                                          DeliverInterventionSubmitEvent(
                                                            TaskModel(
                                                              projectBeneficiaryClientReferenceId:
                                                                  projectBeneficiaryClientReferenceId,
                                                              clientReferenceId:
                                                                  IdGen.i
                                                                      .identifier,
                                                              tenantId:
                                                                  envConfig
                                                                      .variables
                                                                      .tenantId,
                                                              rowVersion: 1,
                                                              auditDetails:
                                                                  AuditDetails(
                                                                createdBy: context
                                                                    .loggedInUserUuid,
                                                                createdTime: context
                                                                    .millisecondsSinceEpoch(),
                                                              ),
                                                              projectId: context
                                                                  .projectId,
                                                              status: Status
                                                                  .beneficiarySick
                                                                  .toValue(),
                                                              clientAuditDetails:
                                                                  ClientAuditDetails(
                                                                createdBy: context
                                                                    .loggedInUserUuid,
                                                                createdTime: context
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
                                                                version: 1,
                                                                fields: [
                                                                  AdditionalField(
                                                                    'taskStatus',
                                                                    Status
                                                                        .beneficiarySick
                                                                        .toValue(),
                                                                  ),
                                                                  if (cycleIndex
                                                                      .isNotEmpty)
                                                                    AdditionalField(
                                                                      'cycleIndex',
                                                                      cycleIndex,
                                                                    ),
                                                                ],
                                                              ),
                                                              address:
                                                                  individual
                                                                      .address
                                                                      ?.first,
                                                            ),
                                                            false,
                                                            context.boundary,
                                                          ),
                                                        );
                                                    final reloadState =
                                                        context.read<
                                                            HouseholdOverviewBloc>();
                                                    Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500),
                                                      () {
                                                        reloadState.add(
                                                          HouseholdOverviewReloadEvent(
                                                            projectId: context
                                                                .projectId,
                                                            projectBeneficiaryType:
                                                                context
                                                                    .beneficiaryType,
                                                          ),
                                                        );
                                                      },
                                                    ).then(
                                                      (value) =>
                                                          context.router.push(
                                                        HouseholdAcknowledgementRoute(
                                                          enableViewHousehold:
                                                              true,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                          ),

                                          const SizedBox(
                                            height: kPadding * 2,
                                          ),
                                          DigitOutLineButton(
                                            label: localizations.translate(
                                              i18.memberCard
                                                  .beneficiaryAbsentLabel,
                                            ),
                                            buttonStyle:
                                                OutlinedButton.styleFrom(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                              ),
                                              backgroundColor: Colors.white,
                                              side: BorderSide(
                                                width: 1.0,
                                                color:
                                                    theme.colorScheme.secondary,
                                              ),
                                              minimumSize: Size(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.25,
                                                50,
                                              ),
                                            ),
                                            onPressed: (tasks != null &&
                                                        (tasks ?? [])
                                                            .where((element) =>
                                                                element
                                                                    .status ==
                                                                Status
                                                                    .beneficiaryAbsent
                                                                    .toValue())
                                                            .toList()
                                                            .isNotEmpty) &&
                                                    !checkIfValidTimeForDose(
                                                      tasks,
                                                      context.selectedCycle,
                                                    )
                                                ? null
                                                : () {
                                                    Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    ).pop();
                                                    context
                                                        .read<
                                                            DeliverInterventionBloc>()
                                                        .add(
                                                          DeliverInterventionSubmitEvent(
                                                            TaskModel(
                                                              projectBeneficiaryClientReferenceId:
                                                                  projectBeneficiaryClientReferenceId,
                                                              clientReferenceId:
                                                                  IdGen.i
                                                                      .identifier,
                                                              tenantId:
                                                                  envConfig
                                                                      .variables
                                                                      .tenantId,
                                                              rowVersion: 1,
                                                              auditDetails:
                                                                  AuditDetails(
                                                                createdBy: context
                                                                    .loggedInUserUuid,
                                                                createdTime: context
                                                                    .millisecondsSinceEpoch(),
                                                              ),
                                                              projectId: context
                                                                  .projectId,
                                                              status: Status
                                                                  .beneficiaryAbsent
                                                                  .toValue(),
                                                              clientAuditDetails:
                                                                  ClientAuditDetails(
                                                                createdBy: context
                                                                    .loggedInUserUuid,
                                                                createdTime: context
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
                                                                version: 1,
                                                                fields: [
                                                                  AdditionalField(
                                                                    'taskStatus',
                                                                    Status
                                                                        .beneficiaryAbsent
                                                                        .toValue(),
                                                                  ),
                                                                  if (cycleIndex
                                                                      .isNotEmpty)
                                                                    AdditionalField(
                                                                      'cycleIndex',
                                                                      cycleIndex,
                                                                    ),
                                                                ],
                                                              ),
                                                              address:
                                                                  individual
                                                                      .address
                                                                      ?.first,
                                                            ),
                                                            false,
                                                            context.boundary,
                                                          ),
                                                        );
                                                    final reloadState =
                                                        context.read<
                                                            HouseholdOverviewBloc>();
                                                    Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500),
                                                      () {
                                                        reloadState.add(
                                                          HouseholdOverviewReloadEvent(
                                                            projectId: context
                                                                .projectId,
                                                            projectBeneficiaryType:
                                                                context
                                                                    .beneficiaryType,
                                                          ),
                                                        );
                                                      },
                                                    ).then(
                                                      (value) =>
                                                          context.router.push(
                                                        HouseholdAcknowledgementRoute(
                                                          enableViewHousehold:
                                                              true,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                          ),

                                          //solution customisation
                                          // const SizedBox(
                                          //   height: kPadding * 2,
                                          // ),
                                          // DigitOutLineButton(
                                          //   label: localizations.translate(
                                          //     i18.memberCard.referBeneficiaryLabel,
                                          //   ),
                                          //   buttonStyle: OutlinedButton.styleFrom(
                                          //     shape: const RoundedRectangleBorder(
                                          //       borderRadius: BorderRadius.zero,
                                          //     ),
                                          //     backgroundColor: Colors.white,
                                          //     side: BorderSide(
                                          //       width: 1.0,
                                          //       color: theme.colorScheme.secondary,
                                          //     ),
                                          //     minimumSize: Size(
                                          //       MediaQuery.of(context).size.width /
                                          //           1.25,
                                          //       50,
                                          //     ),
                                          //   ),
                                          //   onPressed: () async {
                                          //     Navigator.of(
                                          //       context,
                                          //       rootNavigator: true,
                                          //     ).pop();
                                          //     await context.router.push(
                                          //       ReferBeneficiaryRoute(
                                          //         projectBeneficiaryClientRefId:
                                          //             projectBeneficiaryClientReferenceId ??
                                          //                 '',
                                          //         individual: individual,
                                          //       ),
                                          //     );
                                          //   },
                                          // ),
                                          //solution customisation
                                          // const SizedBox(
                                          //   height: kPadding * 2,
                                          // ),
                                          // DigitOutLineButton(
                                          //   label: localizations.translate(
                                          //     i18.memberCard.markIneligibleLabel,
                                          //   ),
                                          //   buttonStyle: OutlinedButton.styleFrom(
                                          //     backgroundColor: Colors.white,
                                          //     side: BorderSide(
                                          //       width: 1.0,
                                          //       color: theme.colorScheme.secondary,
                                          //     ),
                                          //     minimumSize: Size(
                                          //       MediaQuery.of(context).size.width /
                                          //           1.25,
                                          //       50,
                                          //     ),
                                          //   ),
                                          //   onPressed: tasks != null &&
                                          //           (tasks ?? [])
                                          //               .where((element) =>
                                          //                   element.status !=
                                          //                   Status.beneficiaryRefused
                                          //                       .toValue())
                                          //               .toList()
                                          //               .isNotEmpty &&
                                          //           !checkStatus(
                                          //             tasks,
                                          //             context.selectedCycle,
                                          //           )
                                          //       ? null
                                          //       : () async {
                                          //           Navigator.of(
                                          //             context,
                                          //             rootNavigator: true,
                                          //           ).pop();
                                          //           await context.router.push(
                                          //             IneligibilityReasonsRoute(
                                          //               projectBeneficiaryClientRefId:
                                          //                   projectBeneficiaryClientReferenceId ??
                                          //                       '',
                                          //               individual: individual,
                                          //             ),
                                          //           );
                                          //         },
                                          // ),
                                          // Solution customization
                                          // DigitOutLineButton(
                                          //   label: localizations.translate(
                                          //     i18.memberCard.recordAdverseEventsLabel,
                                          //   ),
                                          //   buttonStyle: OutlinedButton.styleFrom(
                                          //     shape: const RoundedRectangleBorder(
                                          //       borderRadius: BorderRadius.zero,
                                          //     ),
                                          //     backgroundColor: Colors.white,
                                          //     side: BorderSide(
                                          //       width: 1.0,
                                          //       color: tasks != null &&
                                          //               (tasks ?? []).isNotEmpty
                                          //           ? theme.colorScheme.secondary
                                          //           : theme.colorScheme.outline,
                                          //     ),
                                          //     minimumSize: Size(
                                          //       MediaQuery.of(context).size.width /
                                          //           1.25,
                                          //       50,
                                          //     ),
                                          //   ),
                                          //   onPressed: tasks != null &&
                                          //           (tasks ?? []).isNotEmpty
                                          //       ? () async {
                                          //           Navigator.of(
                                          //             context,
                                          //             rootNavigator: true,
                                          //           ).pop();
                                          //           await context.router.push(
                                          //             SideEffectsRoute(
                                          //               tasks: tasks!,
                                          //             ),
                                          //           );
                                          //         }
                                          //       : null,
                                          // ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                          : DigitOutLineButton(
                              label: localizations.translate(
                                i18.memberCard.unableToDeliverLabel,
                              ),
                              buttonStyle: OutlinedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  width: 1.0,
                                  color: theme.colorScheme.secondary,
                                ),
                                minimumSize: Size(
                                  MediaQuery.of(context).size.width / 1.15,
                                  50,
                                ),
                              ),
                              onPressed: () async {
                                await DigitActionDialog.show(
                                  context,
                                  widget: Column(
                                    children: [
                                      DigitOutLineButton(
                                        label: localizations.translate(
                                          i18.memberCard
                                              .beneficiaryRefusedLabel,
                                        ),
                                        buttonStyle: OutlinedButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            width: 1.0,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          minimumSize: Size(
                                            MediaQuery.of(context).size.width /
                                                1.25,
                                            50,
                                          ),
                                        ),
                                        onPressed: (tasks != null &&
                                                (tasks ?? [])
                                                    .where((element) =>
                                                        element.status !=
                                                        Status
                                                            .beneficiaryRefused
                                                            .toValue())
                                                    .toList()
                                                    .isNotEmpty &&
                                                !checkStatus(
                                                  tasks,
                                                  context.selectedCycle,
                                                ))
                                            ? null
                                            : () {
                                                Navigator.of(
                                                  context,
                                                  rootNavigator: true,
                                                ).pop();
                                                context
                                                    .read<
                                                        DeliverInterventionBloc>()
                                                    .add(
                                                      DeliverInterventionSubmitEvent(
                                                        TaskModel(
                                                          projectBeneficiaryClientReferenceId:
                                                              projectBeneficiaryClientReferenceId,
                                                          clientReferenceId:
                                                              IdGen
                                                                  .i.identifier,
                                                          tenantId: envConfig
                                                              .variables
                                                              .tenantId,
                                                          rowVersion: 1,
                                                          auditDetails:
                                                              AuditDetails(
                                                            createdBy: context
                                                                .loggedInUserUuid,
                                                            createdTime: context
                                                                .millisecondsSinceEpoch(),
                                                          ),
                                                          projectId:
                                                              context.projectId,
                                                          status: Status
                                                              .beneficiaryRefused
                                                              .toValue(),
                                                          clientAuditDetails:
                                                              ClientAuditDetails(
                                                            createdBy: context
                                                                .loggedInUserUuid,
                                                            createdTime: context
                                                                .millisecondsSinceEpoch(),
                                                            lastModifiedBy: context
                                                                .loggedInUserUuid,
                                                            lastModifiedTime:
                                                                context
                                                                    .millisecondsSinceEpoch(),
                                                          ),
                                                          additionalFields:
                                                              TaskAdditionalFields(
                                                            version: 1,
                                                            fields: [
                                                              AdditionalField(
                                                                'taskStatus',
                                                                Status
                                                                    .beneficiaryRefused
                                                                    .toValue(),
                                                              ),
                                                              if (cycleIndex
                                                                  .isNotEmpty)
                                                                AdditionalField(
                                                                  'cycleIndex',
                                                                  cycleIndex,
                                                                ),
                                                            ],
                                                          ),
                                                          address: individual
                                                              .address?.first,
                                                        ),
                                                        false,
                                                        context.boundary,
                                                      ),
                                                    );
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
                                                ).then(
                                                  (value) =>
                                                      context.router.push(
                                                    HouseholdAcknowledgementRoute(
                                                      enableViewHousehold: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                      ),
                                      const SizedBox(
                                        height: kPadding * 2,
                                      ),
                                      DigitOutLineButton(
                                        label: localizations.translate(
                                          i18.memberCard.beneficiarySickLabel,
                                        ),
                                        buttonStyle: OutlinedButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            width: 1.0,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          minimumSize: Size(
                                            MediaQuery.of(context).size.width /
                                                1.25,
                                            50,
                                          ),
                                        ),
                                        onPressed: (tasks != null &&
                                                (tasks ?? [])
                                                    .where((element) =>
                                                        element.status !=
                                                        Status.beneficiarySick
                                                            .toValue())
                                                    .toList()
                                                    .isNotEmpty &&
                                                !checkStatus(
                                                  tasks,
                                                  context.selectedCycle,
                                                ))
                                            ? null
                                            : () {
                                                Navigator.of(
                                                  context,
                                                  rootNavigator: true,
                                                ).pop();
                                                context
                                                    .read<
                                                        DeliverInterventionBloc>()
                                                    .add(
                                                      DeliverInterventionSubmitEvent(
                                                        TaskModel(
                                                          projectBeneficiaryClientReferenceId:
                                                              projectBeneficiaryClientReferenceId,
                                                          clientReferenceId:
                                                              IdGen
                                                                  .i.identifier,
                                                          tenantId: envConfig
                                                              .variables
                                                              .tenantId,
                                                          rowVersion: 1,
                                                          auditDetails:
                                                              AuditDetails(
                                                            createdBy: context
                                                                .loggedInUserUuid,
                                                            createdTime: context
                                                                .millisecondsSinceEpoch(),
                                                          ),
                                                          projectId:
                                                              context.projectId,
                                                          status: Status
                                                              .beneficiarySick
                                                              .toValue(),
                                                          clientAuditDetails:
                                                              ClientAuditDetails(
                                                            createdBy: context
                                                                .loggedInUserUuid,
                                                            createdTime: context
                                                                .millisecondsSinceEpoch(),
                                                            lastModifiedBy: context
                                                                .loggedInUserUuid,
                                                            lastModifiedTime:
                                                                context
                                                                    .millisecondsSinceEpoch(),
                                                          ),
                                                          additionalFields:
                                                              TaskAdditionalFields(
                                                            version: 1,
                                                            fields: [
                                                              AdditionalField(
                                                                'taskStatus',
                                                                Status
                                                                    .beneficiarySick
                                                                    .toValue(),
                                                              ),
                                                              if (cycleIndex
                                                                  .isNotEmpty)
                                                                AdditionalField(
                                                                  'cycleIndex',
                                                                  cycleIndex,
                                                                ),
                                                            ],
                                                          ),
                                                          address: individual
                                                              .address?.first,
                                                        ),
                                                        false,
                                                        context.boundary,
                                                      ),
                                                    );
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
                                                ).then(
                                                  (value) =>
                                                      context.router.push(
                                                    HouseholdAcknowledgementRoute(
                                                      enableViewHousehold: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                      ),

                                      const SizedBox(
                                        height: kPadding * 2,
                                      ),
                                      DigitOutLineButton(
                                        label: localizations.translate(
                                          i18.memberCard.beneficiaryAbsentLabel,
                                        ),
                                        buttonStyle: OutlinedButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            width: 1.0,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          minimumSize: Size(
                                            MediaQuery.of(context).size.width /
                                                1.25,
                                            50,
                                          ),
                                        ),
                                        onPressed: (tasks != null &&
                                                (tasks ?? [])
                                                    .where((element) =>
                                                        element.status !=
                                                        Status.beneficiaryAbsent
                                                            .toValue())
                                                    .toList()
                                                    .isNotEmpty &&
                                                !checkStatus(
                                                  tasks,
                                                  context.selectedCycle,
                                                ))
                                            ? null
                                            : () {
                                                Navigator.of(
                                                  context,
                                                  rootNavigator: true,
                                                ).pop();
                                                context
                                                    .read<
                                                        DeliverInterventionBloc>()
                                                    .add(
                                                      DeliverInterventionSubmitEvent(
                                                        TaskModel(
                                                          projectBeneficiaryClientReferenceId:
                                                              projectBeneficiaryClientReferenceId,
                                                          clientReferenceId:
                                                              IdGen
                                                                  .i.identifier,
                                                          tenantId: envConfig
                                                              .variables
                                                              .tenantId,
                                                          rowVersion: 1,
                                                          auditDetails:
                                                              AuditDetails(
                                                            createdBy: context
                                                                .loggedInUserUuid,
                                                            createdTime: context
                                                                .millisecondsSinceEpoch(),
                                                          ),
                                                          projectId:
                                                              context.projectId,
                                                          status: Status
                                                              .beneficiaryAbsent
                                                              .toValue(),
                                                          clientAuditDetails:
                                                              ClientAuditDetails(
                                                            createdBy: context
                                                                .loggedInUserUuid,
                                                            createdTime: context
                                                                .millisecondsSinceEpoch(),
                                                            lastModifiedBy: context
                                                                .loggedInUserUuid,
                                                            lastModifiedTime:
                                                                context
                                                                    .millisecondsSinceEpoch(),
                                                          ),
                                                          additionalFields:
                                                              TaskAdditionalFields(
                                                            version: 1,
                                                            fields: [
                                                              AdditionalField(
                                                                'taskStatus',
                                                                Status
                                                                    .beneficiaryAbsent
                                                                    .toValue(),
                                                              ),
                                                              if (cycleIndex
                                                                  .isNotEmpty)
                                                                AdditionalField(
                                                                  'cycleIndex',
                                                                  cycleIndex,
                                                                ),
                                                            ],
                                                          ),
                                                          address: individual
                                                              .address?.first,
                                                        ),
                                                        false,
                                                        context.boundary,
                                                      ),
                                                    );
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
                                                ).then(
                                                  (value) =>
                                                      context.router.push(
                                                    HouseholdAcknowledgementRoute(
                                                      enableViewHousehold: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                      ),

                                      //solution customisation
                                      // const SizedBox(
                                      //   height: kPadding * 2,
                                      // ),
                                      // DigitOutLineButton(
                                      //   label: localizations.translate(
                                      //     i18.memberCard.referBeneficiaryLabel,
                                      //   ),
                                      //   buttonStyle: OutlinedButton.styleFrom(
                                      //     shape: const RoundedRectangleBorder(
                                      //       borderRadius: BorderRadius.zero,
                                      //     ),
                                      //     backgroundColor: Colors.white,
                                      //     side: BorderSide(
                                      //       width: 1.0,
                                      //       color: theme.colorScheme.secondary,
                                      //     ),
                                      //     minimumSize: Size(
                                      //       MediaQuery.of(context).size.width /
                                      //           1.25,
                                      //       50,
                                      //     ),
                                      //   ),
                                      //   onPressed: () async {
                                      //     Navigator.of(
                                      //       context,
                                      //       rootNavigator: true,
                                      //     ).pop();
                                      //     await context.router.push(
                                      //       ReferBeneficiaryRoute(
                                      //         projectBeneficiaryClientRefId:
                                      //             projectBeneficiaryClientReferenceId ??
                                      //                 '',
                                      //         individual: individual,
                                      //       ),
                                      //     );
                                      //   },
                                      // ),
                                      //solution customisation
                                      // const SizedBox(
                                      //   height: kPadding * 2,
                                      // ),
                                      // DigitOutLineButton(
                                      //   label: localizations.translate(
                                      //     i18.memberCard.markIneligibleLabel,
                                      //   ),
                                      //   buttonStyle: OutlinedButton.styleFrom(
                                      //     backgroundColor: Colors.white,
                                      //     side: BorderSide(
                                      //       width: 1.0,
                                      //       color: theme.colorScheme.secondary,
                                      //     ),
                                      //     minimumSize: Size(
                                      //       MediaQuery.of(context).size.width /
                                      //           1.25,
                                      //       50,
                                      //     ),
                                      //   ),
                                      //   onPressed: tasks != null &&
                                      //           (tasks ?? [])
                                      //               .where((element) =>
                                      //                   element.status !=
                                      //                   Status.beneficiaryRefused
                                      //                       .toValue())
                                      //               .toList()
                                      //               .isNotEmpty &&
                                      //           !checkStatus(
                                      //             tasks,
                                      //             context.selectedCycle,
                                      //           )
                                      //       ? null
                                      //       : () async {
                                      //           Navigator.of(
                                      //             context,
                                      //             rootNavigator: true,
                                      //           ).pop();
                                      //           await context.router.push(
                                      //             IneligibilityReasonsRoute(
                                      //               projectBeneficiaryClientRefId:
                                      //                   projectBeneficiaryClientReferenceId ??
                                      //                       '',
                                      //               individual: individual,
                                      //             ),
                                      //           );
                                      //         },
                                      // ),
                                      // Solution customization
                                      // DigitOutLineButton(
                                      //   label: localizations.translate(
                                      //     i18.memberCard.recordAdverseEventsLabel,
                                      //   ),
                                      //   buttonStyle: OutlinedButton.styleFrom(
                                      //     shape: const RoundedRectangleBorder(
                                      //       borderRadius: BorderRadius.zero,
                                      //     ),
                                      //     backgroundColor: Colors.white,
                                      //     side: BorderSide(
                                      //       width: 1.0,
                                      //       color: tasks != null &&
                                      //               (tasks ?? []).isNotEmpty
                                      //           ? theme.colorScheme.secondary
                                      //           : theme.colorScheme.outline,
                                      //     ),
                                      //     minimumSize: Size(
                                      //       MediaQuery.of(context).size.width /
                                      //           1.25,
                                      //       50,
                                      //     ),
                                      //   ),
                                      //   onPressed: tasks != null &&
                                      //           (tasks ?? []).isNotEmpty
                                      //       ? () async {
                                      //           Navigator.of(
                                      //             context,
                                      //             rootNavigator: true,
                                      //           ).pop();
                                      //           await context.router.push(
                                      //             SideEffectsRoute(
                                      //               tasks: tasks!,
                                      //             ),
                                      //           );
                                      //         }
                                      //       : null,
                                      // ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getDeliveryComment(
    List<TaskModel>? tasks,
    String deliveryCommentKey,
  ) {
    if (tasks == null || tasks.isEmpty) {
      return "";
    }

    return tasks.last.additionalFields == null ||
            tasks.last.additionalFields!.fields
                .where((element) => element.key == deliveryCommentKey)
                .isEmpty
        ? ""
        : tasks.last.additionalFields!.fields
            .where((element) => element.key == deliveryCommentKey)
            .first
            .value;
  }

  dynamic getButtonType(
    BuildContext context,
    ThemeData theme,
    String deliveryComment,
    StackRouter router,
  ) {
    final bool successfulDelivery =
        isSuccessfulDelivery(tasks, context.selectedCycle);

    final bool validDelivery = validDoseDelivery(
      tasks,
      context.selectedCycle,
      context.selectedProjectType,
    );

    final lastCycleRunning = isLastCycleRunning(tasks, context.selectedCycle);
    final allDoseDelivered = allDosesDelivered(
      tasks,
      context.selectedCycle,
      sideEffects,
      individual,
    );

    return lastCycleRunning
        ? allDoseDelivered
            ? DigitElevatedButton(
                // padding: const EdgeInsets.only(
                //   left: kPadding / 2,
                //   right: kPadding / 2,
                // ),
                onPressed: () {
                  final bloc = context.read<HouseholdOverviewBloc>();

                  bloc.add(
                    HouseholdOverviewEvent.selectedIndividual(
                      individualModel: individual,
                    ),
                  );
                  bloc.add(HouseholdOverviewReloadEvent(
                    projectId: context.projectId,
                    projectBeneficiaryType: context.beneficiaryType,
                  ));

                  final futureTaskList = tasks
                      ?.where(
                          (task) => task.status == Status.delivered.toValue())
                      .toList();

                  if ((futureTaskList ?? []).isNotEmpty) {
                    context.router.push(
                      RecordPastDeliveryDetailsRoute(
                        tasks: tasks,
                      ),
                    );
                  } else {
                    context.router.push(BeneficiaryDetailsRoute());
                  }
                },
                child: Center(
                  child: Text(
                    localizations.translate(
                      i18.householdOverView.viewDeliveryLabel,
                    ),
                  ),
                ),
              )
            : isNotEligible ||
                    isBeneficiaryIneligible ||
                    isBeneficiarySick ||
                    (!successfulDelivery &&
                        deliveryComment.isNotEmpty &&
                        lastCycleRunning) ||
                    (!validDelivery)
                // todo verify this
                ? const Offstage()
                : (!successfulDelivery && deliveryComment.isEmpty) ||
                        ((!isBeneficiaryAbsent || !isBeneficiaryRefused) &&
                            validDelivery)
                    ? getElevatedButton(context, theme, deliveryComment, router)
                    : const Offstage()
        : getElevatedButton(context, theme, deliveryComment, router);
  }

  Widget getElevatedButton(
    BuildContext context,
    ThemeData theme,
    String deliveryComment,
    StackRouter router,
  ) {
    final allDoseDelivered = allDosesDelivered(
      tasks,
      context.selectedCycle,
      sideEffects,
      individual,
    );

    final validDoseIndex = getValidDoseIndex(tasks, context.selectedCycle);
    final isReferred = checkIfBeneficiaryReferred(tasks);

    return DigitElevatedButton(
      // padding: const EdgeInsets.only(
      //   left: kPadding / 2,
      //   right: kPadding / 2,
      // ),
      onPressed: () {
        if (validDoseIndex > 0 &&
            tasks != null &&
            tasks!.isNotEmpty &&
            !isReferred) {
          DigitDialog.show<bool>(
            context,
            options: DigitDialogOptions(
              titleText: localizations
                  .translate(i18
                      .deliverIntervention.didYouObservePreviousAdvEventsTitle)
                  .replaceAll(
                    '{}',
                    // todo verify this condition
                    validDoseIndex.toString(),
                  ),
              barrierDismissible: true,
              enableRecordPast: true,
              dialogPadding: const EdgeInsets.fromLTRB(
                kPadding,
                kPadding,
                kPadding,
                0,
              ),
              primaryAction: DigitDialogActions(
                label: localizations.translate(
                  i18.common.coreCommonNo,
                ),
                action: (ctx) {
                  Navigator.pop(ctx);

                  final bloc = context.read<HouseholdOverviewBloc>();

                  bloc.add(
                    HouseholdOverviewEvent.selectedIndividual(
                      individualModel: individual,
                    ),
                  );
                  bloc.add(HouseholdOverviewReloadEvent(
                    projectId: context.projectId,
                    projectBeneficiaryType: context.beneficiaryType,
                  ));

                  final futureTaskList = tasks
                      ?.where(
                          (task) => task.status == Status.delivered.toValue())
                      .toList();

                  if ((futureTaskList ?? []).isNotEmpty) {
                    context.router.push(
                      RecordPastDeliveryDetailsRoute(
                        tasks: tasks,
                      ),
                    );
                  } else {
                    context.router.push(BeneficiaryDetailsRoute());
                  }
                },
              ),
              secondaryAction: DigitDialogActions(
                label: localizations.translate(
                  i18.common.coreCommonYes,
                ),
                action: (ctx) async {
                  Navigator.pop(
                    ctx,
                  );
                  final reloadState = context.read<HouseholdOverviewBloc>();
                  final address = individual.address == null
                      ? tasks!.first.address
                      : individual.address!.first;
                  final response = await router.push(
                    SideEffectsRoute(
                      tasks: [
                        (tasks)!.last,
                      ],
                      fromSurvey: false,
                      address: address,
                      projectBeneficiaryClientRefId:
                          projectBeneficiaryClientReferenceId ?? "",
                    ),
                  );

                  // if (response == null) {
                  //   Future.delayed(
                  //     const Duration(
                  //       milliseconds: 1000,
                  //     ),
                  //     () {
                  //       reloadState.add(
                  //         HouseholdOverviewReloadEvent(
                  //           projectId: context.projectId,
                  //           projectBeneficiaryType: context.beneficiaryType,
                  //         ),
                  //       );
                  //     },
                  //   ).then(
                  //     (value) {
                  //       context.router.popAndPush(
                  //         HouseholdAcknowledgementRoute(
                  //           enableViewHousehold: true,
                  //         ),
                  //       );
                  //       Navigator.pop(ctx);
                  //     },
                  //   );
                  // }
                },
              ),
            ),
          );
        } else {
          final bloc = context.read<HouseholdOverviewBloc>();

          bloc.add(
            HouseholdOverviewEvent.selectedIndividual(
              individualModel: individual,
            ),
          );
          bloc.add(HouseholdOverviewReloadEvent(
            projectId: context.projectId,
            projectBeneficiaryType: context.beneficiaryType,
          ));

          final futureTaskList = tasks
              ?.where((task) => task.status == Status.delivered.toValue())
              .toList();

          if ((futureTaskList ?? []).isNotEmpty) {
            context.router.push(
              RecordPastDeliveryDetailsRoute(
                tasks: tasks,
              ),
            );
          } else {
            context.router.push(BeneficiaryDetailsRoute());
          }
        }
      },
      child: Center(
        child: Text(
          allDoseDelivered
              ? localizations.translate(
                  i18.householdOverView.viewDeliveryLabel,
                )
              : localizations.translate(
                  i18.householdOverView.householdOverViewActionText,
                ),
        ),
      ),
    );
  }

  Widget getStatus(
    BuildContext context,
    ThemeData theme,
    String deliveryComment,
    bool isHead,
  ) {
    final bool dosesDelivered = allDosesDelivered(
      tasks,
      context.selectedCycle,
      sideEffects,
      individual,
    );
    final int doseIndex = getDoseIndex(tasks, context.selectedCycle);
    final bool validDelivery = validDoseDelivery(
      tasks,
      context.selectedCycle,
      context.selectedProjectType,
    );

    final bool successfulDelivery =
        isSuccessfulDelivery(tasks, context.selectedCycle);

    final bool lastCycleRunning =
        isLastCycleRunning(tasks, context.selectedCycle);

    IconData icon;
    String iconText;
    Color iconTextColor = theme.colorScheme.error;
    Color iconColor = theme.colorScheme.error;

    // TODO ceck with amit once
    if (isHead) {
      icon = Icons.info;
      iconText = i18.householdOverView.householdOverViewHouseholderHeadLabel;
      iconTextColor = theme.colorScheme.surfaceTint;
      iconColor = theme.colorScheme.surfaceTint;
    } else {
      if (lastCycleRunning) {
        if (dosesDelivered) {
          if (!isDelivered ||
              isNotEligible ||
              isBeneficiaryRefused ||
              isBeneficiaryIneligible ||
              isBeneficiarySick ||
              isBeneficiaryAbsent ||
              isBeneficiaryReferred) {
            icon = Icons.info_rounded;
            iconText = (isNotEligible || isBeneficiaryIneligible)
                ? i18.householdOverView.householdOverViewNotEligibleIconLabel
                : isBeneficiaryReferred
                    ? i18.householdOverView
                        .householdOverViewBeneficiaryReferredLabel
                    : isBeneficiaryRefused
                        ? Status.beneficiaryRefused.toValue()
                        : isBeneficiarySick
                            ? Status.beneficiarySick.toValue()
                            : isBeneficiaryAbsent
                                ? Status.beneficiaryAbsent.toValue()
                                : i18.householdOverView
                                    .householdOverViewNotDeliveredIconLabel;
          } else if (!successfulDelivery && deliveryComment.isNotEmpty) {
            icon = Icons.info_rounded;
            iconText = deliveryComment;
          } else {
            icon = Icons.check_circle;
            iconText =
                i18.householdOverView.householdOverViewDeliveredIconLabel;
            iconTextColor = DigitTheme.instance.colorScheme.onSurfaceVariant;
            iconColor = DigitTheme.instance.colorScheme.onSurfaceVariant;
          }
        } else if (isNotEligible ||
            isBeneficiaryIneligible ||
            isBeneficiaryReferred ||
            isBeneficiaryRefused ||
            isBeneficiarySick ||
            isBeneficiaryAbsent ||
            (!successfulDelivery && deliveryComment.isNotEmpty)) {
          icon = Icons.info_rounded;
          iconText = (isNotEligible || isBeneficiaryIneligible)
              ? i18.householdOverView.householdOverViewNotEligibleIconLabel
              : !successfulDelivery && deliveryComment.isNotEmpty
                  ? deliveryComment
                  : isBeneficiaryReferred
                      ? i18.householdOverView
                          .householdOverViewBeneficiaryReferredLabel
                      : isBeneficiaryRefused &&
                              !checkIfValidTimeForDose(
                                tasks,
                                context.selectedCycle,
                              )
                          ? Status.beneficiaryRefused.toValue()
                          : isBeneficiarySick
                              ? Status.beneficiarySick.toValue()
                              : isBeneficiaryAbsent &&
                                      !checkIfValidTimeForDose(
                                        tasks,
                                        context.selectedCycle,
                                      )
                                  ? Status.beneficiaryAbsent.toValue()
                                  : i18.householdOverView
                                      .householdOverViewNotDeliveredIconLabel;
        } else if (doseIndex == 0 || validDelivery) {
          icon = Icons.info_rounded;
          iconText = Status.notAdministered.toValue();
        } else {
          icon = Icons.check_circle;
          iconText = Status.administered.toValue();
          iconTextColor = DigitTheme.instance.colorScheme.onSurfaceVariant;
          iconColor = DigitTheme.instance.colorScheme.onSurfaceVariant;
        }
      } else {
        if (isNotEligible || isBeneficiaryIneligible) {
          icon = Icons.info_rounded;
          iconText =
              i18.householdOverView.householdOverViewNotEligibleIconLabel;
        } else {
          icon = Icons.info_rounded;
          iconText = Status.notAdministered.toValue();
        }
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: DigitIconButton(
        icon: icon,
        iconSize: 20,
        iconText: localizations.translate(iconText),
        iconTextColor: iconTextColor,
        iconColor: iconColor,
      ),
    );
  }
}
