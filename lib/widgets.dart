import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'models.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class DriveMap extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Drive> drives;
  final LatLng? picked;
  final void Function(Drive drive)? onDriveTap;
  final void Function(LatLng point)? onMapTap;

  const DriveMap({
    super.key,
    required this.center,
    this.zoom = 12,
    this.drives = const [],
    this.picked,
    this.onDriveTap,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      for (final d in drives)
        Marker(
          point: LatLng(d.lat, d.lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: onDriveTap == null ? null : () => onDriveTap!(d),
            child: Icon(
              Icons.park,
              size: 36,
              color: d.caretakerId == null ? Colors.orange : Colors.green,
            ),
          ),
        ),
      if (picked != null)
        Marker(
          point: picked!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
        ),
    ];

    return FlutterMap(
      key: ValueKey('${center.latitude},${center.longitude}'),
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        onTap: onMapTap == null ? null : (tapPosition, point) => onMapTap!(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.vrikshcare.vriksh_care',
        ),
        MarkerLayer(markers: markers),
        RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}