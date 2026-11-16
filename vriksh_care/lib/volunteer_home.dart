import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'leaderboard_page.dart';
import 'models.dart';
import 'my_trees_page.dart';
import 'nearby_page.dart';

class VolunteerHome extends StatefulWidget {
  final AppUser me;

  const VolunteerHome({super.key, required this.me});

  @override
  State<VolunteerHome> createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<VolunteerHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      NearbyPage(me: widget.me),
      MyTreesPage(me: widget.me),
      LeaderboardPage(me: widget.me),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vriksh.Care'),
        actions: [
          Center(child: Text('${widget.me.points} pts')),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map), label: 'Nearby'),
          NavigationDestination(icon: Icon(Icons.eco), label: 'My Trees'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Leaderboard'),
        ],
      ),
    );
  }
}