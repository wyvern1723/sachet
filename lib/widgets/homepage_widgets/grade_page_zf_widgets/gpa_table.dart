import 'package:flutter/material.dart';

class GPATable extends StatelessWidget {
  /// GPA 表
  const GPATable({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
        // border: TableBorder.all(),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(4),
          2: FlexColumnWidth(2)
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // 表头
          TableRow(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              children: const [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('成绩等级'),
                    ),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('成绩'),
                    ),
                  ),
                ),
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('绩点'),
                    ),
                  ),
                ),
              ]),

          // 优
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            children: [
              TableCell(
                child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(2),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    // border: TableBorder.all(),
                    children: [
                      TableRow(children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(child: Text('优')),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Table(
                            // border: TableBorder(horizontalInside: BorderSide()),
                            children: const [
                              TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text('A'),
                                  ),
                                )
                              ]),
                              TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text('A-'),
                                  ),
                                )
                              ])
                            ],
                          ),
                        )
                      ])
                    ]),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  // border: TableBorder(
                  //     horizontalInside: BorderSide(), top: BorderSide()),
                  children: const [
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('90-100'),
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('85-90'),
                        ),
                      )
                    ])
                  ],
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  // border: TableBorder.all(),
                  children: const [
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('4.0'),
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('3.7'),
                        ),
                      )
                    ]),
                  ],
                ),
              ),
            ],
          ),

          // 良
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            children: [
              TableCell(
                child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(2),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(child: Text('良')),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Table(
                            children: const [
                              TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text('B+'),
                                  ),
                                )
                              ]),
                              TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text('B'),
                                  ),
                                )
                              ]),
                              TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text('B-'),
                                  ),
                                )
                              ])
                            ],
                          ),
                        )
                      ])
                    ]),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  children: const [
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('82-84'),
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('78-81'),
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('75-77'),
                        ),
                      )
                    ])
                  ],
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  children: const [
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('3.3'),
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('3.0'),
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('2.7'),
                        ),
                      )
                    ])
                  ],
                ),
              ),
            ],
          ),

          // 中
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            children: [
              TableCell(
                child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(2),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(child: Text('中')),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Table(
                            children: const [
                              TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text('C+'),
                                  ),
                                )
                              ]),
                              TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text('C'),
                                  ),
                                )
                              ]),
                              TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text('C-'),
                                  ),
                                )
                              ])
                            ],
                          ),
                        )
                      ])
                    ]),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  children: const [
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('72-74'),
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('68-71'),
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('64-67'),
                        ),
                      )
                    ])
                  ],
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  children: const [
                    TableRow(children: [
                      Center(
                          child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text('2.3'),
                      ))
                    ]),
                    TableRow(children: [
                      Center(
                          child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text('2.0'),
                      ))
                    ]),
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('1.5'),
                        ),
                      )
                    ])
                  ],
                ),
              ),
            ],
          ),

          // 及格
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            children: [
              TableCell(
                child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(2),
                    },
                    // border: TableBorder.all(
                    //     color: Theme.of(context).colorScheme.onSurfaceVariant),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text('及格'),
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Table(
                            children: const [
                              TableRow(children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Text('D'),
                                  ),
                                )
                              ])
                            ],
                          ),
                        )
                      ])
                    ]),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  children: const [
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('60-63'),
                        ),
                      )
                    ])
                  ],
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  children: const [
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('1.0'),
                        ),
                      )
                    ])
                  ],
                ),
              ),
            ],
          ),

          // 不及格
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            children: [
              TableCell(
                child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(2),
                    },
                    // border: TableBorder.all(
                    //     color: Theme.of(context).colorScheme.onSurfaceVariant),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [
                        const TableCell(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text('不及格'),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Table(
                            children: const [
                              TableRow(children: [Center(child: Text('F'))])
                            ],
                          ),
                        )
                      ])
                    ]),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  children: const [
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('<60'),
                        ),
                      )
                    ])
                  ],
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Table(
                  children: const [
                    TableRow(children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('0'),
                        ),
                      )
                    ])
                  ],
                ),
              ),
            ],
          ),
        ]);
  }
}

// 操，这个表手搓的，累死了。