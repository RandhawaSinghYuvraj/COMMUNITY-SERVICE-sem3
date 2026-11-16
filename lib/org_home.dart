import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'create_drive_page.dart';
import 'db.dart';
import 'models.dart';
import 'review_page.dart';

class OrgHome extends StatefulWidget {
  final AppUser me;

  const OrgHome({super.key, required this.me});

  @override
  State<OrgHome> createState() => _OrgHomeState();
}

class _OrgHomeState extends State<OrgHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.me.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: _index == 0 ? _DrivesTab(me: widget.me) : ReviewPage(me: widget.me),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateDrivePage(me: widget.me)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New drive'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.park), label: 'My Drives'),
          NavigationDestination(icon: Icon(Icons.fact_check), label: 'Reviews'),
        ],
      ),
    );
  }
}

class _DrivesTab extends StatelessWidget {
  final AppUser me;

  const _DrivesTab({required this.me});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Drive>>(
      stream: Db.orgDrives(me.uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final drives = snap.data!;
        if (drives.isEmpty) {
          return const Center(
            child: Text('Tap New drive to add your first plantation drive.'),
          );
        }
        final adopted = drives.where((d) => d.caretakerId != null).length;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.insights),
                title: Text('${drives.length} drives, $adopted with a caretaker'),
              ),
            ),
            for (final d in drives)
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.park,
                    color: d.caretakerId == null ? Colors.orange : Colors.green,
                  ),
                  title: Text(d.title),
                  subtitle: Text(
                    '${d.saplings} saplings • ${d.caretakerName ?? 'Waiting for a caretaker'}',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}