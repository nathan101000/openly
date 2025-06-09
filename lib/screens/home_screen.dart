import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/door_service.dart';
import '../models/door.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDoors());
  }

  Future<void> _loadDoors() async {
    auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      doors = await DoorService.fetchDoors(auth.tenantId!, auth.accessToken!);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Your Doors')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : doors.isEmpty
              ? const Center(child: Text('No Doors Available'))
              : RefreshIndicator(
                  onRefresh: _loadDoors,
                  child: ListView.builder(
                    itemCount: doors.length,
                    itemBuilder: (context, index) {
                      return DoorItem(door: doors[index]);
                    },
                  ),
                ),
    );
  }
}
