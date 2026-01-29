import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/providers/auth_provider.dart';
import 'package:life_auctor/utils/snackbar_helper.dart';

class DeleteAccountDialog extends StatelessWidget {
  final VoidCallback? onDeleted;

  const DeleteAccountDialog({super.key, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          const SizedBox(width: 8),
          Text(
            'Delete Account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () => _handleDelete(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    Navigator.pop(context);

    try {
      await context.read<AuthProvider>().deleteAccount();
      if (context.mounted) {
        onDeleted?.call();
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'Error deleting account: $e');
      }
    }
  }
}
