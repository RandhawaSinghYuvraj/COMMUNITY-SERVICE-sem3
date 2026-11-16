import 'dart:convert';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'db.dart';
import 'models.dart';

class SubmitUpdatePage extends StatefulWidget {
  final Drive drive;
  final AppUser me;

  const SubmitUpdatePage({super.key, required this.drive, required this.me});

  @override
  State<SubmitUpdatePage> createState() => _SubmitUpdatePageState();
}

class _SubmitUpdatePageState extends State<SubmitUpdatePage> {
  static const conditions = ['Healthy', 'Needs water', 'Struggling'];
  final _note = TextEditingController();
  String _condition = 'Healthy';
  Uint8List? _bytes;
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 640,
      imageQuality: 50,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() => _bytes = bytes);
  }

  Future<void> _send() async {
    final bytes = _bytes;
    if (bytes == null) {
      _message('Add a photo first');
      return;
    }
    if (bytes.length > 600000) {
      _message('That photo is too big, please try another one');
      return;
    }
    setState(() => _busy = true);
    final error = await Db.submitUpdate(
      drive: widget.drive,
      me: widget.me,
      condition: _condition,
      note: _note.text.trim(),
      photo: base64Encode(bytes),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      _message(error);
      return;
    }
    _message('Update sent. Waiting for approval.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.drive.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_bytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(_bytes!, height: 240, fit: BoxFit.cover),
            )
          else
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.photo_camera, size: 48)),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Take photo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose photo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('How are the plants today?'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final c in conditions)
                ChoiceChip(
                  label: Text(c),
                  selected: _condition == c,
                  onSelected: (_) => setState(() => _condition = c),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (watered, weeded, ...)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _send,
            child: Text(_busy ? 'Sending...' : 'Send update'),
          ),
        ],
      ),
    );
  }
}