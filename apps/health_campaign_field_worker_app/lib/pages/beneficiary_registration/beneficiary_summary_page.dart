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

class BeneficiarySummaryPage extends LocalizedStatefulWidget {
  final dynamic name;
  final IndividualModel individualModel;
  const BeneficiarySummaryPage({
    super.key,
    super.appLocalizations,
    required this.name,
    required this.individualModel,
  });

  @override
  State<BeneficiarySummaryPage> createState() => SummaryBeneficiaryPageState();
}

class SummaryBeneficiaryPageState
    extends LocalizedState<BeneficiarySummaryPage> {
  final clickedStatus = ValueNotifier<bool>(false);
  // late final SearchHouseholdsBloc customSearchHouseholdsBloc;
  late final dynamic searchHouseholdsBloc;
  
  get spacer2 => null;

  @override
  void initState() {
    super.initState();
    searchHouseholdsBloc = context.read<SearchHouseholdsBloc>();
  }

  String getLocalizedMessage(String code) {
    return localizations.translate(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final textTheme = theme.digitTextTheme(context);
    final textTheme = theme.textTheme;

    return PopScope(
      // onPopInvoked: (val) {},
      onPopInvoked: (didPop) async {
        context
            .read<SearchBlocWrapper>()
            .searchHouseholdsBloc
            .add(const SearchHouseholdsClearEvent());
        Navigator.of(context).pop();
      },
      child: Scaffold(
        body: BlocConsumer<BeneficiaryRegistrationBloc,
            BeneficiaryRegistrationState>(
          listener: (context, householdState) {
            final router = context.router;
            householdState.mapOrNull(
              persisted: (value) {
                // const SearchHouseholdsClearEvent();
                // SearchHouseholdsSearchByHouseholdHeadEvent(
                //   // ignore: avoid_dynamic_calls
                //   searchText: widget.name.trim(),
                //   projectId: context.projectId,
                //   isProximityEnabled: false,
                //   // maxRadius: RegistrationDeliverySingleton().maxRadius,
                //   limit: 10,
                //   offset: 0,
                // );
                // router.popUntil((route) =>
                //     route.settings.name == SearchBeneficiaryRoute.name);
                context.read<SearchBlocWrapper>().searchHouseholdsBloc.add(
                      SearchHouseholdsEvent.searchByHousehold(
                        householdModel: value.householdModel,
                        projectId: context.projectId,
                        isProximityEnabled: false,
                      ),
                    );
                router.popAndPush(BeneficiaryAcknowledgementRoute(
                  enableViewHousehold: true,
                  // acknowledgementType: AcknowledgementType.addMember,
                ));
                // }
              },
            );
          },
          builder: (context, householdState) {
            return ScrollableContent(
                enableFixedDigitButton: true,
                header: Column(children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child:  BackNavigationHelpHeaderWidget(
                      showHelp: false,
                      showBackNavigation: true,
                    handleback: () {
                      context.router.pop();
                    },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizations.translate(
                          i18.common.coreCommonSummaryDetails,
                        ),
                        style: textTheme.headlineLarge
                            ?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                ]),
                footer: DigitCard(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: clickedStatus,
                        builder: (context, bool isClicked, _) {
                          return DigitElevatedButton(
                            child: Center(
                              child: Text(
                                householdState.mapOrNull(
                                  editIndividual: (value) =>
                                      localizations.translate(
                                          i18.common.coreCommonSave,),
                                ) ??
                                localizations.translate(
                                    i18.common.coreCommonSubmit,),
                              ),
                            ),
                            onPressed: () async {
                              final bloc =
                                  context.read<BeneficiaryRegistrationBloc>();

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
                                  final scannerBloc =
                                      context.read<ScannerBloc>();
                                  bloc.add(
                                    BeneficiaryRegistrationAddMemberEvent(
                                      beneficiaryType: context.beneficiaryType,
                                      householdModel:
                                          householdState.householdModel!,
                                      individualModel: widget.individualModel,
                                      addressModel: householdState
                                          .householdModel!.address!,
                                      userUuid: context.loggedInUserUuid,
                                      projectId: context.projectId,
                                      tag: scannerBloc.state.qrcodes.isNotEmpty
                                          ? scannerBloc.state.qrcodes.first
                                          : null,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ],
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
                                  heading: localizations.translate(i18
                                      .householdLocation
                                      .householdLocationLabelText),
                                  headingStyle: textTheme.headlineLarge!.copyWith(
                                     color: theme.colorScheme.primary,
                                  ),
                                  items: [
                                    LabelValueItem(
                                        label: localizations.translate(
                                            i18.householdLocation.administrationAreaFormLabel,),
                                        value: localizations.translate(
                                             context.boundary.name ??
                                                i18.common.coreCommonNA,),
                                        isInline: true,
                                        labelFlex: 5,
                                        padding: const EdgeInsets.only(
                                            bottom: 8,),),
                                  ],),),
                        DigitCard(
                            margin: const EdgeInsets.all(8),
                            child: LabelValueSummary(
                                  padding: EdgeInsets.zero,
                                  heading: localizations.translate(i18
                                      .householdDetails.householdDetailsLabel),
                                  headingStyle: textTheme.headlineLarge!.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                  items: [
                                    LabelValueItem(
                                        label: localizations.translate(i18
                                            .householdDetails
                                            .noOfMembersCountLabel),
                                        value: householdState
                                                .householdModel?.memberCount
                                                .toString() ??
                                            '0',
                                        isInline: true,
                                        labelFlex: 5,
                                        padding: const EdgeInsets.only(
                                            bottom: 8,),),
                                  ],),),
                        DigitCard(
                            margin: const EdgeInsets.all(8),
                          child: LabelValueSummary(
                                  padding: EdgeInsets.zero,
                                  heading: localizations.translate(i18
                                      .individualDetails
                                      .individualsDetailsLabelText),
                                  headingStyle: textTheme.headlineLarge!.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                  items: [
                                    LabelValueItem(
                                        label: localizations.translate(i18
                                            .individualDetails.nameLabelText),
                                        value: '${widget.individualModel.name?.givenName} ${widget.individualModel.name?.familyName}',
                                        labelFlex: 5,
                                        padding: const EdgeInsets.only(
                                            bottom: 8,),),
                                    LabelValueItem(
                                      label: localizations.translate(
                                          i18.individualDetails.dobLabelText,),
                                      value: widget.individualModel
                                                  .dateOfBirth !=
                                              null
                                          ? DigitDateUtils.getFilteredDate(
                                                  DigitDateUtils.getFormattedDateToDateTime(
                                                          widget.individualModel
                                                                  .dateOfBirth ??
                                                              '',)
                                                      .toString(),
                                                  dateFormat: Constants()
                                                      .dateMonthYearFormat,)
                                              .toString()
                                          : localizations.translate(
                                              i18.common.coreCommonNA,),
                                      labelFlex: 5,
                                    ),
                                    LabelValueItem(
                                        label: localizations.translate(i18
                                            .individualDetails.genderLabelText),
                                        value: widget.individualModel.gender !=
                                                null
                                            ? localizations.translate(widget
                                                    .individualModel
                                                    .gender
                                                    ?.name
                                                    .toUpperCase() ??
                                                '')
                                            : localizations.translate(
                                                i18.common.coreCommonNA,),
                                        labelFlex: 5,
                                        padding: const EdgeInsets.only(
                                            top: 8,),),
                                  ],),
                          ),
                      ],
                    ),
                  ),
                ],);
          },
        ),
      ),
    );
  }
}
