import 'package:collection/collection.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:recase/recase.dart';

import '../../../blocs/app_initialization/app_initialization.dart';
import '../../../blocs/facility/facility.dart';
import '../../../blocs/product_variant/product_variant.dart';
import '../../../blocs/record_stock/record_stock.dart';
import '../../../blocs/scanner/scanner.dart';
import '../../../data/local_store/no_sql/schema/app_configuration.dart';
import '../../../models/data_model.dart';
import '../../../router/app_router.dart';
import '../../../utils/i18_key_constants.dart' as i18;
import '../../../utils/utils.dart';
import '../../../widgets/header/back_navigation_help_header.dart';
import '../../../widgets/localized.dart';

class StockDetailsPage extends LocalizedStatefulWidget {
  const StockDetailsPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<StockDetailsPage> createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends LocalizedState<StockDetailsPage> {
  static const _productVariantKey = 'productVariant';
  static const _secondaryPartyKey = 'secondaryParty';
  static const _transactionQuantityKey = 'quantity';
  static const _transactionReasonKey = 'transactionReason';
  static const _waybillNumberKey = 'waybillNumber';
  static const _waybillQuantityKey = 'waybillQuantity';
  static const _vehicleNumberKey = 'vehicleNumber';
  static const _typeOfTransportKey = 'typeOfTransport';
  static const _commentsKey = 'comments';
  static const _deliveryTeamKey = 'deliveryTeam';
  static const _batchNumberKey = 'batchNumber';
  static const _dateOfExpiry = 'dateOfExpiry';
  int maxStockQuantity = 100000;
  bool deliveryTeamSelected = false;
  String? selectedFacilityId;

  FormGroup _form(StockRecordEntryType stockType) {
    return fb.group({
      _productVariantKey: FormControl<ProductVariantModel>(
        validators: [Validators.required],
      ),
      _secondaryPartyKey: FormControl<String>(
        validators: [Validators.required],
      ),
      _transactionQuantityKey: FormControl<int>(validators: [
        Validators.number,
        Validators.required,
        Validators.min(0),
        Validators.max(maxStockQuantity),
      ]),
      _transactionReasonKey: FormControl<TransactionReason>(),
      // _waybillNumberKey: FormControl<String>(
      //   validators: [Validators.required],
      // ),
      // _waybillQuantityKey: FormControl<int>(
      //   validators: [
      //     Validators.number,
      //     Validators.required,
      //     Validators.min(0),
      //   ],
      // ),
      // _vehicleNumberKey: FormControl<String>(),
      // _typeOfTransportKey: FormControl<String>(),
      _commentsKey: FormControl<String>(),
      // _deliveryTeamKey: FormControl<String>(
      //   validators: deliveryTeamSelected ? [Validators.required] : [],
      // ),
      // _batchNumberKey: FormControl<String>(
      //   validators: [Validators.required],
      // ),
      // _dateOfExpiry: FormControl<DateTime>(
      //   validators: [Validators.required],
      // ),
    });
  }

  @override
  void initState() {
    clearQRCodes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool isWareHouseMgr = true;

    return PopScope(
      onPopInvoked: (didPop) {
        final stockState = context.read<RecordStockBloc>().state;
        if (stockState.primaryId != null) {
          context.read<ScannerBloc>().add(
                ScannerEvent.handleScanner(
                  [],
                  [stockState.primaryId.toString()],
                ),
              );
        }
      },
      child: Scaffold(
        body: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, locationState) {
            return BlocConsumer<RecordStockBloc, RecordStockState>(
              listener: (context, stockState) {
                stockState.mapOrNull(
                  persisted: (value) {
                    final parent = context.router.parent() as StackRouter;
                    parent.replace(AcknowledgementRoute());
                  },
                );
              },
              builder: (context, stockState) {
                StockRecordEntryType entryType = stockState.entryType;

                const module = i18.stockDetails;

                String pageTitle;
                String transactionPartyLabel;
                String quantityCountLabel;
                String? transactionReasonLabel;
                TransactionReason? transactionReason;
                TransactionType transactionType;

                List<TransactionReason>? reasons;

                switch (entryType) {
                  case StockRecordEntryType.receipt:
                    pageTitle = module.receivedPageTitle;
                    transactionPartyLabel =
                        module.selectTransactingPartyReceived;
                    quantityCountLabel = module.quantityReceivedLabel;
                    transactionType = TransactionType.received;

                    break;
                  case StockRecordEntryType.dispatch:
                    pageTitle = module.issuedPageTitle;
                    transactionPartyLabel = module.selectTransactingPartyIssued;
                    quantityCountLabel = module.quantitySentLabel;
                    transactionType = TransactionType.dispatched;

                    break;
                  case StockRecordEntryType.returned:
                    pageTitle = module.returnedPageTitle;
                    transactionPartyLabel =
                        module.selectTransactingPartyReturned;
                    quantityCountLabel = module.quantityReturnedLabel;
                    transactionType = TransactionType.received;
                    break;
                  case StockRecordEntryType.loss:
                    pageTitle = module.lostPageTitle;
                    quantityCountLabel = module.quantityLostLabel;
                    transactionReasonLabel = module.transactionReasonLost;
                    transactionType = TransactionType.dispatched;

                    reasons = [
                      TransactionReason.lostInStorage,
                      TransactionReason.lostInTransit,
                    ];
                    break;
                  case StockRecordEntryType.damaged:
                    pageTitle = module.damagedPageTitle;
                    transactionPartyLabel =
                        module.selectTransactingPartyReceivedFromDamaged;
                    quantityCountLabel = module.quantityDamagedLabel;
                    transactionReasonLabel = module.transactionReasonDamaged;
                    transactionType = TransactionType.dispatched;

                    reasons = [
                      TransactionReason.damagedInStorage,
                      TransactionReason.damagedInTransit,
                    ];
                    break;
                }

                transactionReasonLabel ??= '';

                return ReactiveFormBuilder(
                  form: () => _form(entryType),
                  builder: (context, form, child) {
                    return BlocBuilder<ScannerBloc, ScannerState>(
                      builder: (context, scannerState) {
                        // form.control(_deliveryTeamKey).value =
                        //     scannerState.qrcodes.isNotEmpty
                        //         ? scannerState.qrcodes.last
                        //         : '';

                        return ScrollableContent(
                          header: Column(children: [
                            BackNavigationHelpHeaderWidget(
                              handleback: () {
                                final stockState =
                                    context.read<RecordStockBloc>().state;
                                if (stockState.primaryId != null) {
                                  context.read<ScannerBloc>().add(
                                        ScannerEvent.handleScanner(
                                          [],
                                          [stockState.primaryId.toString()],
                                        ),
                                      );
                                }
                              },
                            ),
                          ]),
                          enableFixedButton: true,
                          footer: DigitCard(
                            margin:
                                const EdgeInsets.fromLTRB(0, kPadding, 0, 0),
                            padding: const EdgeInsets.fromLTRB(
                              kPadding,
                              0,
                              kPadding,
                              0,
                            ),
                            child: ReactiveFormConsumer(
                              builder: (context, form, child) =>
                                  DigitElevatedButton(
                                onPressed: !form.valid
                                    ? null
                                    : () async {
                                        form.markAllAsTouched();
                                        if (!form.valid) {
                                          return;
                                        }
                                        final primaryId =
                                            BlocProvider.of<RecordStockBloc>(
                                          context,
                                        ).state.primaryId;
                                        final secondaryParty =
                                            selectedFacilityId != null
                                                ? FacilityModel(
                                                    id: selectedFacilityId
                                                        .toString(),
                                                  )
                                                : null;
                                        // final deliveryTeamName = form
                                        //     .control(_deliveryTeamKey)
                                        //     .value as String?;

                                        if (primaryId == secondaryParty?.id) {
                                          DigitToast.show(
                                            context,
                                            options: DigitToastOptions(
                                              localizations.translate(
                                                i18.stockDetails
                                                    .transactionIdsCheckLabel,
                                              ),
                                              true,
                                              theme,
                                            ),
                                          );

                                          return;
                                        }
                                        if (deliveryTeamSelected) {
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
                                          // } else if ((primaryId ==
                                          //         secondaryParty?.id) ||
                                          //     (primaryId == deliveryTeamName)) {
                                          //   DigitToast.show(
                                          //     context,
                                          //     options: DigitToastOptions(
                                          //       localizations.translate(
                                          //         i18.stockDetails
                                          //             .senderReceiverValidation,
                                          //       ),
                                          //       true,
                                          //       theme,
                                          //     ),
                                          //   );
                                        } else {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();

                                          final bloc =
                                              context.read<RecordStockBloc>();

                                          final productVariant = form
                                              .control(_productVariantKey)
                                              .value as ProductVariantModel;

                                          switch (entryType) {
                                            case StockRecordEntryType.receipt:
                                              transactionReason =
                                                  TransactionReason.received;
                                              break;
                                            case StockRecordEntryType.dispatch:
                                              transactionReason = null;
                                              break;
                                            case StockRecordEntryType.returned:
                                              transactionReason =
                                                  TransactionReason.returned;
                                              break;
                                            default:
                                              transactionReason = form
                                                  .control(
                                                    _transactionReasonKey,
                                                  )
                                                  .value as TransactionReason?;
                                              break;
                                          }

                                          final quantity = form
                                              .control(_transactionQuantityKey)
                                              .value;

                                          // final waybillNumber = form
                                          //     .control(_waybillNumberKey)
                                          //     .value as String?;

                                          // final waybillQuantity = form
                                          //     .control(_waybillQuantityKey)
                                          //     .value;

                                          // final vehicleNumber = form
                                          //     .control(_vehicleNumberKey)
                                          //     .value as String?;

                                          // final batchNumber = form
                                          //     .control(_batchNumberKey)
                                          //     .value as String?;

                                          // final expiryDate = form
                                          //     .control(_dateOfExpiry)
                                          //     .value as DateTime?;

                                          final lat = locationState.latitude;
                                          final lng = locationState.longitude;

                                          final hasLocationData =
                                              lat != null && lng != null;

                                          final comments = form
                                              .control(_commentsKey)
                                              .value as String?;

                                          // final deliveryTeamName = form
                                          //     .control(_deliveryTeamKey)
                                          //     .value as String?;

                                          String? senderId;
                                          String? senderType;
                                          String? receiverId;
                                          String? receiverType;

                                          final primaryType =
                                              BlocProvider.of<RecordStockBloc>(
                                            context,
                                          ).state.primaryType;

                                          final primaryId =
                                              BlocProvider.of<RecordStockBloc>(
                                            context,
                                          ).state.primaryId;

                                          switch (entryType) {
                                            case StockRecordEntryType.receipt:
                                            case StockRecordEntryType.loss:
                                            case StockRecordEntryType.damaged:
                                              senderId = secondaryParty?.id;
                                              senderType = "WAREHOUSE";
                                              receiverId = primaryId;
                                              receiverType = primaryType;

                                              break;
                                            case StockRecordEntryType.dispatch:
                                            case StockRecordEntryType.returned:
                                              receiverId = secondaryParty?.id;
                                              receiverType = "WAREHOUSE";
                                              senderId = primaryId;
                                              senderType = primaryType;
                                              break;
                                          }

                                          if (entryType ==
                                              StockRecordEntryType.dispatch) {
                                            int issueQuantity = quantity ?? 0;

                                            List<StockModel>
                                                stocksByProductVAriant =
                                                stockState.existingStocks
                                                    .where((element) =>
                                                        element
                                                            .productVariantId ==
                                                        productVariant.id)
                                                    .toList();

                                            num stockReceived =
                                                _getQuantityCount(
                                              stocksByProductVAriant.where(
                                                (e) =>
                                                    e.transactionType ==
                                                        TransactionType
                                                            .received &&
                                                    e.transactionReason ==
                                                        TransactionReason
                                                            .received,
                                              ),
                                            );

                                            num stockIssued = _getQuantityCount(
                                              stocksByProductVAriant.where(
                                                (e) =>
                                                    e.transactionType ==
                                                        TransactionType
                                                            .dispatched &&
                                                    e.transactionReason == null,
                                              ),
                                            );

                                            num stockReturned =
                                                _getQuantityCount(
                                              stocksByProductVAriant.where(
                                                (e) =>
                                                    e.transactionType ==
                                                        TransactionType
                                                            .received &&
                                                    e.transactionReason ==
                                                        TransactionReason
                                                            .returned,
                                              ),
                                            );

                                            num stockInHand = (stockReceived +
                                                    stockReturned) -
                                                (stockIssued);
                                            if (issueQuantity > stockInHand) {
                                              final alert =
                                                  await DigitDialog.show<bool>(
                                                context,
                                                options: DigitDialogOptions(
                                                  titleText:
                                                      localizations.translate(
                                                    i18.stockDetails
                                                        .countDialogTitle,
                                                  ),
                                                  contentText: localizations
                                                      .translate(
                                                        i18.stockDetails
                                                            .countContent,
                                                      )
                                                      .replaceAll(
                                                        '{}',
                                                        stockInHand.toString(),
                                                      ),
                                                  primaryAction:
                                                      DigitDialogActions(
                                                    label:
                                                        localizations.translate(
                                                      i18.stockDetails
                                                          .countDialogSuccess,
                                                    ),
                                                    action: (context) {
                                                      Navigator.of(
                                                        context,
                                                        rootNavigator: true,
                                                      ).pop(false);
                                                    },
                                                  ),
                                                ),
                                              );

                                              if (!(alert ?? false)) {
                                                return;
                                              }
                                            }
                                          }

                                          final cycleIndex = context
                                                      .selectedCycle.id ==
                                                  0
                                              ? ""
                                              : "0${context.selectedCycle.id}";

                                          final projectTypeId = context
                                                      .selectedProjectType ==
                                                  null
                                              ? ""
                                              : context.selectedProjectType!.id;

                                          final stockModel = StockModel(
                                            clientReferenceId:
                                                IdGen.i.identifier,
                                            productVariantId: productVariant.id,
                                            transactionReason:
                                                transactionReason,
                                            transactionType: transactionType,
                                            referenceId: stockState.projectId,
                                            referenceIdType: 'PROJECT',
                                            quantity: quantity.toString(),
                                            // waybillNumber: waybillNumber,
                                            receiverId: receiverId,
                                            receiverType: receiverType,
                                            senderId: senderId,
                                            senderType: senderType,
                                            facilityId: primaryId,
                                            transactingPartyId:
                                                secondaryParty?.id,
                                            transactingPartyType: "WAREHOUSE",
                                            auditDetails: AuditDetails(
                                              createdBy:
                                                  context.loggedInUserUuid,
                                              createdTime: context
                                                  .millisecondsSinceEpoch(),
                                            ),
                                            clientAuditDetails:
                                                ClientAuditDetails(
                                              createdBy:
                                                  context.loggedInUserUuid,
                                              createdTime: context
                                                  .millisecondsSinceEpoch(),
                                              lastModifiedBy:
                                                  context.loggedInUserUuid,
                                              lastModifiedTime: context
                                                  .millisecondsSinceEpoch(),
                                            ),
                                            additionalFields: [
                                                      // waybillQuantity,
                                                      comments,
                                                      // batchNumber,
                                                      // expiryDate,
                                                    ].any((element) =>
                                                        element != null) ||
                                                    hasLocationData
                                                ? StockAdditionalFields(
                                                    version: 1,
                                                    fields: [
                                                      // if (waybillQuantity !=
                                                      //     null)
                                                      //   AdditionalField(
                                                      //     'waybill_quantity',
                                                      //     waybillQuantity
                                                      //         .toString(),
                                                      //   ),
                                                      if (comments != null)
                                                        AdditionalField(
                                                          'comments',
                                                          comments,
                                                        ),
                                                      // if (batchNumber != null)
                                                      //   AdditionalField(
                                                      //     _batchNumberKey,
                                                      //     batchNumber,
                                                      //   ),
                                                      // if (expiryDate != null)
                                                      //   AdditionalField(
                                                      //     _dateOfExpiry,
                                                      //     expiryDate
                                                      //         .millisecondsSinceEpoch,
                                                      //   ),
                                                      if (hasLocationData) ...[
                                                        AdditionalField(
                                                          'lat',
                                                          lat,
                                                        ),
                                                        AdditionalField(
                                                          'lng',
                                                          lng,
                                                        ),
                                                      ],
                                                      if (cycleIndex.isNotEmpty)
                                                        AdditionalField(
                                                          "cycleIndex",
                                                          cycleIndex,
                                                        ),
                                                      if (projectTypeId
                                                          .isNotEmpty)
                                                        AdditionalField(
                                                          "projectTypeId",
                                                          projectTypeId,
                                                        ),
                                                    ],
                                                  )
                                                : null,
                                          );

                                          bloc.add(
                                            RecordStockSaveStockDetailsEvent(
                                              stockModel: stockModel,
                                            ),
                                          );

                                          final submit =
                                              await DigitDialog.show<bool>(
                                            context,
                                            options: DigitDialogOptions(
                                              titleText:
                                                  localizations.translate(
                                                i18.stockDetails.dialogTitle,
                                              ),
                                              contentText:
                                                  localizations.translate(
                                                i18.stockDetails.dialogContent,
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
                                              secondaryAction:
                                                  DigitDialogActions(
                                                label: localizations.translate(
                                                  i18.common.coreCommonCancel,
                                                ),
                                                action: (context) =>
                                                    Navigator.of(
                                                  context,
                                                  rootNavigator: true,
                                                ).pop(false),
                                              ),
                                            ),
                                          );

                                          if (submit ?? false) {
                                            bloc.add(
                                              const RecordStockCreateStockEntryEvent(),
                                            );
                                          }
                                        }
                                      },
                                child: Center(
                                  child: Text(
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
                                    localizations.translate(pageTitle),
                                    style: theme.textTheme.displayMedium,
                                  ),
                                  BlocBuilder<ProductVariantBloc,
                                      ProductVariantState>(
                                    builder: (context, state) {
                                      return state.maybeWhen(
                                        orElse: () => const Offstage(),
                                        fetched: (productVariants) {
                                          return DigitReactiveDropdown<
                                              ProductVariantModel>(
                                            formControlName: _productVariantKey,
                                            label: localizations.translate(
                                              module.selectProductLabel,
                                            ),
                                            isRequired: true,
                                            valueMapper: (value) {
                                              return localizations.translate(
                                                value.sku ?? value.id,
                                              );
                                            },
                                            menuItems: productVariants,
                                            validationMessages: {
                                              'required': (object) =>
                                                  localizations.translate(
                                                    '${module.selectProductLabel}_IS_REQUIRED',
                                                  ),
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  if ([
                                    StockRecordEntryType.loss,
                                    StockRecordEntryType.damaged,
                                  ].contains(entryType))
                                    DigitReactiveDropdown<TransactionReason>(
                                      label: localizations.translate(
                                        transactionReasonLabel ?? 'Reason',
                                      ),
                                      menuItems: reasons ?? [],
                                      formControlName: _transactionReasonKey,
                                      valueMapper: (value) =>
                                          value.name.titleCase,
                                      isRequired: true,
                                    ),
                                  BlocBuilder<FacilityBloc, FacilityState>(
                                    builder: (context, state) {
                                      final facilities = state.whenOrNull(
                                            fetched: (_, facilities, __) =>
                                                facilities,
                                          ) ??
                                          [];

                                      return InkWell(
                                        onTap: () async {
                                          // clearQRCodes();
                                          // form.control(_deliveryTeamKey).value =
                                          //     '';
                                          final parent = context.router.parent()
                                              as StackRouter;
                                          final facility =
                                              await parent.push<FacilityModel>(
                                            FacilitySelectionRoute(
                                              facilities: facilities,
                                            ),
                                          );

                                          if (facility == null) return;
                                          form
                                              .control(_secondaryPartyKey)
                                              .value = localizations.translate(
                                            '${facility.name}',
                                          );

                                          setState(() {
                                            selectedFacilityId = facility.id;
                                          });
                                          if (facility.id == 'Delivery Team') {
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
                                            label: localizations.translate(
                                              '${pageTitle}_${i18.stockReconciliationDetails.stockLabel}',
                                            ),
                                            isRequired: true,
                                            validationMessages: {
                                              'required': (object) =>
                                                  localizations.translate(
                                                    i18.common
                                                        .corecommonRequired,
                                                  ),
                                            },
                                            suffix: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(Icons.search),
                                            ),
                                            formControlName: _secondaryPartyKey,
                                            onTap: () async {
                                              // clearQRCodes();
                                              // form
                                              //     .control(_deliveryTeamKey)
                                              //     .value = '';
                                              final parent = context.router
                                                  .parent() as StackRouter;
                                              final facility = await parent
                                                  .push<FacilityModel>(
                                                FacilitySelectionRoute(
                                                  facilities: facilities,
                                                ),
                                              );

                                              if (facility == null) return;
                                              form
                                                      .control(_secondaryPartyKey)
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
                                                  deliveryTeamSelected = false;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Visibility(
                                  //   visible: deliveryTeamSelected,
                                  //   child: DigitTextFormField(
                                  //     label: localizations.translate(
                                  //       i18.stockReconciliationDetails
                                  //           .teamCodeLabel,
                                  //     ),
                                  //     onChanged: (val) {
                                  //       String? value = val.value as String?;
                                  //       if (value != null &&
                                  //           value.trim().isNotEmpty) {
                                  //         context.read<ScannerBloc>().add(
                                  //               ScannerEvent.handleScanner(
                                  //                 [],
                                  //                 [value],
                                  //               ),
                                  //             );
                                  //       } else {
                                  //         clearQRCodes();
                                  //       }
                                  //     },
                                  //     suffix: IconButton(
                                  //       onPressed: () {
                                  //         context.router.push(QRScannerRoute(
                                  //           quantity: 5,
                                  //           isGS1code: false,
                                  //           sinlgleValue: false,
                                  //         ));
                                  //       },
                                  //       icon: Icon(
                                  //         Icons.qr_code_2,
                                  //         color: theme.colorScheme.secondary,
                                  //       ),
                                  //     ),
                                  //     isRequired: deliveryTeamSelected,
                                  //     maxLines: 3,
                                  //     formControlName: _deliveryTeamKey,
                                  //   ),
                                  // ),
                                  DigitTextFormField(
                                    formControlName: _transactionQuantityKey,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    isRequired: true,
                                    validationMessages: {
                                      "number": (object) =>
                                          localizations.translate(
                                            '${quantityCountLabel}_VALIDATION',
                                          ),
                                      "max": (object) =>
                                          "${localizations.translate(
                                            '${quantityCountLabel}_MAX_ERROR',
                                          )} $maxStockQuantity",
                                      "min": (object) =>
                                          localizations.translate(
                                            '${quantityCountLabel}_MIN_ERROR',
                                          ),
                                    },
                                    label: localizations.translate(
                                      quantityCountLabel,
                                    ),
                                  ),

                                  // Solution Customizations
                                  // if (isWareHouseMgr)
                                  //   BlocBuilder<AppInitializationBloc,
                                  //       AppInitializationState>(
                                  //     builder: (context, state) =>
                                  //         state.maybeWhen(
                                  //       orElse: () => const Offstage(),
                                  //       initialized: (appConfiguration, _) {
                                  //         final transportTypeOptions =
                                  //             appConfiguration.transportTypes ??
                                  //                 <TransportTypes>[];

                                  //         return DigitReactiveDropdown<String>(
                                  //           isRequired: false,
                                  //           label: localizations.translate(
                                  //             i18.stockDetails
                                  //                 .transportTypeLabel,
                                  //           ),
                                  //           valueMapper: (e) => e,
                                  //           onChanged: (value) {
                                  //             setState(() {
                                  //               form.control(
                                  //                 _typeOfTransportKey,
                                  //               );
                                  //             });
                                  //           },
                                  //           initialValue: transportTypeOptions
                                  //               .firstOrNull?.name,
                                  //           menuItems: transportTypeOptions.map(
                                  //             (e) {
                                  //               return localizations
                                  //                   .translate(e.name);
                                  //             },
                                  //           ).toList(),
                                  //           formControlName:
                                  //               _typeOfTransportKey,
                                  //         );
                                  //       },
                                  //     ),
                                  //   ),
                                  // if (isWareHouseMgr)
                                  //   DigitTextFormField(
                                  //     label: localizations.translate(
                                  //       i18.stockDetails.vehicleNumberLabel,
                                  //     ),
                                  //     formControlName: _vehicleNumberKey,
                                  //   ),
                                  DigitTextFormField(
                                    label: localizations.translate(
                                      i18.stockDetails.commentsLabel,
                                    ),
                                    minLines: 2,
                                    maxLines: 3,
                                    formControlName: _commentsKey,
                                  ),
                                  // Impel Customization
                                  // DigitOutlineIconButton(
                                  //   buttonStyle: OutlinedButton.styleFrom(
                                  //     shape: const RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.zero,
                                  //     ),
                                  //   ),
                                  //   onPressed: () {
                                  //     context.router.push(QRScannerRoute(
                                  //       quantity: 5,
                                  //       isGS1code: true,
                                  //       sinlgleValue: false,
                                  //     ));
                                  //   },
                                  //   icon: Icons.qr_code,
                                  //   label: localizations.translate(
                                  //     i18.common.scanBales,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<FacilityModel> getFilteredFacilities(
    List<FacilityModel> facilities,
    String? boundaryType,
    String requiredBoundaryType,
  ) {
    List<FacilityModel> filteredFacilities = [];

    for (FacilityModel facility in facilities) {
      FacilityAdditionalFields? additionalFields = facility.additionalFields;
      if (additionalFields != null) {
        bool hasRequiredKey = additionalFields.fields
            .any((field) => field.key == requiredBoundaryType);
        if (hasRequiredKey) {
          bool hasBoundaryType = additionalFields.fields.any((field) =>
              field.key == requiredBoundaryType && field.value == boundaryType);
          if (hasBoundaryType) {
            filteredFacilities.add(facility);
          }
        } else {
          filteredFacilities.add(facility);
        }
      } else {
        filteredFacilities.add(facility);
      }
    }

    return filteredFacilities;
  }

  void clearQRCodes() {
    context.read<ScannerBloc>().add(const ScannerEvent.handleScanner([], []));
  }

  num _getQuantityCount(Iterable<StockModel> stocks) {
    return stocks.fold<num>(
      0.0,
      (old, e) => (num.tryParse(e.quantity ?? '') ?? 0.0) + old,
    );
  }
}
