import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'db.dart';
import 'login_page.dart';
import 'models.dart';
import 'org_home.dart';
import 'volunteer_home.dart';
import 'widgets.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Loading();
        }
        final user = authSnap.data;
        if (user == null) return const LoginPage();
        return StreamBuilder<AppUser?>(
          stream: Db.userStream(user.uid),
          builder: (context, snap) {
            final me = snap.data;
            if (me == null) return const Loading();
            if (me.role == 'organization') return OrgHome(me: me);
            return VolunteerHome(me: me);
          },
        );
      },
    );
  }
}