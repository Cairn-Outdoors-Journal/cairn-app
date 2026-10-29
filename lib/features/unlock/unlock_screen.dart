import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/keys/local_keys.dart';
import '../../data/providers.dart';
import '../../design/tokens.dart';

/// Shown instead of the shelf when the journal is on this phone but no key
/// here opens it (after a restore, or on a new phone): the recovery key
/// unlocks it. Also used by the data inspector.
class UnlockForm extends ConsumerStatefulWidget {
  const UnlockForm({super.key});

  @override
  ConsumerState<UnlockForm> createState() => _UnlockFormState();
}

class _UnlockFormState extends ConsumerState<UnlockForm> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    try {
      await unlockRestoredJournal(_controller.text);
      ref.invalidate(journalProvider);
    } on FormatException catch (error) {
      setState(() => _error = error.message);
    } on WrongRecoveryKey {
      setState(() => _error = 'This key belongs to a different journal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        const Text(
          'Unlock your journal',
          style: TextStyle(
            fontFamily: CairnFonts.writing,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your journal is on this phone, but the key that opens it isn’t. '
          'That happens after restoring from a backup or moving to a new '
          'phone. Enter the recovery key you wrote down when you started.',
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('recovery-key'),
          controller: _controller,
          maxLines: 3,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontFamily: CairnFonts.stamp),
          decoration: InputDecoration(
            labelText: 'Recovery key',
            errorText: _error,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _unlock, child: const Text('Unlock')),
      ],
    );
  }
}
