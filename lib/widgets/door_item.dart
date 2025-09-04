import 'package:flutter/material.dart';
import './snackbar.dart';
import 'package:provider/provider.dart';
import '../models/door.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/door_service.dart';

enum UnlockMode { none, pulse, timed }

class DoorItem extends StatefulWidget {
  final Door door;
  final void Function({UnlockMode? mode, int? duration})?
      onUnlock; // update type

  const DoorItem({super.key, required this.door, this.onUnlock});

  @override
  State<DoorItem> createState() => _DoorItemState();
}

class _DoorItemState extends State<DoorItem> {
  bool isUnlocking = false;
  UnlockMode unlockedMode = UnlockMode.none;

  Future<void> _unlock({required bool isPulse, int? customDuration}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final duration = isPulse ? 5 : (customDuration ?? 15);

    setState(() {
      isUnlocking = true;
      unlockedMode = isPulse ? UnlockMode.pulse : UnlockMode.timed;
    });

    try {
      await DoorService.unlockDoor(
        widget.door.id,
        auth.tenantId!,
        auth.accessToken!,
        isPulse ? 0 : duration,
      );

      if (widget.onUnlock != null) {
        widget.onUnlock!(
          mode: isPulse ? UnlockMode.pulse : UnlockMode.timed,
          duration: isPulse ? null : duration,
        );
      }

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
          unlockedMode = UnlockMode.none;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    favorites.toggleFavorite(widget.door.id);
                    showAppSnackBar(
                      context,
                      isFavorite
                          ? 'Removed from favorites'
                          : 'Added to favorites',
                      success: !isFavorite,
                      backgroundColor: isFavorite
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
                Tooltip(
                  message: 'Unlock',
                  child: ElevatedButton.icon(
                    onPressed: isUnlocking
                        ? null
                        : () {
                            _unlock(isPulse: true);
                          },
                    onLongPress: isUnlocking
                        ? null
                        : () async {
                            final result = await showModalBottomSheet<
                                Map<String, dynamic>>(
                              context: context,
                              builder: (ctx) {
                                int timedDuration = 5; // default to 5 minutes
                                return StatefulBuilder(
                                  builder: (context, setModalState) => SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'Unlock Mode',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.flash_on),
                                          title: const Text('Pulse (5s)'),
                                          onTap: () => Navigator.pop(
                                              ctx, {'mode': 'pulse'}),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.timer),
                                          title: Row(
                                            children: [
                                              const Text('Timed'),
                                              const SizedBox(width: 8),
                                              Text('(${timedDuration} min)'),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              Slider(
                                                value: timedDuration.toDouble(),
                                                min: 1,
                                                max: 60,
                                                divisions: 59,
                                                label: '${timedDuration} min',
                                                onChanged: (v) =>
                                                    setModalState(() {
                                                  timedDuration = v.round();
                                                }),
                                              ),
                                              const Text(
                                                'Select duration (1-60 minutes)',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          onTap: () => Navigator.pop(ctx, {
                                            'mode': 'timed',
                                            'duration': timedDuration
                                          }),
                                        ),
                                        const Divider(),
                                        ListTile(
                                          leading: const Icon(Icons.cancel),
                                          title: const Text('Cancel'),
                                          onTap: () => Navigator.pop(ctx, null),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            if (result != null && result['mode'] == 'pulse') {
                              _unlock(isPulse: true);
                            } else if (result != null &&
                                result['mode'] == 'timed') {
                              _unlock(
                                  isPulse: false,
                                  customDuration: result['duration']);
                            }
                          },
                    icon: isUnlocking
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              isUnlocking ? Icons.lock_open : Icons.lock,
                              key: ValueKey(isUnlocking),
                              color: isUnlocking
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                    label: const Text('Unlock'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUnlocking
                          ? Colors.green[100]
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: isUnlocking
                          ? Colors.green
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
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
