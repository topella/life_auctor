import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/services/connectivity_service.dart';
import 'package:life_auctor/services/sync_queue_service.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isDismissed = false;
  bool? _lastOnlineState;

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityService, SyncQueueService>(
      builder: (context, connectivity, syncQueue, child) {
        // Reset dismissed state when connectivity changes
        if (_lastOnlineState != null &&
            _lastOnlineState != connectivity.isOnline) {
          _isDismissed = false;
        }
        _lastOnlineState = connectivity.isOnline;

        // Dont show if dismissed, online or no pending operations
        if (_isDismissed ||
            (connectivity.isOnline && !syncQueue.hasPendingOperations)) {
          return const SizedBox.shrink();
        }

        return Material(
          color: connectivity.isOffline
              ? Colors.orange.shade700
              : Colors.blue.shade600,
          elevation: 4,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    connectivity.isOffline
                        ? Icons.cloud_off
                        : Icons.cloud_queue,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          connectivity.isOffline
                              ? 'You are offline'
                              : 'Syncing...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (syncQueue.hasPendingOperations)
                          Text(
                            '${syncQueue.pendingOperations} operation${syncQueue.pendingOperations > 1 ? 's' : ''} pending',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (syncQueue.isSyncing)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => setState(() => _isDismissed = true),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WithConnectivityBanner extends StatelessWidget {
  final Widget child;

  const WithConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ConnectivityBanner(),
        Expanded(child: child),
      ],
    );
  }
}
