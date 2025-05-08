import 'dart:io';

import 'package:flutter/material.dart';

class ShowcasePaletteCard extends StatelessWidget {
  // 展示应用随机分配颜色的 palette 的 Card
  const ShowcasePaletteCard({
    super.key,
    required this.paletteTitle,
    required this.paletteColor,
  });
  final String paletteTitle;
  final List<Color?> paletteColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paletteTitle.split(Platform.pathSeparator).last,
              style: TextStyle(fontSize: 19),
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
          ],
        ),
      ),
    );
  }
}
