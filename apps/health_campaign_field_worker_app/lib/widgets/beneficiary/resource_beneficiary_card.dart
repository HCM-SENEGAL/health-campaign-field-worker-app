import 'package:digit_components/digit_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../blocs/product_variant/product_variant.dart';
import '../../models/data_model.dart';
import '../../utils/i18_key_constants.dart' as i18;
import '../localized.dart';

class ResourceBeneficiaryCard extends LocalizedStatefulWidget {
  final void Function(int) onDelete;
  final int cardIndex;
  final FormGroup form;
  final int totalItems;
  final doseIndex;

  const ResourceBeneficiaryCard({
    Key? key,
    super.appLocalizations,
    required this.onDelete,
    required this.cardIndex,
    required this.form,
    required this.totalItems,
    required this.doseIndex,
  }) : super(key: key);

  @override
  State<ResourceBeneficiaryCard> createState() =>
      _ResourceBeneficiaryCardState();
}

class _ResourceBeneficiaryCardState
    extends LocalizedState<ResourceBeneficiaryCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DigitTheme.instance.colorScheme.surface,
        border: Border.all(
          color: DigitTheme.instance.colorScheme.outline,
          width: 1,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(4.0),
        ),
      ),
      margin: const EdgeInsets.only(
        top: kPadding,
        bottom: kPadding,
      ),
      padding: const EdgeInsets.all(kPadding),
      child: Column(
        children: [
          BlocBuilder<ProductVariantBloc, ProductVariantState>(
            builder: (context, productState) {
              return productState.maybeWhen(
                orElse: () => const Offstage(),
                fetched: (productVariants) {
                  return DigitReactiveSearchDropdown<ProductVariantModel>(
                    label: localizations.translate(
                      i18.deliverIntervention.resourceDeliveredLabel,
                    ),
                    enabled: false,
                    form: widget.form,
                    menuItems: productVariants,
                    formControlName: 'resourceDelivered.${widget.cardIndex}',
                    valueMapper: (value) {
                      final doseString =
                          widget.doseIndex == 1 ? '(SP + AQ)' : '(AQ)';
                      if (widget.totalItems > 1) {
                        final skuList = productVariants.map(
                          (e) => e.sku,
                        );

                        return skuList.join(' + ') + doseString;
                      }

                      return localizations.translate(
                        (value.sku ?? value.id) + doseString,
                      );
                    },
                    isRequired: true,
                    validationMessage: localizations.translate(
                      i18.common.corecommonRequired,
                    ),
                    emptyText: localizations.translate(i18.common.noMatchFound),
                  );
                },
              );
            },
          ),
          DigitIntegerFormPicker(
            incrementer: true,
            formControlName: 'quantityUtilised.${widget.cardIndex}',
            form: widget.form,
            label: localizations.translate(
              i18.deliverIntervention.quantityUtilisedLabel,
            ),
            minimum: 1,
            maximum: 2,
          ),
          DigitIntegerFormPicker(
            incrementer: true,
            formControlName: 'quantityDistributed.${widget.cardIndex}',
            form: widget.form,
            label: localizations.translate(
              i18.deliverIntervention.quantityDistributedLabel,
            ),
            minimum: 0,
            maximum: 1,
          ),

          // DigitTextFormField(
          //   formControlName: 'quantityWasted.${widget.cardIndex}',
          //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
          //   inputFormatters: [
          //     FilteringTextInputFormatter.allow(
          //       RegExp(r'^\d*\.?(0|5)?$'),
          //     ),
          //   ],
          //   label: localizations.translate(
          //     i18.deliverIntervention.quantityWastedLabel,
          //   ),
          //   validationMessages: {
          //     "required": (control) {
          //       return localizations.translate(
          //         i18.common.corecommonRequired,
          //       );
          //     },
          //   },
          // ),

          // Solution customization
          // SizedBox(
          //   child: Align(
          //     alignment: Alignment.centerLeft,
          //     child: (widget.cardIndex == widget.totalItems - 1 &&
          //             widget.totalItems > 1)
          //         ? DigitIconButton(
          //             onPressed: () async {
          //               final submit = await DigitDialog.show<bool>(
          //                 context,
          //                 options: DigitDialogOptions(
          //                   titleText: localizations.translate(
          //                     i18.deliverIntervention
          //                         .resourceDeleteBeneficiaryDialogTitle,
          //                   ),
          //                   primaryAction: DigitDialogActions(
          //                     label: localizations.translate(
          //                       i18.deliverIntervention
          //                           .resourceDeleteBeneficiaryPrimaryActionLabel,
          //                     ),
          //                     action: (context) {
          //                       Navigator.of(
          //                         context,
          //                         rootNavigator: true,
          //                       ).pop(true);
          //                     },
          //                   ),
          //                   secondaryAction: DigitDialogActions(
          //                     label: localizations.translate(
          //                       i18.common.coreCommonCancel,
          //                     ),
          //                     action: (context) => Navigator.of(
          //                       context,
          //                       rootNavigator: true,
          //                     ).pop(false),
          //                   ),
          //                 ),
          //               );
          //               if (submit == true) {
          //                 widget.onDelete(widget.cardIndex);
          //               }
          //             },
          //             iconText: localizations.translate(
          //               i18.deliverIntervention.resourceDeleteBeneficiary,
          //             ),
          //             icon: Icons.delete,
          //           )
          //         : const Offstage(),
          //   ),
          // ),
        ],
      ),
    );
  }
}
