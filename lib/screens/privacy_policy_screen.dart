import 'package:flutter/material.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final Function(int)? onNavigate;

  const PrivacyPolicyScreen({super.key, this.onBack, this.onNavigate});

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
                'Privacy Policy',
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
                '1. Information We Collect',
                'LifeAuctor collects information you provide directly to us when you create an account, such as your name, email address, and profile information. We also collect information about your use of our services, including items you track, shopping lists you create, and your preferences.',
                isDark,
              ),

              _buildSection(
                '2. How We Use Your Information',
                'We use the information we collect to provide, maintain, and improve our services, to communicate with you, to monitor and analyze trends and usage, and to personalize your experience with LifeAuctor.',
                isDark,
              ),

              _buildSection(
                '3. Information Sharing',
                'We do not sell your personal information. We may share your information with third-party service providers who perform services on our behalf, such as hosting and data storage services. If you choose to share lists with the community, that information will be visible to other users.',
                isDark,
              ),

              _buildSection(
                '4. Data Security',
                'We implement appropriate technical and organizational measures to protect your personal information. However, no method of transmission over the Internet or electronic storage is 100% secure.',
                isDark,
              ),

              _buildSection(
                '5. Your Rights',
                'You have the right to access, correct, or delete your personal information. You can do this through your account settings or by contacting us directly. You also have the right to object to or restrict certain processing of your data.',
                isDark,
              ),

              _buildSection(
                '6. Data Retention',
                'We retain your information for as long as your account is active or as needed to provide you services. If you delete your account, we will delete your personal information, except where we are required to retain it for legal purposes.',
                isDark,
              ),

              _buildSection(
                '7. Children\'s Privacy',
                'LifeAuctor is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us.',
                isDark,
              ),

              _buildSection(
                '8. Changes to This Policy',
                'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
                isDark,
              ),

              _buildSection(
                '9. Contact Us',
                'If you have any questions about this Privacy Policy, please contact us at:\nEmail: support@lifeauctor.com',
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
