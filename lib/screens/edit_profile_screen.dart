import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/providers/auth_provider.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';
import 'package:life_auctor/widgets/form/form_label.dart';
import 'package:life_auctor/widgets/form/profile_text_field.dart';
import 'package:life_auctor/widgets/profile/profile_avatar.dart';
import 'package:life_auctor/widgets/profile/delete_account_dialog.dart';
import 'package:life_auctor/utils/snackbar_helper.dart';
import 'package:life_auctor/theme/app_sizes.dart';
import 'package:life_auctor/theme/app_text_styles.dart';

class EditProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const EditProfileScreen({super.key, this.onBack});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      SnackBarHelper.showError(context, 'Name cannot be empty');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().updateProfile(
        displayName: name,
        photoURL: null,
      );

      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Profile updated successfully');
        widget.onBack?.call();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: CustomAppBar(showBackButton: true, onBack: widget.onBack),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final padding = AppSizes.padding(width);
            final titleSize = AppSizes.titleSize(width);
            final labelSize = AppSizes.labelSize(width);

            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Profile',
                    style: AppTextStyles.title(context, titleSize),
                  ),
                  SizedBox(height: padding * 1.5),

                  _buildAvatarSection(width, padding, labelSize),
                  SizedBox(height: padding * 2),

                  const FormLabel('Display Name *'),
                  SizedBox(height: padding * 0.5),
                  ProfileTextField(
                    controller: _nameController,
                    hint: 'Enter your name',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: padding),

                  const FormLabel('Email'),
                  SizedBox(height: padding * 0.5),
                  ProfileTextField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                    enabled: false,
                  ),
                  SizedBox(height: padding * 0.5),
                  _buildEmailHint(labelSize, isDark),
                  SizedBox(height: padding * 3),

                  _buildSaveButton(padding, labelSize),
                  SizedBox(height: padding),
                  _buildDeleteButton(padding, labelSize),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarSection(double width, double padding, double labelSize) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          ProfileAvatar(
            radius: width * 0.15,
            onTap: () {
              SnackBarHelper.showInfo(context, 'Photo upload coming soon');
            },
          ),
          SizedBox(height: padding),
          Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: labelSize * 0.9,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailHint(double labelSize, bool isDark) {
    return Text(
      'Email cannot be changed',
      style: TextStyle(
        fontSize: labelSize * 0.85,
        color: isDark ? Colors.grey[500] : Colors.grey[500],
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildSaveButton(double padding, double labelSize) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGreen,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: labelSize * 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildDeleteButton(double padding, double labelSize) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => DeleteAccountDialog(onDeleted: widget.onBack),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 2),
          padding: EdgeInsets.symmetric(vertical: padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Delete Account',
          style: TextStyle(
            fontSize: labelSize * 1.1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
