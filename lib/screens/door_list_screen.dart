import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_exception.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/door_service.dart';
import '../models/door.dart';
import '../widgets/door_item.dart';
import '../widgets/snackbar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';

class DoorListScreen extends StatefulWidget {
  final bool favoritesOnly;
  const DoorListScreen({super.key, this.favoritesOnly = false});

  @override
  State<DoorListScreen> createState() => _DoorListScreenState();
}

class _DoorListScreenState extends State<DoorListScreen> {
  late AuthProvider auth;
  bool loading = true;
  List<Door> doors = [];
  Map<int, String> floorNames = {};
  String searchQuery = '';
  int? selectedFloorId;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _headerOffset = ValueNotifier<double>(0.0);
  late final ScrollController _scrollController;

  List<Door> _filteredDoors(FavoritesProvider favorites) {
    return doors.where((d) {
      final matchesSearch =
          d.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFavorite =
          !widget.favoritesOnly || favorites.isFavorite(d.id);
      final matchesFloor =
          selectedFloorId == null || d.floors.contains(selectedFloorId);
      return matchesSearch && matchesFavorite && matchesFloor;
    }).toList();
  }

  Map<String, List<Door>> _groupByFloor(List<Door> doors) {
    final Map<String, Set<Door>> groups = {};
    for (final door in doors) {
      final ids = door.floors.isEmpty ? [null] : door.floors.toSet().toList();
      final names = ids.map((id) => floorNames[id] ?? 'Unknown').toSet();
      for (final name in names) {
        groups.putIfAbsent(name, () => {}).add(door);
      }
    }
    return {for (final e in groups.entries) e.key: e.value.toList()};
  }

  Future<void> _loadDoors() async {
    auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final unlockList =
          await DoorService.fetchDoors(auth.tenantId!, auth.accessToken!);
      doors = unlockList.doors;
      floorNames = {for (var f in unlockList.floors) f.id: f.name};
      // Show success only if there are doors (optional)
      if (mounted && doors.isNotEmpty) {
        showAppSnackBar(context, 'Doors loaded successfully',
            success: true, duration: const Duration(seconds: 1));
      }
      // If you want to always show success, use:
      // if (mounted) showAppSnackBar(context, 'Doors refreshed', success: true);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected error occurred')),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDoors());
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    _headerOffset.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _loadDoors();
    // let the indicator stay visible a bit before collapsing
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _refreshController.refreshCompleted();
    }
  }

  Widget _buildChipBar() {
    final chips = <Widget>[];
    chips.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: const Text('All'),
        selected: selectedFloorId == null,
        onSelected: (_) => setState(() => selectedFloorId = null),
      ),
    ));
    final entries = floorNames.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    for (final entry in entries) {
      chips.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(entry.value),
          selected: selectedFloorId == entry.key,
          onSelected: (_) => setState(() => selectedFloorId = entry.key),
        ),
      ));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: chips),
    );
  }

  List<Widget> _buildSlivers(List<Door> doors) {
    final groups = _groupByFloor(doors);
    final floorNamesSorted = groups.keys.toList()..sort();
    final slivers = <Widget>[];
    for (final name in floorNamesSorted) {
      final items = groups[name]!;
      slivers.add(SliverPersistentHeader(
        pinned: false,
        delegate: _FloorHeader(name),
      ));
      slivers.add(SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => DoorItem(
            door: items[index],
            onUnlock: ({UnlockMode? mode, int? duration}) {
              if (mode == UnlockMode.pulse) {
                showCountdownSnackBar(context, 'Unlocked ${items[index].name}',
                    seconds: 5);
              } else if (mode == UnlockMode.timed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Unlocked ${items[index].name} for $duration min')),
                );
              }
            },
          ),
          childCount: items.length,
        ),
      ));
    }
    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoritesProvider>(context);
    final visibleDoors = _filteredDoors(favorites);

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : doors.isEmpty
              ? const Center(child: Text('No Doors Available'))
              : SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  header: CustomHeader(
                    refreshStyle: RefreshStyle.Front,
                    height: 80,
                    onOffsetChange: (o) =>
                        _headerOffset.value = o.clamp(0.0, 80.0),
                    builder: (context, mode) {
                      return ValueListenableBuilder<double>(
                        valueListenable: _headerOffset,
                        builder: (_, offset, __) {
                          final progress = (offset / 80.0).clamp(0.0, 1.0);
                          final translateY = offset - 40;
                          return SizedBox(
                            height: 80,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Transform.translate(
                                  offset: Offset(0, translateY),
                                  child: Opacity(
                                    opacity: progress,
                                    child: Transform.scale(
                                      scale: 0.7 + 0.3 * progress,
                                      child: ExpressiveLoadingIndicator(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        constraints:
                                            const BoxConstraints.tightFor(
                                                width: 56, height: 56),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    controller: _scrollController,
                    key: const PageStorageKey('doorListScroll'),
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics()),
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SearchBarHeader(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (v) => setState(() => searchQuery = v),
                        ),
                      ),
                      if (!widget.favoritesOnly)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _ChipBarHeader(_buildChipBar()),
                        ),
                      if (visibleDoors.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text('No Doors Found')),
                        )
                      else
                        ..._buildSlivers(visibleDoors),
                    ],
                  ),
                ),
    );
  }
}

class _FloorHeader extends SliverPersistentHeaderDelegate {
  final String title;
  _FloorHeader(this.title);

  @override
  double get minExtent => 40;
  @override
  double get maxExtent => 40;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FloorHeader oldDelegate) =>
      oldDelegate.title != title;
}

class _SearchBarHeader extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  _SearchBarHeader({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  double get minExtent => 76; // Increased
  @override
  double get maxExtent => 76;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(
          horizontal: 12.0, vertical: 8.0), // more breathing room
      alignment: Alignment.center,
      child: SearchBar(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        leading: const Icon(Icons.search),
        hintText: 'Search doors...',
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarHeader oldDelegate) => false;
}

class _ChipBarHeader extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ChipBarHeader(this.child);

  @override
  double get minExtent => 84;
  @override
  double get maxExtent => 84;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _ChipBarHeader oldDelegate) => false;
}
