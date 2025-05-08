import 'package:flutter/material.dart';
import 'package:sachet/provider/free_class_page_provider.dart';
import 'package:provider/provider.dart';

/// 空闲教室页面的筛选 FloatingActionButton
class FilterFAB extends StatelessWidget {
  const FilterFAB({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasData = context.select<FreeClassPageProvider, bool>(
        (freeClassPageProvider) => freeClassPageProvider.hasData);
    final freeClassPageProvider = context.watch<FreeClassPageProvider>();
    if (hasData) {
      return FloatingActionButton(
        child: Icon(Icons.filter_alt_outlined),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => ChangeNotifierProvider.value(
              value: freeClassPageProvider,
              builder: (context, _) {
                return BottomSheet(
                  onClosing: () {},
                  enableDrag: false,
                  builder: (BuildContext context) => Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 36.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(child: SizedBox()),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '教室筛选',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context
                                        .read<FreeClassPageProvider>()
                                        .addAllToClassRoomFliters();
                                    context
                                        .read<FreeClassPageProvider>()
                                        .filter();
                                  },
                                  child: Text('全选'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Selector<FreeClassPageProvider, List<String>>(
                            selector: (context, freeClassPageProvider) =>
                                freeClassPageProvider.selectedRoomFilters,
                            builder: (context, classRoomFilters, __) {
                              return Wrap(
                                spacing: 4.0,
                                children: classRoomFilter.entries.map((filter) {
                                  return FilterChip(
                                    label: Text(filter.key),
                                    selected:
                                        classRoomFilters.contains(filter.value),
                                    onSelected: (bool selected) {
                                      if (selected) {
                                        context
                                            .read<FreeClassPageProvider>()
                                            .addClassRoomFilter(filter.value);
                                      } else {
                                        context
                                            .read<FreeClassPageProvider>()
                                            .removeClassRoomFilter(
                                                filter.value);
                                      }
                                      context
                                          .read<FreeClassPageProvider>()
                                          .filter();
                                    },
                                  );
                                }).toList(),
                              );
                            }),
                        Row(
                          children: [
                            Expanded(child: SizedBox()),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '节次筛选',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Selector<FreeClassPageProvider,
                                        SessionFilterMode>(
                                    selector: (context,
                                            freeClassPageProvider) =>
                                        freeClassPageProvider.sessionFilterMode,
                                    builder: (context, sessionFilterMode, __) {
                                      return SegmentedButton<SessionFilterMode>(
                                        segments: sessionFilterModeMap.entries
                                            .map((entry) {
                                          return ButtonSegment<
                                              SessionFilterMode>(
                                            value: entry.value,
                                            label: Text(entry.key),
                                          );
                                        }).toList(),
                                        selected: <SessionFilterMode>{
                                          sessionFilterMode
                                        },
                                        onSelectionChanged:
                                            (Set<SessionFilterMode> mode) {
                                          // By default there is only a single segment that can be
                                          // selected at one time, so its value is always the first
                                          // item in the selected set.
                                          context
                                              .read<FreeClassPageProvider>()
                                              .setSessionFilterMode(mode.first);
                                          context
                                              .read<FreeClassPageProvider>()
                                              .filter();
                                        },
                                        style: const ButtonStyle(
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity(
                                              horizontal: -4, vertical: -2),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Selector<FreeClassPageProvider, List<int>>(
                            selector: (context, freeClassPageProvider) =>
                                freeClassPageProvider.selectedSessionFilters,
                            builder: (context, sessionFilters, __) {
                              return Wrap(
                                spacing: 4.0,
                                children: sessionFilter.entries.map((filter) {
                                  return FilterChip(
                                    label: Text(filter.key),
                                    selected:
                                        sessionFilters.contains(filter.value),
                                    onSelected: (bool selected) {
                                      if (selected) {
                                        context
                                            .read<FreeClassPageProvider>()
                                            .addSessionFilter(filter.value);
                                      } else {
                                        context
                                            .read<FreeClassPageProvider>()
                                            .removeSessionFilter(filter.value);
                                      }
                                      context
                                          .read<FreeClassPageProvider>()
                                          .filter();
                                    },
                                  );
                                }).toList(),
                              );
                            }),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  context
                                      .read<FreeClassPageProvider>()
                                      .clearFilters();
                                  Navigator.of(context).pop();
                                },
                                child: Text('清除筛选'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('确认'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      return SizedBox();
    }
  }
}
