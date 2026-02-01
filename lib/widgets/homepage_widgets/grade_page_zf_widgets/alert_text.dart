import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/grade_page_zf_provider.dart';

class AlertTextZF extends StatelessWidget {
  const AlertTextZF({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> alertTexts = context.select<GradePageZFProvider, List<String>>(
        (provider) => provider.alertTexts);
    if (alertTexts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: alertTexts
          .map(
            (alertText) => Text(
              alertText,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFFC26664)
                    : Color(0xFFA94442),
                fontSize: 12,
              ),
            ),
          )
          .toList(),
    );
  }
}
