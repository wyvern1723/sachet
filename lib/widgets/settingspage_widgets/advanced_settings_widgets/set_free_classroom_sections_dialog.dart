import 'package:flutter/material.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:provider/provider.dart';

List<int> items = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

class SetFreeClassroomSectionsDialog extends StatefulWidget {
  const SetFreeClassroomSectionsDialog({super.key});

  @override
  State<SetFreeClassroomSectionsDialog> createState() =>
      _SetFreeClassroomSectionsDialogState();
}

class _SetFreeClassroomSectionsDialogState
    extends State<SetFreeClassroomSectionsDialog> {
  final List<int> _items = List.generate(11, (i) => i + 1);

  List _splitedSections = [];

  List<bool> _isClip = List.filled(11, false);

  /// 根据 _isClip 生成 _splitedSections
  void _split() {
    int startIndex = 0;
    _splitedSections.clear();
    for (var i = 0; i < _isClip.length; i++) {
      if (_isClip[i] == true) {
        _splitedSections.add(_items.sublist(startIndex, i + 1));
        startIndex = i + 1;
      }
    }
    _splitedSections.add(_items.sublist(startIndex, _items.length));
  }

  /// 根据 _splitedSections 生成 _isClip
  void _getClips() {
    int lastIndex = 0;
    List<List<int>> convertedList =
        _splitedSections.map((innerList) => List<int>.from(innerList)).toList();
    // 去掉最后一项的 List
    final List<List<int>> cuttedEndList =
        convertedList.take(convertedList.length - 1).toList();
    for (final section in cuttedEndList) {
      int splitIndex = lastIndex + section.length - 1;
      _isClip[splitIndex] = true;
      lastIndex = splitIndex + 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _splitedSections =
        List.from(context.read<SettingsProvider>().freeClassroomSections);
    _getClips();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置查询节次分段'),
      contentPadding: EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        right: 16.0,
        bottom: 12.0,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '节次分段：${_splitedSections.join(',  ')}',
              style: TextStyle(fontSize: 16),
            ),
            Text('注意：分段越多，网络请求越慢'),
            SizedBox(height: 16),
            SizedBox(
              height: (_items.length * 54 + 20).toDouble(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ..._items.map((e) => Positioned(
                      top: ((e - 1) * 54).toDouble(),
                      left: 30,
                      width: 140,
                      height: 36,
                      child: _buildItemContainer(e))),
                  for (var i = 0; i < _isClip.length; i++)
                    _isClip[i] == true
                        ?
                        // 实线
                        Positioned(
                            top: ((i + 1) * 54 - 9 - (3 / 2)).toDouble(),
                            left: 10,
                            width: 186,
                            height: 3,
                            child: Container(
                              color: Colors.grey.shade600,
                            ),
                          )
                        :
                        // 虚线
                        Positioned(
                            top: ((i + 1) * 54 - 9 - (2 / 2)).toDouble(),
                            left: 24,
                            width: 160,
                            height: 2,
                            child: CustomPaint(
                              size: const Size(double.infinity, 2),
                              painter: DashedLinePainter(),
                            ),
                          ),
                  for (var i = 0; i < _isClip.length; i++)
                    Positioned(
                      top: ((i + 1) * 54 - 9 - (24)).toDouble(),
                      left: 204,
                      child: IconButton.filledTonal(
                        onPressed: () {
                          setState(() {
                            _isClip[i] = !_isClip[i];
                            _split();
                          });
                        },
                        icon:
                            Icon(_isClip[i] == true ? Icons.remove : Icons.add),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context
                .read<SettingsProvider>()
                .setFreeClassroomSections(_splitedSections);
          },
          child: const Text('确认'),
        )
      ],
    );
  }

  Widget _buildItemContainer(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$index',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

// 用于绘制虚线的 CustomPainter
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
