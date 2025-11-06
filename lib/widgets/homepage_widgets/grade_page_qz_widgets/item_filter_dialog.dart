import 'package:flutter/material.dart';

class ItemFilterDialogQZ extends StatefulWidget {
  /// 成绩查询详细页面（强智教务）的筛选显示字段的 Dialog
  const ItemFilterDialogQZ({
    super.key,
    required this.items,
    required this.selectedItems,
  });
  final List<String> items;
  final List<String> selectedItems;

  @override
  State<ItemFilterDialogQZ> createState() => _ItemFilterDialogQZState();
}

class _ItemFilterDialogQZState extends State<ItemFilterDialogQZ> {
  late List<String> _selectedItems;
  late List<String> _items;

  void _filtersChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  @override
  void initState() {
    _selectedItems = List.of(widget.selectedItems);
    _items = List.of(widget.items);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.only(top: 16),
      title: const Text("选择显示项目"),
      clipBehavior: Clip.hardEdge, // 如果不设置，长按的水波效果会超出 dialog
      content: SizedBox(
        width: 200,
        child: ReorderableListView(
          shrinkWrap: true,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final String item = _items.removeAt(oldIndex);
              _items.insert(newIndex, item);
            });
          },
          // buildDefaultDragHandles: false,
          children: _items.map((item) {
            switch (Theme.of(context).platform) {
              case TargetPlatform.linux:
              case TargetPlatform.windows:
              case TargetPlatform.macOS:
                return CheckboxListTile(
                  key: Key(item),
                  value: _selectedItems.contains(item),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) {
                    if (isChecked != null) {
                      _filtersChange(item, isChecked);
                    }
                  },
                  title: Text(item),
                );

              case TargetPlatform.android:
              case TargetPlatform.iOS:
              case TargetPlatform.fuchsia:
                return CheckboxListTile(
                  key: Key(item),
                  value: _selectedItems.contains(item),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) {
                    if (isChecked != null) {
                      _filtersChange(item, isChecked);
                    }
                  },
                  title: Text(item),
                  secondary: const Icon(Icons.drag_handle),
                );
            }
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, [_selectedItems, _items]),
          child: const Text('确认'),
        ),
      ],
    );
  }
}
