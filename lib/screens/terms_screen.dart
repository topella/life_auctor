import 'package:flutter/material.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';

class TermsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final Function(int)? onNavigate;

  const TermsScreen({super.key, this.onBack, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: CustomAppBar(
        showBackButton: true,
        onBack: onBack,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                '1. Acceptance of Terms',
                'By accessing and using LifeAuctor, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these terms, please do not use our service.',
                isDark,
              ),

              _buildSection(
                '2. Description of Service',
                'LifeAuctor provides a platform for managing household items, tracking expiry dates, creating shopping lists, and sharing lists with a community. We reserve the right to modify or discontinue the service at any time.',
                isDark,
              ),

              _buildSection(
                '3. User Accounts',
                'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
                isDark,
              ),

              _buildSection(
                '4. User Content',
                'You retain ownership of all content you post to LifeAuctor. By posting content, you grant us a worldwide, non-exclusive, royalty-free license to use, reproduce, and display that content in connection with the service.',
                isDark,
              ),

              _buildSection(
                '5. Prohibited Uses',
                'You may not use LifeAuctor to:\n• Violate any laws or regulations\n• Post false, inaccurate, or misleading information\n• Impersonate any person or entity\n• Transmit viruses or malicious code\n• Harass or harm other users',
                isDark,
              ),

              _buildSection(
                '6. Intellectual Property',
                'The service and its original content, features, and functionality are owned by LifeAuctor and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
                isDark,
              ),

              _buildSection(
                '7. Disclaimer of Warranties',
                'LifeAuctor is provided "as is" without warranties of any kind, either express or implied. We do not warrant that the service will be uninterrupted, secure, or error-free.',
                isDark,
              ),

              _buildSection(
                '8. Limitation of Liability',
                'In no event shall LifeAuctor be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.',
                isDark,
              ),

              _buildSection(
                '9. Termination',
                'We may terminate or suspend your account and access to the service immediately, without prior notice, for any reason, including breach of these terms. Upon termination, your right to use the service will immediately cease.',
                isDark,
              ),

              _buildSection(
                '10. Changes to Terms',
                'We reserve the right to modify these terms at any time. We will notify users of any material changes. Your continued use of the service after such modifications constitutes acceptance of the updated terms.',
                isDark,
              ),

              _buildSection(
                '11. Contact Information',
                'If you have any questions about these Terms, please contact us at:\nEmail: support@lifeauctor.com',
                isDark,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
