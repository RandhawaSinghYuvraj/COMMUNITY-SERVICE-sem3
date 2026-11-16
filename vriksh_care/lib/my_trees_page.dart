import 'package:material_ui/material_ui.dart';
import 'db.dart';
import 'models.dart';
import 'submit_update_page.dart';

class MyTreesPage extends StatelessWidget {
  final AppUser me;

  const MyTreesPage({super.key, required this.me});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Drive>>(
      stream: Db.myDrives(me.uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final drives = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                title: Text('${me.streak} day streak'),
                subtitle: Text('${me.points} points • ${me.badge}'),
              ),
            ),
            if (drives.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Pick a drive from the Nearby tab to start caring for it.'),
                ),
              ),
            for (final d in drives) _TreeCard(drive: d, me: me),
          ],
        );
      },
    );
  }
}

class _TreeCard extends StatelessWidget {
  final Drive drive;
  final AppUser me;

  const _TreeCard({required this.drive, required this.me});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(drive.title, style: Theme.of(context).textTheme.titleMedium),
            Text('${drive.orgName} • ${drive.saplings} saplings'),
            const SizedBox(height: 8),
            StreamBuilder<PlantUpdate?>(
              stream: Db.todayUpdate(drive.id),
              builder: (context, snap) {
                final status = snap.data?.status;
                final canSend = status == null || status == 'rejected';
                final label = switch (status) {
                  'pending' => 'Waiting for approval',
                  'approved' => 'Approved today, +10 points',
                  'rejected' => 'Not approved, send a fresh photo',
                  _ => 'No update sent today',
                };
                return Row(
                  children: [
                    Expanded(child: Text(label)),
                    FilledButton(
                      onPressed: canSend
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubmitUpdatePage(drive: drive, me: me),
                                ),
                              )
                          : null,
                      child: const Text('Send update'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}