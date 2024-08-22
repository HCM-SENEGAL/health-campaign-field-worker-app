import 'package:collection/collection.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../blocs/facility/facility.dart';
import '../../../blocs/project/project.dart';
import '../../../blocs/record_stock/record_stock.dart';
import '../../../blocs/scanner/scanner.dart';
import '../../../data/local_store/sql_store/tables/stock.dart';
import '../../../models/data_model.dart';
import '../../../router/app_router.dart';
import '../../../utils/i18_key_constants.dart' as i18;
import '../../../utils/utils.dart';
import '../../../widgets/header/back_navigation_help_header.dart';
import '../../../widgets/inventory/no_facilities_assigned_dialog.dart';
import '../../../widgets/localized.dart';

class WarehouseDetailsPage extends LocalizedStatefulWidget {
  const WarehouseDetailsPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<WarehouseDetailsPage> createState() => _WarehouseDetailsPageState();
}

class _WarehouseDetailsPageState extends LocalizedState<WarehouseDetailsPage> {
  static const _dateOfEntryKey = 'dateOfReceipt';
  static const _administrativeUnitKey = 'administrativeUnit';
  static const _warehouseKey = 'warehouse';
  static const _teamCodeKey = 'teamCode';
  bool deliveryTeamSelected = false;
  String? selectedFacilityId;
  FacilityModel? prevFacility;
  String? entryType;
  FacilityModel? filteredFacility;

  @override
  void initState() {
    // clearQRCodes();
    final stockState = context.read<RecordStockBloc>().state;
    setState(() {
      entryType = stockState.entryType.toString();
    });
    super.initState();
  }

  FormGroup buildForm(bool isDistributor, RecordStockState stockState) =>
      fb.group(<String, Object>{
        _dateOfEntryKey: FormControl<DateTime>(value: DateTime.now()),
        _administrativeUnitKey: FormControl<String>(
          value: context.boundary.name,
        ),
        _warehouseKey: FormControl<String>(
          validators: [Validators.required],
          // value: isCommunityDistributor && filteredFacility != null
          //     ? filteredFacility!.name
          //     : prevFacility?.name,
        ),
        _teamCodeKey: FormControl<String>(
          value: stockState.primaryId ?? '',
          validators: deliveryTeamSelected ? [Validators.required] : [],
        ),
      });

  @override
  Widget build(BuildContext context) {
    bool isDistributor = context.loggedInUserRoles
        .where(
          (role) => role.code == RolesType.distributor.toValue(),
        )
        .toList()
        .isNotEmpty;
    bool isWareHouseMgr = context.loggedInUserRoles
        .where(
          (role) =>
              role.code == RolesType.healthFacilitySupervisor.toValue() ||
              role.code == RolesType.warehouseManager.toValue(),
        )
        .toList()
        .isNotEmpty;

    bool isSupervisor = context.loggedInUserRoles
        .where(
          (role) => role.code == RolesType.fieldSupervisor.toValue(),
        )
        .toList()
        .isNotEmpty;

    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (ctx, projectState) {
        final selectedProject = projectState.selectedProject;

        if (selectedProject == null) {
          return const Center(child: Text('No project selected'));
        }

        final theme = Theme.of(context);

        return BlocConsumer<FacilityBloc, FacilityState>(
          listener: (context, state) {
            state.whenOrNull(
              empty: () => NoFacilitiesAssignedDialog.show(context),
            );
          },
          builder: (ctx, facilityState) {
            final facilities = facilityState.whenOrNull(
                  fetched: (facilities, _, __) {
                    List<FacilityModel> teamFacilities = [];
                    teamFacilities.addAll(
                      facilities,
                    );

                    return isDistributor && !isWareHouseMgr
                        ? teamFacilities
                        : facilities;
                  },
                ) ??
                [];
            // get distribution facilities for communityDistributor , solution customisation
            List<FacilityModel> filteredFacilities = [];
            if (isSupervisor) {
              filteredFacilities = facilities
                  .where(
                    (element) => element.name == context.loggedInUser.userName,
                  )
                  .toList();
              if (filteredFacilities.isNotEmpty) {
                filteredFacility = filteredFacilities.first;
              }
            } else {
              filteredFacilities = facilities
                  .where(
                    (element) => element.usage != 'CD' && element.usage != 'CS',
                  )
                  .toList();
            }

            // prevFacility = facilityState.whenOrNull(
            //   fetched: (_, __, facility) => facility,
            // );

            // if (prevFacility != null) {
            //   selectedFacilityId = prevFacility?.id;
            // } else if (isCommunityDistributor && filteredFacility != null) {
            //   selectedFacilityId = filteredFacility!.id;
            // }

            return Scaffold(
              body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: BlocBuilder<ScannerBloc, ScannerState>(
                  builder: (context, scannerState) {
                    final stockState =
                        BlocProvider.of<RecordStockBloc>(context).state;

                    return ReactiveFormBuilder(
                      form: () => buildForm(
                          isDistributor && !isWareHouseMgr, stockState),
                      builder: (context, form, child) {
                        form.control(_teamCodeKey).value =
                            scannerState.qrcodes.isNotEmpty
                                ? scannerState.qrcodes.last
                                : '';

                        return ScrollableContent(
                          header: const Column(children: [
                            BackNavigationHelpHeaderWidget(),
                          ]),
                          footer: SizedBox(
                            child: DigitCard(
                              margin:
                                  const EdgeInsets.fromLTRB(0, kPadding, 0, 0),
                              padding: const EdgeInsets.fromLTRB(
                                kPadding,
                                0,
                                kPadding,
                                0,
                              ),
                              child: ReactiveFormConsumer(
                                builder: (context, form, child) {
                                  return DigitElevatedButton(
                                    onPressed: !form.valid
                                        ? null
                                        : () {
                                            form.markAllAsTouched();
                                            if (!form.valid) {
                                              return;
                                            }
                                            final dateOfRecord = form
                                                .control(_dateOfEntryKey)
                                                .value as DateTime;

                                            final teamCode = form
                                                .control(_teamCodeKey)
                                                .value as String?;

                                            final facility =
                                                deliveryTeamSelected
                                                    ? FacilityModel(
                                                        id: teamCode ??
                                                            'Delivery Team',
                                                      )
                                                    : selectedFacilityId != null
                                                        ? FacilityModel(
                                                            id: selectedFacilityId
                                                                .toString(),
                                                          )
                                                        : null;

                                            context.read<ScannerBloc>().add(
                                                  const ScannerEvent
                                                      .handleScanner([], []),
                                                );
                                            if (facility == null) {
                                              DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                  localizations.translate(
                                                    i18.stockDetails
                                                        .facilityRequired,
                                                  ),
                                                  true,
                                                  theme,
                                                ),
                                              );
                                            } else if (deliveryTeamSelected &&
                                                (teamCode == null ||
                                                    teamCode.trim().isEmpty)) {
                                              DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                  localizations.translate(
                                                    i18.stockDetails
                                                        .teamCodeRequired,
                                                  ),
                                                  true,
                                                  theme,
                                                ),
                                              );
                                            } else {
                                              context
                                                  .read<RecordStockBloc>()
                                                  .add(
                                                    RecordStockSaveWarehouseDetailsEvent(
                                                      dateOfRecord:
                                                          dateOfRecord,
                                                      facilityModel: facility,
                                                    ),
                                                  );
                                              context.router.push(
                                                StockDetailsRoute(),
                                              );
                                            }
                                          },
                                    child: child!,
                                  );
                                },
                                child: Center(
                                  child: Text(
                                    localizations.translate(
                                      i18.householdDetails.actionLabel,
                                    ),
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
                                    isDistributor && !isWareHouseMgr
                                        ? localizations.translate(
                                            i18.stockDetails
                                                .transactionDetailsLabel,
                                          )
                                        : localizations.translate(
                                            i18.warehouseDetails
                                                .warehouseDetailsLabel,
                                          ),
                                    style: theme.textTheme.displayMedium,
                                  ),
                                  Column(children: [
                                    DigitDateFormPicker(
                                      isEnabled: true,
                                      formControlName: _dateOfEntryKey,
                                      label: entryType ==
                                              StockRecordEntryType.receipt
                                                  .toString()
                                          ? localizations.translate(
                                              i18.warehouseDetails
                                                  .dateOfReceipt,
                                            )
                                          : entryType ==
                                                  StockRecordEntryType.dispatch
                                                      .toString()
                                              ? localizations.translate(
                                                  i18.warehouseDetails
                                                      .dateOfIssue,
                                                )
                                              : localizations.translate(
                                                  i18.warehouseDetails
                                                      .dateOfReturn,
                                                ),
                                      isRequired: false,
                                      confirmText: localizations.translate(
                                        i18.common.coreCommonOk,
                                      ),
                                      cancelText: localizations.translate(
                                        i18.common.coreCommonCancel,
                                      ),
                                    ),
                                    DigitTextFormField(
                                      readOnly: true,
                                      formControlName: _administrativeUnitKey,
                                      label: localizations.translate(
                                        i18.warehouseDetails.administrativeUnit,
                                      ),
                                    ),
                                  ]),
                                  InkWell(
                                    onTap: facilities.isEmpty
                                        ? null
                                        : () async {
                                            clearQRCodes();
                                            form.control(_teamCodeKey).value =
                                                '';
                                            final parent = context.router
                                                .parent() as StackRouter;
                                            final facility = await parent
                                                .push<FacilityModel>(
                                              FacilitySelectionRoute(
                                                facilities:
                                                    filteredFacilities.isEmpty
                                                        ? facilities
                                                        : filteredFacilities,
                                              ),
                                            );

                                            if (facility == null) return;
                                            form.control(_warehouseKey).value =
                                                localizations.translate(
                                                    '${facility.name}');

                                            setState(() {
                                              selectedFacilityId = facility.id;
                                            });
                                            if (facility.id ==
                                                'Delivery Team') {
                                              setState(() {
                                                deliveryTeamSelected = true;
                                              });
                                            } else {
                                              setState(() {
                                                deliveryTeamSelected = false;
                                              });
                                            }
                                          },
                                    child: IgnorePointer(
                                      child: DigitTextFormField(
                                        hideKeyboard: true,
                                        padding: const EdgeInsets.only(
                                          bottom: kPadding,
                                        ),
                                        isRequired: true,
                                        label: localizations.translate(
                                          i18.stockReconciliationDetails
                                              .facilityLabel,
                                        ),
                                        validationMessages: {
                                          'required': (object) =>
                                              localizations.translate(
                                                '${i18.individualDetails.nameLabelText}_IS_REQUIRED',
                                              ),
                                        },
                                        suffix: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(Icons.search),
                                        ),
                                        formControlName: _warehouseKey,
                                        readOnly: true,
                                        onTap: facilities.isEmpty
                                            ? null
                                            : () async {
                                                context.read<ScannerBloc>().add(
                                                      const ScannerEvent
                                                          .handleScanner(
                                                        [],
                                                        [],
                                                      ),
                                                    );
                                                form
                                                    .control(_teamCodeKey)
                                                    .value = '';
                                                final parent = context.router
                                                    .parent() as StackRouter;
                                                final facility = await parent
                                                    .push<FacilityModel>(
                                                  FacilitySelectionRoute(
                                                    facilities:
                                                        filteredFacilities
                                                                .isEmpty
                                                            ? facilities
                                                            : filteredFacilities,
                                                  ),
                                                );

                                                if (facility == null) return;
                                                form
                                                        .control(_warehouseKey)
                                                        .value =
                                                    localizations.translate(
                                                  '${facility.name}',
                                                );

                                                setState(() {
                                                  selectedFacilityId =
                                                      facility.id;
                                                });
                                                if (facility.id ==
                                                    'Delivery Team') {
                                                  setState(() {
                                                    deliveryTeamSelected = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    deliveryTeamSelected =
                                                        false;
                                                  });
                                                }
                                              },
                                      ),
                                    ),
                                  ),
                                  if (deliveryTeamSelected)
                                    DigitTextFormField(
                                      label: localizations.translate(
                                        i18.stockReconciliationDetails
                                            .teamCodeLabel,
                                      ),
                                      formControlName: _teamCodeKey,
                                      onChanged: (val) {
                                        String? value = val as String?;
                                        if (value != null &&
                                            value.trim().isNotEmpty) {
                                          context.read<ScannerBloc>().add(
                                                ScannerEvent.handleScanner(
                                                  [],
                                                  [value],
                                                ),
                                              );
                                        } else {
                                          clearQRCodes();
                                        }
                                      },
                                      isRequired: true,
                                      suffix: IconButton(
                                        onPressed: () {
                                          context.router.push(QRScannerRoute(
                                            quantity: 1,
                                            isGS1code: false,
                                            sinlgleValue: true,
                                          ));
                                        },
                                        icon: Icon(
                                          Icons.qr_code_2,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void clearQRCodes() {
    context.read<ScannerBloc>().add(const ScannerEvent.handleScanner([], []));
  }
}
