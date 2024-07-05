import 'package:digit_components/digit_components.dart';
import 'package:digit_components/models/digit_table_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/delivery_intervention/deliver_intervention.dart';
import '../../../blocs/localization/app_localization.dart';
import '../../../blocs/project/project.dart';
import '../../../models/data_model.dart';
import '../../../utils/i18_key_constants.dart' as i18;
import '../../../utils/utils.dart';

// This function builds a table with the given data and headers
Widget buildTableContent(
  DeliverInterventionState deliverInterventionState,
  BuildContext context,
  List<ProductVariantModel>? variant,
  IndividualModel? individualModel,
) {
  // Calculate the current cycle. If deliverInterventionState.cycle is negative, set it to 0.
  final currentCycle =
      deliverInterventionState.cycle >= 0 ? deliverInterventionState.cycle : 0;

  // Calculate the current dose. If deliverInterventionState.dose is negative, set it to 0.
  final currentDose =
      deliverInterventionState.dose >= 0 ? deliverInterventionState.dose : 0;
  final localizations = AppLocalizations.of(context);

  // Defining a list of table headers for resource popup
  final headerListResource = [
    TableHeader(
      localizations.translate(i18.beneficiaryDetails.beneficiaryDose),
      cellKey: 'dose',
    ),
    TableHeader(
      localizations.translate(i18.beneficiaryDetails.beneficiaryResources),
      cellKey: 'resources',
    ),
  ];

  // Calculate the height of the container based on the number of items in the table

  final projectState = context.read<ProjectBloc>().state;
  final item = projectState
      .projectType!.cycles![currentCycle - 1].deliveries![currentDose - 1];
  final productVariants =
      fetchProductVariant(item, individualModel)?.productVariants;
  final numRows = productVariants?.length ?? 0;
  const rowHeight = 82;
  const paddingHeight = kPadding * 2;
  final containerHeight = (numRows + 1) * rowHeight + paddingHeight;

  return Container(
    padding: const EdgeInsets.only(
      left: kPadding,
      bottom: 0,
      right: kPadding,
      top: 0,
    ),
    // [TODO - need to set the height of the card based on the number of items]
    height: containerHeight,
    width: MediaQuery.of(context).size.width / 1.25,
    child: BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, projectState) {
        // BlocBuilder to get project data based on the current cycle and dose
        final item = projectState.projectType!.cycles![currentCycle - 1]
            .deliveries![currentDose - 1];
        final productVariants =
            fetchProductVariant(item, individualModel)!.productVariants ?? [];

        String resource = '';

        if (variant != null && productVariants.isNotEmpty) {
          final skuList = productVariants.map(
            (e) => variant
                .firstWhere(
                  (element) => element.id == e.productVariantId,
                )
                .sku,
          );

          resource = skuList.join('+');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            DigitTableCard(
              topPadding: const EdgeInsets.only(top: 0.0),
              padding: const EdgeInsets.only(bottom: kPadding / 2),
              fraction: 2.5,
              element: {
                localizations.translate(
                  i18.beneficiaryDetails.beneficiaryAge,
                  //[TODO: Condition need to be handled in generic way,]
                ): '${fetchProductVariant(item, individualModel)?.condition?.split('<=age<').first} - ${fetchProductVariant(item, individualModel)?.condition?.split('<=age<').last} ${localizations.translate(i18.common.monthsLabel)}',
              },
            ),
            const Divider(
              thickness: 1.0,
            ),
            // Build the DigitTable with the data
            DigitTable(
              headerList: headerListResource,
              columnRowFixedHeight: 78,
              tableData: [
                TableDataRow([
                  // Display the dose information in the first column if it's the first row,
                  // otherwise, display an empty cell.

                  TableData(
                    '${localizations.translate(i18.beneficiaryDetails.beneficiaryDeliveryText)} ${deliverInterventionState.dose}',
                    cellKey: 'dose',
                  ),
                  // Display the SKU value in the second column.
                  TableData(
                    '${localizations.translate(resource.toString())}${deliverInterventionState.dose == 1 ? '(SP + AQ)' : '(AQ)'}',
                    cellKey: 'resources',
                  ),
                ]),
              ],
              columnWidth: 152,
              height: 150,
            ),
          ],
        );
      },
    ),
  );
}
