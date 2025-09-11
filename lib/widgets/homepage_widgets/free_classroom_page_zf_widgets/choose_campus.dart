import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/providers/free_classroom_page_zf_provider.dart';
import 'package:sachet/widgets/homepage_widgets/free_classroom_page_zf_widgets/rounded_rectangle_container.dart';

class ChooseCampus extends StatelessWidget {
  /// 选择校区
  const ChooseCampus({super.key});

  @override
  Widget build(BuildContext context) {
    String selectedCampus = context.select<FreeClassroomPageZFProvider, String>(
        (freeClassroomPageZFProvider) =>
            freeClassroomPageZFProvider.selectedCampus);
    return RoundedRectangleContainer(
      title: Text(
        '校区',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      direction: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
        child: SegmentedButton(
          segments: campusTypeMap.entries.map((e) {
            return ButtonSegment<String>(
              value: e.value,
              label: Text(
                e.key,
                style: TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          selected: <String>{selectedCampus},
          onSelectionChanged: (Set<String> campus) {
            context
                .read<FreeClassroomPageZFProvider>()
                .setSelectedCampus(campus.first);
          },
        ),
      ),
    );
  }
}
