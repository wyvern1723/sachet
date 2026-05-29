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
      return const SizedBox();
    }

    return FloatingActionButton(
      child: const Icon(Icons.filter_alt_outlined),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          showDragHandle: false,
          useSafeArea: true,
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
  const _FilterBottomSheet({required this.sessionFilter});
  final Map<String, int> sessionFilter;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final safeAreaInsets = MediaQuery.of(context).padding;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12.0, bottom: 2.0),
            width: 32.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20.0, 0.0, 20.0, safeAreaInsets.bottom + 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('教学楼筛选', style: textTheme.labelLarge),
                    Selector<FreeClassroomPageProvider, bool>(
                        selector: (context, provider) =>
                            provider.isClassroomFiltersAllSelected,
                        builder: (context, isClassroomFiltersAllSelected, __) {
                          return TextButton(
                            onPressed: () {
                              final provider =
                                  context.read<FreeClassroomPageProvider>();
                              if (!isClassroomFiltersAllSelected) {
                                provider.addAllToClassroomFilters();
                              } else {
                                provider.clearClassroomFilters();
                              }
                              provider.filter();
                            },
                            child: Text(
                                isClassroomFiltersAllSelected ? '取消全选' : '全选'),
                          );
                        }),
                  ],
                ),
                const SizedBox(height: 4.0),
                Selector<FreeClassroomPageProvider, List<String>>(
                    selector: (context, provider) =>
                        provider.selectedRoomFilters,
                    builder: (context, classRoomFilters, __) {
                      return Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        children: classRoomFilter.entries.map((filter) {
                          return FilterChip(
                            label: Text(filter.key),
                            selected: classRoomFilters.contains(filter.value),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            onSelected: (bool selected) {
                              final provider =
                                  context.read<FreeClassroomPageProvider>();
                              if (selected) {
                                provider.addClassroomFilter(filter.value);
                              } else {
                                provider.removeClassroomFilter(filter.value);
                              }
                              provider.filter();
                            },
                          );
                        }).toList(),
                      );
                    }),
                const SizedBox(height: 4.0),
                _toggleIsShowYifuListeningClassroom(context, colorScheme),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('节次筛选', style: textTheme.labelLarge),
                    Selector<FreeClassroomPageProvider, SessionFilterMode>(
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
                              final provider =
                                  context.read<FreeClassroomPageProvider>();
                              provider.setSessionFilterMode(mode.first);
                              provider.filter();
                            },
                            style: SegmentedButton.styleFrom(
                              visualDensity: VisualDensity(
                                vertical: VisualDensity.minimumDensity,
                                horizontal: VisualDensity.minimumDensity,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              textStyle: textTheme.labelSmall,
                            ),
                          );
                        }),
                  ],
                ),
                const SizedBox(height: 8.0),
                Selector<FreeClassroomPageProvider, List<int>>(
                    selector: (context, provider) =>
                        provider.selectedSessionFilters,
                    builder: (context, sessionFilters, __) {
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: sessionFilter.entries.map((filter) {
                          return FilterChip(
                            label: Text(filter.key),
                            selected: sessionFilters.contains(filter.value),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            onSelected: (bool selected) {
                              final provider =
                                  context.read<FreeClassroomPageProvider>();
                              if (selected) {
                                provider.addSessionFilter(filter.value);
                              } else {
                                provider.removeSessionFilter(filter.value);
                              }
                              provider.filter();
                            },
                          );
                        }).toList(),
                      );
                    }),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context
                              .read<FreeClassroomPageProvider>()
                              .clearFilters();
                          Navigator.of(context).pop();
                        },
                        child: const Text('清除筛选'),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Theme.of(context).useMaterial3
                          ? FilledButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('确认'),
                            )
                          : ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('确认'),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleIsShowYifuListeningClassroom(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Selector<FreeClassroomPageProvider,
            ({bool isShowListeningClassroom, bool isContainYifuBuilding})>(
        selector: (context, provider) => (
              isShowListeningClassroom: provider.isShowListeningClassroom,
              isContainYifuBuilding: provider.isContainYifuBuilding,
            ),
        builder: (context, data, __) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: !data.isContainYifuBuilding
                ? const SizedBox(height: 8.0)
                : Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: () {
                        final provider =
                            context.read<FreeClassroomPageProvider>();
                        provider.setIsShowListeningClassroom(
                            !data.isShowListeningClassroom);
                        provider.filter();
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox.square(
                              dimension:
                                  MediaQuery.textScalerOf(context).scale(14),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Checkbox(
                                  value: !data.isShowListeningClassroom,
                                  onChanged: (value) {
                                    if (value != null) {
                                      final provider = context
                                          .read<FreeClassroomPageProvider>();
                                      provider.setIsShowListeningClassroom(
                                          !data.isShowListeningClassroom);
                                      provider.filter();
                                    }
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: const VisualDensity(
                                    horizontal: VisualDensity.minimumDensity,
                                    vertical: VisualDensity.minimumDensity,
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
        });
  }
}
