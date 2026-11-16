import 'package:material_ui/material_ui.dart';
import 'package:latlong2/latlong.dart';
import 'db.dart';
import 'models.dart';
import 'widgets.dart';

class DriveDetailPage extends StatefulWidget {
  final Drive drive;
  final AppUser me;

  const DriveDetailPage({super.key, required this.drive, required this.me});

  @override
  State<DriveDetailPage> createState() => _DriveDetailPageState();
}

class _DriveDetailPageState extends State<DriveDetailPage> {
  bool _busy = false;

  Future<void> _claim() async {
    setState(() => _busy = true);
    final ok = await Db.claimDrive(widget.drive, widget.me).catchError((_) => false);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'You are now the caretaker. Find it under My Trees.'
              : 'Someone else just took this location.',
        ),
      ),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final drive = widget.drive;
    return Scaffold(
      appBar: AppBar(title: Text(drive.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 240,
            child: DriveMap(
              center: LatLng(drive.lat, drive.lng),
              zoom: 16,
              drives: [drive],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drive.orgName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${drive.saplings} saplings planted'),
                if (drive.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(drive.description),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _claim,
                    icon: const Icon(Icons.volunteer_activism),
                    label: const Text('Become the caretaker'),
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