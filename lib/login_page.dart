import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'db.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;
  bool _busy = false;
  String _role = 'volunteer';
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.length < 6) {
      setState(() => _error = 'Enter an email and a password of at least 6 characters');
      return;
    }
    if (_registering && _name.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a name');
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      if (_registering) {
        await Db.register(
          name: _name.text.trim(),
          email: email,
          password: password,
          role: _role,
        );
      } else {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Something went wrong');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Icon(Icons.park, size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text('Vriksh.Care', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                const Text('Plant it. Care for it. Watch it grow.'),
                const SizedBox(height: 24),
                if (_registering) ...[
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'volunteer',
                        label: Text('Volunteer'),
                        icon: Icon(Icons.person),
                      ),
                      ButtonSegment(
                        value: 'organization',
                        label: Text('Organization'),
                        icon: Icon(Icons.groups),
                      ),
                    ],
                    selected: {_role},
                    onSelectionChanged: (s) => setState(() => _role = s.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _name,
                    decoration: InputDecoration(
                      labelText: _role == 'organization' ? 'Organization name' : 'Your name',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_registering ? 'Create account' : 'Sign in'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _registering = !_registering;
                    _error = '';
                  }),
                  child: Text(
                    _registering ? 'I already have an account' : 'Create a new account',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}