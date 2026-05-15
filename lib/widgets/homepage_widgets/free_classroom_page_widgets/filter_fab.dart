import 'package:flutter/material.dart';
import 'package:sachet/providers/free_classroom_page_provider.dart';
import 'package:provider/provider.dart';

/// 空闲教室页面的筛选 FloatingActionButton
class FilterFAB extends StatelessWidget {
  final Map<String, int> sessionFilter;
  const FilterFAB({super.key, required this.sessionFilter});

  @override
  Widget build(BuildContext context) {
    bool hasData = context.select<FreeClassroomPageProvider, bool>(
        (provider) => provider.hasData);
    final freeClassroomPageProvider =
        context.watch<FreeClassroomPageProvider>();

    if (!hasData) {
      return SizedBox();
    }

    return FloatingActionButton(
      child: Icon(Icons.filter_alt_outlined),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => ChangeNotifierProvider.value(
            value: freeClassroomPageProvider,
            builder: (context, _) {
              return _FilterBottomSheet(sessionFilter: sessionFilter);
            },
          ),
        );
      },
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  const _FilterBottomSheet({super.key, required this.sessionFilter});
  final Map<String, int> sessionFilter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                    child: Text('教室筛选', style: textTheme.labelLarge),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Selector<FreeClassroomPageProvider, bool>(
                        selector: (context, provider) =>
                            provider.isClassroomFiltersAllSelected,
                        builder: (context, isClassroomFlitersAllSelected, __) {
                          if (!isClassroomFlitersAllSelected) {
                            return TextButton(
                              onPressed: () {
                                context
                                    .read<FreeClassroomPageProvider>()
                                    .addAllToClassroomFilters();
                                context
                                    .read<FreeClassroomPageProvider>()
                                    .filter();
                              },
                              child: Text('全选'),
                            );
                          } else {
                            return TextButton(
                              onPressed: () {
                                context
                                    .read<FreeClassroomPageProvider>()
                                    .clearClassroomFilters();
                                context
                                    .read<FreeClassroomPageProvider>()
                                    .filter();
                              },
                              child: Text('取消全选'),
                            );
                          }
                        }),
                  ),
                ),
              ],
            ),
            Selector<FreeClassroomPageProvider, List<String>>(
                selector: (context, provider) => provider.selectedRoomFilters,
                builder: (context, classRoomFilters, __) {
                  return Wrap(
                    spacing: 4.0,
                    children: classRoomFilter.entries.map((filter) {
                      return FilterChip(
                        label: Text(filter.key),
                        selected: classRoomFilters.contains(filter.value),
                        onSelected: (bool selected) {
                          if (selected) {
                            context
                                .read<FreeClassroomPageProvider>()
                                .addClassroomFilter(filter.value);
                          } else {
                            context
                                .read<FreeClassroomPageProvider>()
                                .removeClassroomFilter(filter.value);
                          }
                          context.read<FreeClassroomPageProvider>().filter();
                        },
                      );
                    }).toList(),
                  );
                }),
            Selector<
                    FreeClassroomPageProvider,
                    ({
                      bool isShowListeningClassroom,
                      bool isContainYifuBuilding
                    })>(
                selector: (context, provider) => (
                      isShowListeningClassroom:
                          provider.isShowListeningClassroom,
                      isContainYifuBuilding: provider.isContainYifuBuilding,
                    ),
                builder: (context, data, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: !data.isContainYifuBuilding
                        ? const SizedBox(height: 16)
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () {
                                context
                                    .read<FreeClassroomPageProvider>()
                                    .setIsShowListeningClassroom(
                                        !data.isShowListeningClassroom);
                                context
                                    .read<FreeClassroomPageProvider>()
                                    .filter();
                              },
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox.square(
                                      dimension:
                                          MediaQuery.textScalerOf(context)
                                              .scale(12),
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Checkbox(
                                          value: !data.isShowListeningClassroom,
                                          onChanged: (value) {
                                            if (value != null) {
                                              context
                                                  .read<
                                                      FreeClassroomPageProvider>()
                                                  .setIsShowListeningClassroom(!data
                                                      .isShowListeningClassroom);
                                              context
                                                  .read<
                                                      FreeClassroomPageProvider>()
                                                  .filter();
                                            }
                                          },
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity(
                                            horizontal:
                                                VisualDensity.minimumDensity,
                                            vertical:
                                                VisualDensity.minimumDensity,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '隐藏逸夫楼听力教室',
                                      style: TextStyle(
                                        fontSize: 11.0,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  );
                }),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: SizedBox()),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('节次筛选', style: textTheme.labelLarge),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Selector<FreeClassroomPageProvider,
                            SessionFilterMode>(
                        selector: (context, freeClassPageProvider) =>
                            freeClassPageProvider.sessionFilterMode,
                        builder: (context, sessionFilterMode, __) {
                          return SegmentedButton<SessionFilterMode>(
                            segments: sessionFilterModeMap.entries.map((entry) {
                              return ButtonSegment<SessionFilterMode>(
                                value: entry.value,
                                label: Text(entry.key),
                              );
                            }).toList(),
                            selected: <SessionFilterMode>{sessionFilterMode},
                            onSelectionChanged: (Set<SessionFilterMode> mode) {
                              // By default there is only a single segment that can be
                              // selected at one time, so its value is always the first
                              // item in the selected set.
                              context
                                  .read<FreeClassroomPageProvider>()
                                  .setSessionFilterMode(mode.first);
                              context
                                  .read<FreeClassroomPageProvider>()
                                  .filter();
                            },
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -2),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Selector<FreeClassroomPageProvider, List<int>>(
                selector: (context, provider) =>
                    provider.selectedSessionFilters,
                builder: (context, sessionFilters, __) {
                  return Wrap(
                    spacing: 4.0,
                    children: sessionFilter.entries.map((filter) {
                      return FilterChip(
                        label: Text(filter.key),
                        selected: sessionFilters.contains(filter.value),
                        onSelected: (bool selected) {
                          if (selected) {
                            context
                                .read<FreeClassroomPageProvider>()
                                .addSessionFilter(filter.value);
                          } else {
                            context
                                .read<FreeClassroomPageProvider>()
                                .removeSessionFilter(filter.value);
                          }
                          context.read<FreeClassroomPageProvider>().filter();
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
                      context.read<FreeClassroomPageProvider>().clearFilters();
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
            ),
          ],
        ),
      ),
    );
  }
}
