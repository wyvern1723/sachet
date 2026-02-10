import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/score_pdf_page_zf_provider.dart';

class ScorePdfTypesSelectorZF extends StatelessWidget {
  /// 成绩单打印页面（正方教务）选择成绩单格式的 DropDownMenu
  const ScorePdfTypesSelectorZF({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    String selectedScorePdfType =
        context.select<ScorePdfPageZFProvider, String>(
            (provider) => provider.selectedScorePdfType);
    Map scorePdfTypes = context.select<ScorePdfPageZFProvider, Map>(
        (provider) => provider.scorePdfTypes);
    bool isShowDropDownMenuError = context.select<ScorePdfPageZFProvider, bool>(
        (provider) => provider.isShowDropDownMenuError);

    return DropdownMenu<String>(
      width: width,
      menuHeight: 600,
      initialSelection: selectedScorePdfType,
      errorText: isShowDropDownMenuError ? "请选择一项" : null,
      requestFocusOnTap: false,
      label: const Text('成绩单格式'),
      onSelected: (String? value) {
        if (value != null) {
          context.read<ScorePdfPageZFProvider>().changeScorePdfType(value);
          context
              .read<ScorePdfPageZFProvider>()
              .changeIsShowDropDownMenuError(false);
        }
      },
      dropdownMenuEntries: scorePdfTypes.entries
          .map((e) => DropdownMenuEntry<String>(value: e.value, label: e.key))
          .toList(),
    );
  }
}
