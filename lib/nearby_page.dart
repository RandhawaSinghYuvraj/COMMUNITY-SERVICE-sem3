import 'package:material_ui/material_ui.dart';
import 'package:latlong2/latlong.dart';
import 'db.dart';
import 'drive_detail_page.dart';
import 'location.dart';
import 'models.dart';
import 'widgets.dart';

class NearbyPage extends StatefulWidget {
  final AppUser me;

  const NearbyPage({super.key, required this.me});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  static const double radiusKm = 50;
  static const LatLng fallback = LatLng(28.6139, 77.2090);
  LatLng? _here;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    currentLocation().then((point) {
      if (mounted) {
        setState(() {
          _here = point;
          _ready = true;
        });
      }
    });
  }

  void _open(Drive drive) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriveDetailPage(drive: drive, me: widget.me),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());
    final here = _here;
    return StreamBuilder<List<Drive>>(
      stream: Db.allDrives(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        const distance = Distance();
        final items = <(Drive, double)>[];
        for (final d in snap.data!) {
          if (d.caretakerId != null) continue;
          final km = here == null
              ? 0.0
              : distance.as(LengthUnit.Kilometer, here, LatLng(d.lat, d.lng));
          if (here == null || km <= radiusKm) items.add((d, km));
        }
        items.sort((a, b) => a.$2.compareTo(b.$2));
        return Column(
          children: [
            SizedBox(
              height: 260,
              child: DriveMap(
                center: here ?? fallback,
                drives: [for (final i in items) i.$1],
                onDriveTap: _open,
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No open plantation drives nearby yet.'))
                  : ListView(
                      children: [
                        for (final i in items)
                          ListTile(
                            leading: const Icon(Icons.park, color: Colors.orange),
                            title: Text(i.$1.title),
                            subtitle: Text(
                              '${i.$1.orgName} • ${i.$1.saplings} saplings'
                              '${here == null ? '' : ' • ${i.$2.toStringAsFixed(1)} km'}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _open(i.$1),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}