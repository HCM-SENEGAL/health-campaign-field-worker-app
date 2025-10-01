// import 'package:auto_route/auto_route.dart';
// import 'package:digit_ui_components/digit_components.dart';
// import 'package:digit_ui_components/theme/digit_extended_theme.dart';
// import 'package:digit_ui_components/utils/date_utils.dart';
// import 'package:digit_ui_components/widgets/atoms/label_value_list.dart';
// import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
// import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
// import 'package:digit_ui_components/widgets/molecules/label_value_summary.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:registration_delivery/models/entities/additional_fields_type.dart';
// // import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
// // import 'package:registration_delivery/widgets/back_navigation_help_header.dart';
// // import 'package:registration_delivery/widgets/showcase/showcase_button.dart';

// // import 'package:registration_delivery/widgets/localized.dart';
// import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
// // import 'package:registration_delivery/blocs/search_households/search_bloc_common_wrapper.dart';
// // import 'package:registration_delivery/blocs/search_households/search_households.dart';
// // import 'package:registration_delivery/utils/constants.dart';
// // import 'package:registration_delivery/utils/utils.dart';

// // import '../../blocs/registration_delivery/custom_beneficairy_registration.dart';
// // import '../../blocs/registration_delivery/custom_search_household.dart';
// import '../../router/app_router.dart';
// // import 'custom_beneficiary_acknowledgement.dart';

import 'package:digit_components/utils/date_utils.dart';
import '../../blocs/search_households/search_households.dart';
import '../../blocs/beneficiary_registration/beneficiary_registration.dart';
import '../../blocs/scanner/scanner.dart';
import 'package:digit_components/digit_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/search_households/search_bloc_common_wrapper.dart';
import '../../models/entities/individual.dart';
import '../../router/app_router.dart';
import '../../utils/utils.dart';
import '../../widgets/beneficiary/label_value_item.dart';
import '../../widgets/beneficiary/label_value_summary.dart';
import '../../widgets/header/back_navigation_help_header.dart';
import '../../widgets/localized.dart';
import '../../utils/i18_key_constants.dart' as i18;

class SummaryPage extends LocalizedStatefulWidget {
  final dynamic name;
  final IndividualModel? individualModel;
  const SummaryPage({
    super.key,
    super.appLocalizations,
    required this.name,
    this.individualModel,
  });

  @override
  State<SummaryPage> createState() => SummaryPageState();
}

class SummaryPageState extends LocalizedState<SummaryPage> {
  final clickedStatus = ValueNotifier<bool>(false);

  String getLocalizedMessage(String code) {
    return localizations.translate(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return PopScope(
      onPopInvoked: (val) {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: BlocConsumer<BeneficiaryRegistrationBloc,
            BeneficiaryRegistrationState>(
          listener: (context, state) {
            state.mapOrNull(
              persisted: (persistedState) {
                if (persistedState.navigateToRoot) {
                  (context.router.parent() as StackRouter).pop();
                } else {
                  (context.router.parent() as StackRouter).pop();
                  context.router.popUntil((route) =>
                      route.settings.name == SearchBeneficiaryRoute.name);
                  context.read<SearchBlocWrapper>().searchHouseholdsBloc.add(
                        SearchHouseholdsEvent.searchByHousehold(
                          householdModel: persistedState.householdModel,
                          projectId: context.projectId,
                          isProximityEnabled: false,
                        ),
                      );
                  context.router.push(BeneficiaryAcknowledgementRoute(
                    enableViewHousehold: true,
                  ));
                }
              },
            );
          },
          builder: (context, householdState) {
            return ScrollableContent(
              enableFixedDigitButton: true,
              header: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BackNavigationHelpHeaderWidget(
                    showHelp: false,
                    showBackNavigation: true,
                    handleback: () {
                      context.router.pop();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.translate(
                        i18.common.coreCommonSummaryDetails,
                      ),
                      style: textTheme.headlineLarge!
                          .copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
              ]),
              footer: DigitCard(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                child: ValueListenableBuilder(
                  valueListenable: clickedStatus,
                  builder: (ctx, bool isClicked, _) {
                    return DigitElevatedButton(
                      child: Center(
                        child: Text(
                          householdState.mapOrNull(
                                editIndividual: (value) =>
                                    localizations.translate(
                                  i18.common.coreCommonSave,
                                ),
                              ) ??
                              localizations.translate(
                                i18.common.coreCommonSubmit,
                              ),
                        ),
                      ),
                      onPressed: () async {
                        householdState.maybeWhen(
                          orElse: () {
                            return;
                          },
                          create: (addressModel,
                              householdModel,
                              individualModel,
                              registrationDate,
                              searchQuery,
                              loading,
                              isHeadOfHousehold) async {
                            // persisted: (navigateToRoot, householdModel) async {
                            final submit = await DigitDialog.show<bool>(
                              context,
                              options: DigitDialogOptions(
                                titleText: localizations.translate(
                                  i18.deliverIntervention.dialogTitle,
                                ),
                                content: RichText(
                                  text: TextSpan(
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: localizations.translate(
                                          i18.deliverIntervention
                                              .dialogContentPartOne,
                                        ),
                                      ),
                                      const TextSpan(text: ' '),
                                      TextSpan(
                                        text: localizations.translate(
                                          i18.deliverIntervention
                                              .dialogContentPartTwo,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                      const TextSpan(text: ' '),
                                      TextSpan(
                                        text: localizations.translate(
                                          i18.deliverIntervention
                                              .dialogContentPartThree,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                primaryAction: DigitDialogActions(
                                  label: localizations.translate(
                                    i18.common.coreCommonSubmit,
                                  ),
                                  action: (context) async {
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
                                final scannerBloc = context.read<ScannerBloc>();
                                final bloc =
                                    context.read<BeneficiaryRegistrationBloc>();
                                bloc.add(
                                  BeneficiaryRegistrationCreateEvent(
                                    projectId: context.projectId,
                                    userUuid: context.loggedInUserUuid,
                                    boundary: context.boundary,
                                    tag: scannerBloc.state.qrcodes.isNotEmpty
                                        ? scannerBloc.state.qrcodes.first
                                        : null,
                                  ),
                                );
                                scannerBloc.add(
                                  const ScannerEvent.handleScanner(
                                    [],
                                    [],
                                  ),
                                );
                                // router.popUntil((route) =>
                                //     route.settings.name ==
                                //     SearchBeneficiaryRoute.name);
                                // context
                                //     .read<SearchBlocWrapper>()
                                //     .searchHouseholdsBloc
                                //     .add(
                                //       SearchHouseholdsEvent.searchByHousehold(
                                //         householdModel: householdModel!,
                                //         projectId: context.projectId,
                                //         isProximityEnabled: false,
                                //       ),
                                //     );
                                // final searchbloc = context.read<SearchBlocWrapper>();
                                // context.router.push(
                                //   BeneficiaryAcknowledgementRoute(
                                //     enableViewHousehold: true,
                                //     name: widget.name,
                                //   ),
                                // );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      DigitCard(
                        margin: const EdgeInsets.all(8),
                        child: LabelValueSummary(
                          padding: EdgeInsets.zero,
                          heading: localizations.translate(
                            i18.householdLocation.householdLocationLabelText,
                          ),
                          headingStyle: textTheme.headlineLarge!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          items: [
                            LabelValueItem(
                              label: localizations.translate(
                                i18.householdLocation
                                    .administrationAreaFormLabel,
                              ),
                              value: localizations.translate(
                                context.boundary.name ??
                                    i18.common.coreCommonNA,
                              ),
                              isInline: true,
                              labelFlex: 5,
                              padding: const EdgeInsets.only(
                                bottom: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DigitCard(
                        margin: const EdgeInsets.all(8),
                        child: LabelValueSummary(
                          padding: EdgeInsets.zero,
                          heading: localizations.translate(
                            i18.householdDetails.householdDetailsLabel,
                          ),
                          headingStyle: textTheme.headlineLarge!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          items: [
                            LabelValueItem(
                              label: localizations.translate(
                                i18.householdDetails.noOfMembersCountLabelMda,
                              ),
                              value: householdState.householdModel?.memberCount
                                      .toString() ??
                                  '0',
                              isInline: true,
                              labelFlex: 5,
                              padding: const EdgeInsets.only(
                                bottom: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DigitCard(
                        margin: const EdgeInsets.all(8),
                        child: LabelValueSummary(
                          padding: EdgeInsets.zero,
                          heading: localizations.translate(i18
                              .individualDetails.individualsDetailsLabelText),
                          headingStyle: textTheme.headlineLarge!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          items: [
                            LabelValueItem(
                              label: localizations.translate(
                                i18.individualDetails.nameLabelText,
                              ),
                              value:
                                  '${widget.individualModel?.name?.givenName} ${widget.individualModel?.name?.familyName}',
                              labelFlex: 5,
                              padding: const EdgeInsets.only(
                                bottom: 8,
                              ),
                            ),
                            LabelValueItem(
                              label: localizations.translate(
                                i18.individualDetails.dobLabelText,
                              ),
                              value: widget.individualModel?.dateOfBirth != null
                                  ? DigitDateUtils.getFilteredDate(
                                      DigitDateUtils.getFormattedDateToDateTime(
                                        widget.individualModel?.dateOfBirth ??
                                            '',
                                      ).toString(),
                                      dateFormat:
                                          Constants().dateMonthYearFormat,
                                    ).toString()
                                  : localizations.translate(
                                      i18.common.coreCommonNA,
                                    ),
                              labelFlex: 5,
                            ),
                            LabelValueItem(
                              label: localizations.translate(
                                  i18.individualDetails.genderLabelText),
                              value: widget.individualModel?.gender != null
                                  ? localizations.translate(widget
                                          .individualModel?.gender?.name
                                          .toUpperCase() ??
                                      '')
                                  : localizations.translate(
                                      i18.common.coreCommonNA,
                                    ),
                              labelFlex: 5,
                              padding: const EdgeInsets.only(
                                top: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
