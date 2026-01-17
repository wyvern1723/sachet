import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:sachet/pages/settings_child_pages/palette_adjust_page.dart';
import 'package:sachet/utils/custom_route.dart';
import 'package:path/path.dart' as path;

class PaletteCard extends StatelessWidget {
  const PaletteCard({
    super.key,
    required this.filePath,
    required this.courseColorData,
    required this.refresh,
  });
  final String filePath;
  final Map courseColorData;
  final ValueChanged<bool> refresh;

  @override
  Widget build(BuildContext context) {
    List<Color?> paletteColor = [];
    if (courseColorData.isNotEmpty) {
      courseColorData.values
          .forEach((e) => paletteColor.add(e.toString().toColor()));
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              path.basename(filePath),
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              // alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 8,
              direction: Axis.horizontal,
              children: [
                ...List.generate(
                  paletteColor.length,
                  (index) => ClipRRect(
                    borderRadius: BorderRadius.circular(90.0),
                    child: Container(
                      height: 46,
                      width: 46,
                      color: paletteColor[index],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TextButton(onPressed: () {}, child: const Text('克隆')),
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context)
                        .push(slideTransitionPageRoute(PaletteAdjustPage(
                      colorFilePath: filePath,
                      courseColorData: courseColorData,
                    )));
                    refresh(true);
                  },
                  child: const Text('修改'),
                ),
                // TextButton(onPressed: () {}, child: const Text('应用')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
