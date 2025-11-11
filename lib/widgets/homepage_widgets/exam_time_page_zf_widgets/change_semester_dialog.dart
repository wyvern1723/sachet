import 'package:flutter/material.dart';

class ChangeSemesterDialogZF extends StatefulWidget {
  /// 考试时间查询页面（正方教务），改变当前要查询学期 Dialog
  const ChangeSemesterDialogZF({
    super.key,
    required this.semestersYears,
    required this.selectedSemesterYear,
    required this.selectedSemesterIndex,
  });
  final Map semestersYears;
  final String selectedSemesterYear;
  final String selectedSemesterIndex;
  @override
  State<ChangeSemesterDialogZF> createState() => _ChangeSemesterDialogZFState();
}

class _ChangeSemesterDialogZFState extends State<ChangeSemesterDialogZF> {
  String _selectedSemesterYear = '';
  String _selectedSemesterIndex = '';
  final Map semesterIndexes = {"全部": "", "1": "3", "2": "12", "3": "16"};

  @override
  void initState() {
    super.initState();
    _selectedSemesterYear = widget.selectedSemesterYear;
    _selectedSemesterIndex = widget.selectedSemesterIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('切换查询学期'),
      content: Wrap(
        spacing: 8,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          DropdownMenu<String>(
            width: 160,
            menuHeight: 400,
            initialSelection: widget.selectedSemesterYear,
            requestFocusOnTap: false,
            label: const Text('学年'),
            onSelected: (String? semester) {
              if (semester != null) {
                _selectedSemesterYear = semester;
              }
            },
            dropdownMenuEntries: widget.semestersYears.entries
                .map((e) =>
                    DropdownMenuEntry<String>(value: e.value, label: e.key))
                .toList(),
          ),
          DropdownMenu<String>(
            width: 110,
            menuHeight: 400,
            initialSelection: widget.selectedSemesterIndex,
            requestFocusOnTap: false,
            label: const Text('学期'),
            onSelected: (String? semester) {
              if (semester != null) {
                _selectedSemesterIndex = semester;
              }
            },
            dropdownMenuEntries: semesterIndexes.entries
                .map((e) =>
                    DropdownMenuEntry<String>(value: e.value, label: e.key))
                .toList(),
          ),
        ],
      ),
      contentPadding: EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 24.0),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
                context, [_selectedSemesterYear, _selectedSemesterIndex]);
          },
          child: const Text('确认'),
        )
      ],
    );
  }
}
