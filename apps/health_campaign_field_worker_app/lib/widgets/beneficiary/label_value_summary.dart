// import 'package:digit_ui_components/digit_components.dart';
// import 'package:digit_ui_components/theme/digit_extended_theme.dart';
// import 'package:digit_ui_components/widgets/helper_widget/button_list.dart';
// import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
// import 'package:flutter/material.dart';
// import '../atoms/label_value_list.dart';

import 'package:digit_components/digit_components.dart';
import 'package:flutter/material.dart';
import 'package:health_campaign_field_worker_app/widgets/beneficiary/label_value_item.dart';

class LabelValueSummary extends StatelessWidget {
  final String? heading;
  final TextStyle? headingStyle;
  final List<LabelValueItem> items;
  final EdgeInsets? padding;
  final bool withDivider;
  final List<DigitOutLineButton>? action;
  final bool withCard;

  const LabelValueSummary({
    super.key,
    this.heading,
    this.headingStyle,
    required this.items,
    this.padding,
    this.withDivider = false,
    this.action,
    this.withCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    const bool isMobile = true;

    Widget content = Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: withCard ? 0 : isMobile ? 32 : 48, horizontal: withCard ? 0 : isMobile ? 32:48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                heading!,
                style: headingStyle ?? textTheme.headlineLarge!.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ..._buildItemsWithDividers(),
        ],
      ),
    );

    // Wrap the content in a Card if withCard is true
    if (withCard) {
      content = DigitCard(
        child: content,
      );
    }

    return content;
  }

  List<Widget> _buildItemsWithDividers() {
    List<Widget> itemList = [];
    for (int i = 0; i < items.length; i++) {
      itemList.add(items[i]);
      if (i < items.length - 1 && withDivider) {
        itemList.add(
          const Divider(),
        );
      }
    }
    return itemList;
  }
}
