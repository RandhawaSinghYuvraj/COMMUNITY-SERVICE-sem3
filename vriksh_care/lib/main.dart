import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VrikshApp());
}

class VrikshApp extends StatelessWidget {
  const VrikshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vriksh.Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}