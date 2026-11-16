import 'package:material_ui/material_ui.dart';
import 'db.dart';
import 'models.dart';

class LeaderboardPage extends StatelessWidget {
  final AppUser me;

  const LeaderboardPage({super.key, required this.me});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: Db.leaderboard(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snap.data!;
        if (users.isEmpty) {
          return const Center(child: Text('No volunteers yet.'));
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, i) {
            final u = users[i];
            return ListTile(
              selected: u.uid == me.uid,
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(u.name),
              subtitle: Text('${u.badge} • ${u.streak} day streak'),
              trailing: Text('${u.points}', style: Theme.of(context).textTheme.titleMedium),
            );
          },
        );
      },
    );
  }
}