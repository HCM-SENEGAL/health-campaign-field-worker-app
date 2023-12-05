import 'package:collection/collection.dart';
import 'package:digit_components/digit_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../blocs/facility/facility.dart';
import '../../../blocs/product_variant/product_variant.dart';
import '../../../blocs/record_stock/record_stock.dart';
import '../../../models/data_model.dart';
import '../../../router/app_router.dart';
import '../../../utils/i18_key_constants.dart' as i18;
import '../../../utils/utils.dart';
import '../../../widgets/header/back_navigation_help_header.dart';
import '../../../widgets/localized.dart';
import '../facility_selection.dart';

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
  static const _transactingPartyKey = 'transactingParty';
  static const _transactionQuantityKey = 'quantity';
  static const _commentsKey = 'comments';
  static const _waybillNumberKey = 'waybillNumber';
  static const _waybillQuantityKey = 'waybillQuantity';

  FormGroup _form() {
    return fb.group({
      _productVariantKey: FormControl<ProductVariantModel>(
        validators: [Validators.required],
      ),
      _transactingPartyKey: FormControl<FacilityModel>(
        validators: [Validators.required],
      ),
      _transactionQuantityKey: FormControl<int>(validators: [
        Validators.number,
        Validators.required,
        Validators.min(0),
        Validators.max(10000000),
      ]),
      _waybillNumberKey: FormControl<String>(
        validators: [Validators.required],
      ),
      _waybillQuantityKey: FormControl<int>(
        validators: [
          Validators.number,
          Validators.required,
          Validators.min(0),
          Validators.max(10000000),
        ],
      ),
      _commentsKey: FormControl<String>(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
              TransactionType transactionType;
              TransactionReason? transactionReason;

              List<TransactionReason>? reasons;

              switch (entryType) {
                case StockRecordEntryType.receipt:
                  pageTitle = module.receivedPageTitle;
                  transactionPartyLabel = module.selectTransactingPartyReceived;
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
                  transactionPartyLabel = module.selectTransactingPartyReturned;
                  quantityCountLabel = module.quantityReturnedLabel;
                  transactionType = TransactionType.received;
                  break;
                case StockRecordEntryType.loss:
                  pageTitle = module.lostPageTitle;
                  transactionPartyLabel =
                      module.selectTransactingPartyReceivedFromLost;
                  quantityCountLabel = module.quantityLostLabel;
                  transactionType = TransactionType.dispatched;
                  transactionReasonLabel = module.transactionReasonLost;
                  reasons = [
                    TransactionReason.lostInStorage,
                    TransactionReason.lostInTransit,
                  ];
                  break;
                case StockRecordEntryType.damaged:
                  pageTitle = module.damagedSpaqDetails;
                  transactionPartyLabel =
                      module.selectTransactingPartyReceivedFromDamaged;
                  quantityCountLabel = module.quantityDamagedLabel;
                  transactionType = TransactionType.dispatched;
                  transactionReasonLabel = module.transactionReasonDamaged;
                  reasons = [
                    TransactionReason.damagedInStorage,
                    TransactionReason.damagedInTransit,
                  ];
                  break;
              }

              transactionReasonLabel ??= '';
              debugPrint(transactionPartyLabel);

              return ReactiveFormBuilder(
                form: _form,
                builder: (context, form, child) {
                  return ScrollableContent(
                    header: const Column(children: [
                      BackNavigationHelpHeaderWidget(),
                    ]),
                    footer: SizedBox(
                      height: 85,
                      child: DigitCard(
                        margin:
                            const EdgeInsets.only(left: 0, right: 0, top: 10),
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
                                        transactionReason = null;
                                        break;
                                    }

                                    final transactingParty = form
                                        .control(_transactingPartyKey)
                                        .value as FacilityModel;

                                    final quantity = form
                                        .control(_transactionQuantityKey)
                                        .value;

                                    final waybillNumber = form
                                        .control(_waybillNumberKey)
                                        .value as String?;

                                    final waybillQuantity =
                                        form.control(_waybillQuantityKey).value;

                                    final lat = locationState.latitude;
                                    final lng = locationState.longitude;

                                    final hasLocationData =
                                        lat != null && lng != null;

                                    final comments = form
                                        .control(_commentsKey)
                                        .value as String?;

                                    String? transactingPartyType;

                                    final fields = transactingParty
                                        .additionalFields?.fields;

                                    if (fields != null && fields.isNotEmpty) {
                                      final type = fields.firstWhereOrNull(
                                        (element) => element.key == 'type',
                                      );
                                      final value = type?.value;
                                      if (value != null &&
                                          value is String &&
                                          value.isNotEmpty) {
                                        transactingPartyType = value;
                                      }
                                    }

                                    transactingPartyType ??= 'WAREHOUSE';

                                    final stockModel = StockModel(
                                      clientReferenceId: IdGen.i.identifier,
                                      productVariantId: productVariant.id,
                                      transactingPartyId: transactingParty.id,
                                      transactingPartyType:
                                          transactingPartyType,
                                      transactionType: transactionType,
                                      transactionReason: transactionReason,
                                      referenceId: stockState.projectId,
                                      referenceIdType: 'PROJECT',
                                      quantity: quantity.toString(),
                                      waybillNumber: waybillNumber,
                                      auditDetails: AuditDetails(
                                        createdBy: context.loggedInUserUuid,
                                        createdTime:
                                            context.millisecondsSinceEpoch(),
                                      ),
                                      clientAuditDetails: ClientAuditDetails(
                                        createdBy: context.loggedInUserUuid,
                                        createdTime:
                                            context.millisecondsSinceEpoch(),
                                        lastModifiedBy:
                                            context.loggedInUserUuid,
                                        lastModifiedTime:
                                            context.millisecondsSinceEpoch(),
                                      ),
                                      additionalFields: [
                                                waybillQuantity,
                                                comments,
                                              ].any((element) =>
                                                  element != null) ||
                                              hasLocationData
                                          ? StockAdditionalFields(
                                              version: 1,
                                              fields: [
                                                if (waybillQuantity != null)
                                                  AdditionalField(
                                                    'waybill_quantity',
                                                    waybillQuantity.toString(),
                                                  ),
                                                if (comments != null)
                                                  AdditionalField(
                                                    'comments',
                                                    comments,
                                                  ),
                                                if (hasLocationData) ...[
                                                  AdditionalField('lat', lat),
                                                  AdditionalField('lng', lng),
                                                ],
                                              ],
                                            )
                                          : null,
                                    );

                                    bloc.add(
                                      RecordStockSaveStockDetailsEvent(
                                        stockModel: stockModel,
                                      ),
                                    );

                                    final submit = await DigitDialog.show<bool>(
                                      context,
                                      options: DigitDialogOptions(
                                        titleText: localizations.translate(
                                          i18.stockDetails.dialogTitle,
                                        ),
                                        contentText: localizations.translate(
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
                                        const RecordStockCreateStockEntryEvent(),
                                      );
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
                            BlocBuilder<FacilityBloc, FacilityState>(
                              builder: (context, state) {
                                final facilities = state.whenOrNull(
                                      fetched: (_, facilities, __) =>
                                          facilities,
                                    ) ??
                                    [];

                                return DigitTextFormField(
                                  valueAccessor: FacilityValueAccessor(
                                    facilities,
                                  ),
                                  label: localizations.translate(
                                    '${pageTitle}_${i18.stockReconciliationDetails.stockLabel}',
                                  ),
                                  isRequired: true,
                                  suffix: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.search),
                                  ),
                                  formControlName: _transactingPartyKey,
                                  readOnly: true,
                                  onTap: () async {
                                    final parent =
                                        context.router.parent() as StackRouter;
                                    final facility =
                                        await parent.push<FacilityModel>(
                                      FacilitySelectionRoute(
                                        facilities: facilities,
                                      ),
                                    );

                                    if (facility == null) return;
                                    form.control(_transactingPartyKey).value =
                                        facility;
                                  },
                                  validationMessages: {
                                    'required': (object) =>
                                        localizations.translate(
                                          i18.common.corecommonRequired,
                                        ),
                                  },
                                );
                              },
                            ),
                            DigitTextFormField(
                              formControlName: _transactionQuantityKey,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              isRequired: true,
                              validationMessages: {
                                "number": (object) => localizations.translate(
                                      '${quantityCountLabel}_VALIDATION',
                                    ),
                                "max": (object) => localizations.translate(
                                      '${quantityCountLabel}_MAX_ERROR',
                                    ),
                                "min": (object) => localizations.translate(
                                      '${quantityCountLabel}_MIN_ERROR',
                                    ),
                              },
                              label: localizations.translate(
                                quantityCountLabel,
                              ),
                            ),
                            DigitTextFormField(
                              label: localizations.translate(
                                i18.stockDetails.waybillNumberLabel,
                              ),
                              isRequired: true,
                              formControlName: _waybillNumberKey,
                              validationMessages: {
                                'required': (object) => localizations.translate(
                                      i18.common.corecommonRequired,
                                    ),
                              },
                            ),
                            DigitTextFormField(
                              label: localizations.translate(
                                i18.stockDetails
                                    .quantityOfProductIndicatedOnWaybillLabel,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              isRequired: true,
                              formControlName: _waybillQuantityKey,
                              validationMessages: {
                                "number": (object) => localizations.translate(
                                      '${i18.stockDetails.quantityOfProductIndicatedOnWaybillLabel}_ERROR',
                                    ),
                                "max": (object) => localizations.translate(
                                      '${quantityCountLabel}_MAX_ERROR',
                                    ),
                                "min": (object) => localizations.translate(
                                      '${quantityCountLabel}_MIN_ERROR',
                                    ),
                              },
                            ),
                            DigitTextFormField(
                              label: localizations.translate(
                                i18.stockDetails.commentsLabel,
                              ),
                              minLines: 2,
                              maxLines: 3,
                              formControlName: _commentsKey,
                            ),
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
      ),
    );
  }
}
