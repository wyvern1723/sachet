import 'package:flutter/material.dart';
import 'package:sachet/provider/grade_page_provider.dart';
import 'package:provider/provider.dart';

class SemesterSelector extends StatelessWidget {
  const SemesterSelector({
    super.key,
    required this.data,
    required this.menuHeight,
    required this.initialSelection,
  });
  final Map data;
  final double menuHeight;
  final String initialSelection;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      menuHeight: menuHeight,
      initialSelection: initialSelection,
      requestFocusOnTap: false,
      label: const Text('学期'),
      onSelected: (String? date) {
        if (date != null) {
          context.read<GradePageProvider>().changeSemester(date);
        }
      },
      dropdownMenuEntries: data.entries
          .map((e) => DropdownMenuEntry<String>(
                value: e.value,
                label: e.key,
              ))
          .toList(),
    );
  }
}

//选择日期（学期）的 Widget
enum DateLabel {
  semester7('全部'),
  semester6('2023-2024 2'),
  semester5('2023-2024 1'),
  semester4('2022-2023 2'),
  semester3('2022-2023 1'),
  semester2('2021-2022 1'),
  semester1('2021-2022 2');

  const DateLabel(this.label);
  final String label;
}

const mapData = {
  "---请选择---": "",
  "2024-2025-2": "2024-2025-2",
  "2024-2025-1": "2024-2025-1",
  "2023-2024-2": "2023-2024-2",
  "2023-2024-1": "2023-2024-1",
  "2022-2023-2": "2022-2023-2",
  "2022-2023-1": "2022-2023-1",
  "2021-2022-2": "2021-2022-2",
  "2021-2022-1": "2021-2022-1",
  "2020-2021-2": "2020-2021-2",
  "2020-2021-1": "2020-2021-1",
  "2019-2020-2": "2019-2020-2",
  "2019-2020-1": "2019-2020-1",
  "2018-2019-2": "2018-2019-2",
  "2018-2019-1": "2018-2019-1",
  "2017-2018-2": "2017-2018-2",
  "2017-2018-1": "2017-2018-1",
  "2016-2017-2": "2016-2017-2",
  "2016-2017-1": "2016-2017-1",
  "2015-2016-2": "2015-2016-2",
  "2015-2016-1": "2015-2016-1",
  "2014-2015-2": "2014-2015-2",
  "2014-2015-1": "2014-2015-1",
  "2013-2014-2": "2013-2014-2",
  "2013-2014-1": "2013-2014-1",
  "2012-2013-2": "2012-2013-2",
  "2012-2013-1": "2012-2013-1",
  "2011-2012-2": "2011-2012-2",
  "2011-2012-1": "2011-2012-1",
  "2010-2011-2": "2010-2011-2",
  "2010-2011-1": "2010-2011-1",
  "2009-2010-2": "2009-2010-2",
  "2009-2010-1": "2009-2010-1",
  "2008-2009-2": "2008-2009-2",
  "2008-2009-1": "2008-2009-1",
  "2007-2008-2": "2007-2008-2",
  "2007-2008-1": "2007-2008-1",
  "2006-2007-2": "2006-2007-2",
  "2006-2007-1": "2006-2007-1",
  "2005-2006-2": "2005-2006-2",
  "2005-2006-1": "2005-2006-1",
  "2004-2005-2": "2004-2005-2",
  "2004-2005-1": "2004-2005-1",
  "2003-2004-2": "2003-2004-2",
  "2003-2004-1": "2003-2004-1",
  "2002-2003-2": "2002-2003-2",
  "2002-2003-1": "2002-2003-1",
  "2001-2002-2": "2001-2002-2",
  "2001-2002-1": "2001-2002-1",
  "2000-2001-2": "2000-2001-2",
  "2000-2001-1": "2000-2001-1",
  "1999-2000-2": "1999-2000-2",
  "1999-2000-1": "1999-2000-1",
  "1998-1999-1": "1998-1999-1"
};
