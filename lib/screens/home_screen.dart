import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/door_service.dart';
import '../models/door.dart';
import '../models/floor.dart';
import '../widgets/door_item.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthProvider auth;
  bool loading = true;
  List<Door> doors = [];
  Map<int, String> floorNames = {};
  String searchQuery = '';
  bool showFavoritesOnly = false;

  List<Door> _filteredDoors(FavoritesProvider favorites) {
    return doors.where((d) {
      final matchesSearch =
          d.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFavorite =
          !showFavoritesOnly || favorites.isFavorite(d.id);
      return matchesSearch && matchesFavorite;
    }).toList();
  }

  Map<int, List<Door>> _groupByFloor(List<Door> doors) {
    final Map<int, List<Door>> groups = {};
    for (final door in doors) {
      final ids = door.floors.isEmpty ? [0] : door.floors;
      for (final id in ids) {
        groups.putIfAbsent(id, () => []).add(door);
      }
    }
    return groups;
  }

  Widget _buildGroupedList(List<Door> doors) {
    final groups = _groupByFloor(doors);
    final floorIds = groups.keys.toList()
      ..sort((a, b) => (floorNames[a] ?? '$a').compareTo(floorNames[b] ?? '$b'));

    return ListView.builder(
      itemCount: floorIds.length,
      itemBuilder: (context, index) {
        final floorId = floorIds[index];
        final name = floorNames[floorId] ?? 'Unknown';
        final items = groups[floorId]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(name, style: Theme.of(context).textTheme.titleMedium),
            ),
            ...items.map((d) => DoorItem(door: d)).toList(),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDoors());
  }

  Future<void> _loadDoors() async {
    auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final unlockList =
          await DoorService.fetchDoors(auth.tenantId!, auth.accessToken!);
      doors = unlockList.doors;
      floorNames = {for (var f in unlockList.floors) f.id: f.name};
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoritesProvider>(context);
    final visibleDoors = _filteredDoors(favorites);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Doors'),
        actions: [
          IconButton(
            icon: Icon(
              showFavoritesOnly ? Icons.star : Icons.star_border,
            ),
            onPressed: () {
              setState(() => showFavoritesOnly = !showFavoritesOnly);
            },
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : doors.isEmpty
              ? const Center(child: Text('No Doors Available'))
              : RefreshIndicator(
                  onRefresh: _loadDoors,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search doors',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) => setState(() => searchQuery = value),
                        ),
                      ),
                      Expanded(
                        child: visibleDoors.isEmpty
                            ? const Center(child: Text('No Doors Found'))
                            : _buildGroupedList(visibleDoors),
                      ),
                    ],
                  ),
                ),
    );
  }
}
