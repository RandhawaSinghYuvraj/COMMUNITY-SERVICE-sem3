import 'package:material_ui/material_ui.dart';
import 'package:latlong2/latlong.dart';
import 'db.dart';
import 'location.dart';
import 'models.dart';
import 'widgets.dart';

class CreateDrivePage extends StatefulWidget {
  final AppUser me;

  const CreateDrivePage({super.key, required this.me});

  @override
  State<CreateDrivePage> createState() => _CreateDrivePageState();
}

class _CreateDrivePageState extends State<CreateDrivePage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _count = TextEditingController(text: '10');
  LatLng _center = const LatLng(28.6139, 77.2090);
  LatLng? _point;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _count.dispose();
    super.dispose();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _useMyLocation() async {
    final point = await currentLocation();
    if (!mounted) return;
    if (point == null) {
      _message('Could not get your location. Tap the map instead.');
      return;
    }
    setState(() {
      _center = point;
      _point = point;
    });
  }

  Future<void> _save() async {
    final count = int.tryParse(_count.text.trim()) ?? 0;
    final point = _point;
    if (_title.text.trim().isEmpty || count <= 0 || point == null) {
      _message('Add a name, the number of saplings, and tap the map to set the location');
      return;
    }
    setState(() => _busy = true);
    await Db.createDrive(
      org: widget.me,
      title: _title.text.trim(),
      description: _description.text.trim(),
      saplings: count,
      point: point,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New plantation drive')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Drive name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _description,
                        decoration: const InputDecoration(
                          labelText: 'Short description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _count,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Saplings',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Tap the map to place the pin'),
              ],
            ),
          ),
          Expanded(
            child: DriveMap(
              center: _center,
              zoom: 14,
              picked: _point,
              onMapTap: (p) => setState(() => _point = p),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _useMyLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('My location'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : _save,
                    child: Text(_busy ? 'Saving...' : 'Create drive'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}