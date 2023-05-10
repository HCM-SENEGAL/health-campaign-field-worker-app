import 'package:digit_components/digit_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/inventory_report/inventory_report.dart';
import '../../../models/data_model.dart';
import '../../../router/app_router.dart';
import '../../../utils/i18_key_constants.dart' as i18;
import '../../../utils/utils.dart';
import '../../../widgets/header/back_navigation_help_header.dart';
import '../../../widgets/localized.dart';
import '../../../widgets/reports/readonly_pluto_grid.dart';

class InventoryReportDetailsPage extends LocalizedStatefulWidget
    with AutoRouteWrapper {
  final InventoryReportType reportType;

  const InventoryReportDetailsPage({
    Key? key,
    super.appLocalizations,
    required this.reportType,
  }) : super(key: key);

  @override
  State<InventoryReportDetailsPage> createState() =>
      _InventoryReportDetailsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final event = reportType == InventoryReportType.reconciliation
            ? const InventoryReportLoadStockReconciliationDataEvent()
            : InventoryReportLoadStockDataEvent(reportType: reportType);

        return InventoryReportBloc(
          stockReconciliationRepository: context.repository<
              StockReconciliationModel, StockReconciliationSearchModel>(),
          stockRepository: context.repository<StockModel, StockSearchModel>(),
        )..add(event);
      },
      child: this,
    );
  }
}

class _InventoryReportDetailsPageState
    extends LocalizedState<InventoryReportDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<InventoryReportBloc, InventoryReportState>(
        builder: (context, inventoryReportState) {
          return Column(
            children: [
              const BackNavigationHelpHeaderWidget(),
              const SizedBox(height: kPadding * 2),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _ReportDetailsContent(title: title),
                ),
              ),
              const SizedBox(height: kPadding * 2),
              DigitCard(
                margin: EdgeInsets.zero,
                child: DigitElevatedButton(
                  onPressed: () => context.router.popUntilRoot(),
                  child: Text(
                    i18.inventoryReportDetails.backToHomeButtonLabel,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String get title {
    switch (widget.reportType) {
      case InventoryReportType.receipt:
        return i18.inventoryReportDetails.receiptReportTitle;
      case InventoryReportType.dispatch:
        return i18.inventoryReportDetails.dispatchReportTitle;
      case InventoryReportType.returned:
        return i18.inventoryReportDetails.returnedReportTitle;
      case InventoryReportType.damage:
        return i18.inventoryReportDetails.damageReportTitle;
      case InventoryReportType.loss:
        return i18.inventoryReportDetails.lossReportTitle;
      case InventoryReportType.reconciliation:
        return i18.inventoryReportDetails.reconciliationReportTitle;
    }
  }
}

class _ReportDetailsContent extends StatelessWidget {
  final String title;
  final DigitGridData data;

  const _ReportDetailsContent({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kPadding * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: kPadding * 2),
          Flexible(
            child: ReadonlyDigitGrid(
              data: data,
            ),
          ),
        ],
      ),
    );
  }
}