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
  final FocusNode _searchFocusNode = FocusNode(); // Added FocusNode

  List<Door> _filteredDoors(FavoritesProvider favorites) {
    return doors.where((d) {
      final matchesSearch =
          d.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesFavorite = !showFavoritesOnly || favorites.isFavorite(d.id);
      return matchesSearch && matchesFavorite;
    }).toList();
  }

  Map<String, List<Door>> _groupByFloor(List<Door> doors) {
    final Map<String, Set<Door>> groups = {};

    for (final door in doors) {
      final ids = door.floors.isEmpty ? [null] : door.floors.toSet().toList();
      final floorNamesForDoor = ids
          .map((id) => floorNames[id] ?? 'Unknown')
          .toSet(); // prevent same name repeating

      for (final name in floorNamesForDoor) {
        groups.putIfAbsent(name, () => {}).add(door); // use Set to avoid dupes
      }
    }

    // Convert to Map<String, List<Door>>
    return {
      for (final entry in groups.entries) entry.key: entry.value.toList(),
    };
  }

  Widget _buildGroupedList(List<Door> doors) {
    final groups = _groupByFloor(doors);
    final floorNamesSorted = groups.keys.toList()..sort();

    return ListView.builder(
      itemCount: floorNamesSorted.length,
      itemBuilder: (context, index) {
        final name = floorNamesSorted[index];
        final items = groups[name]!;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Floor Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 4.0),
              // List of doors under the floor
              ...items.map((d) => DoorItem(door: d)).toList(),
            ],
          ),
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
  void dispose() {
    _searchFocusNode.dispose(); // Dispose FocusNode
    super.dispose();
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
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            focusNode: _searchFocusNode, // Attach FocusNode
                            showCursor: _searchFocusNode.hasFocus, // Conditional cursor
                            decoration: InputDecoration(
                              hintText: 'Search doors...',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                            ),
                            onChanged: (value) =>
                                setState(() => searchQuery = value),
                          ),
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
