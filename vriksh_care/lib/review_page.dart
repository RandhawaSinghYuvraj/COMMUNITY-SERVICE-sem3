import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import 'db.dart';
import 'models.dart';

class ReviewPage extends StatelessWidget {
  final AppUser me;

  const ReviewPage({super.key, required this.me});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlantUpdate>>(
      stream: Db.pendingFor(me.uid),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return const Center(child: Text('No updates waiting for review.'));
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final u in items)
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.memory(
                      base64Decode(u.photo),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.driveTitle, style: Theme.of(context).textTheme.titleMedium),
                          Text('${u.volunteerName} • ${u.condition} • ${u.dayKey}'),
                          if (u.note.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(u.note),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => Db.reject(u),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: () => Db.approve(u),
                                child: const Text('Approve'),
                              ),
                            ],
                          ),
                        ],
                      ),
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