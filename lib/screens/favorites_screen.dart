import 'package:flutter/material.dart';
import 'door_list_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoorListScreen(favoritesOnly: true);
  }
}
