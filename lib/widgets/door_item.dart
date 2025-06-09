import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/door.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/door_service.dart';

class DoorItem extends StatefulWidget {
  final Door door;
  const DoorItem({super.key, required this.door});

  @override
  State<DoorItem> createState() => _DoorItemState();
}

class _DoorItemState extends State<DoorItem> {
  bool isUnlocking = false;
  String unlockedMode = ''; // 'pulse', 'timed', or ''

  Future<void> _unlock({required bool isPulse}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final duration = 5;

    setState(() {
      isUnlocking = true;
      unlockedMode = isPulse ? 'pulse' : 'timed';
    });

    try {
      await DoorService.unlockDoor(
        widget.door.id,
        auth.tenantId!,
        auth.accessToken!,
        isPulse ? 0 : duration,
      );

      // Keep it unlocked for the duration
      await Future.delayed(Duration(seconds: duration));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unlock: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUnlocking = false;
          unlockedMode = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPulseUnlocked = unlockedMode == 'pulse';
    final isTimedUnlocked = unlockedMode == 'timed';
    final favorites = Provider.of<FavoritesProvider>(context);
    final isFavorite = favorites.isFavorite(widget.door.id);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          widget.door.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: () => favorites.toggleFavorite(widget.door.id),
            ),
            Tooltip(
              message: 'Pulse Unlock',
              child: IconButton(
                onPressed: isUnlocking ? null : () => _unlock(isPulse: true),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isPulseUnlocked ? Icons.lock_open : Icons.lock,
                    key: ValueKey(isPulseUnlocked),
                    color: isPulseUnlocked ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
            Tooltip(
              message: 'Timed Unlock',
              child: IconButton(
                onPressed: isUnlocking ? null : () => _unlock(isPulse: false),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isTimedUnlocked ? Icons.lock_open : Icons.key,
                    key: ValueKey(isTimedUnlocked),
                    color: isTimedUnlocked ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
