import 'package:flutter/material.dart';
import '../../core/theme/neo_theme.dart';
import '../../core/services/sync_service.dart';

class SyncUpdateBanner extends StatefulWidget {
  final VoidCallback onSyncComplete;

  const SyncUpdateBanner({
    super.key,
    required this.onSyncComplete,
  });

  @override
  State<SyncUpdateBanner> createState() => _SyncUpdateBannerState();
}

class _SyncUpdateBannerState extends State<SyncUpdateBanner> {
  bool _isSyncing = false;
  bool _isDismissed = false;

  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    final success = await SyncService.instance.performSync();

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });

      if (success) {
        // Success — trigger parent reload and hide banner
        widget.onSyncComplete();
        setState(() {
          _isDismissed = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data berhasil diperbarui!'),
            backgroundColor: NeoTheme.accentGreen,
          ),
        );
      } else {
        // Failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Gagal mengunduh pembaruan.'),
            backgroundColor: NeoTheme.accentPink,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: NeoTheme.accentYellow,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔄', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Pembaruan Data!',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                Text(
                  'Ada update gaya poster terbaru dari server.',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.black,
                ),
              ),
            )
          else ...[
            GestureDetector(
              onTap: _performSync,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SYNC',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDismissed = true;
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, color: Colors.black, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
