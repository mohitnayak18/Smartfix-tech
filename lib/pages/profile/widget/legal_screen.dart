import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Legal Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
              Tab(text: 'Refund Policy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Terms of Service
            _buildTermsOfService(),

            // Privacy Policy
            _buildPrivacyPolicy(),

            // Refund Policy
            _buildRefundPolicy(),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsOfService() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Last Updated: January 2024',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),

          _buildSection(
            '1. Acceptance of Terms',
            'By accessing and using SmartFix Tech services, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.',
          ),

          _buildSection(
            '2. Service Description',
            'SmartFix Tech provides mobile device repair services including but not limited to: screen replacement, battery replacement, water damage repair, software troubleshooting, and hardware diagnostics.',
          ),

          _buildSection(
            '3. User Responsibilities',
            '• Provide accurate information about your device\n• Backup your data before service\n• Remove screen locks and passwords\n• Ensure device is paid off (if financed)\n• Provide proof of purchase for warranty claims',
          ),

          _buildSection(
            '4. Service Warranty',
            'All repairs come with a 90-day warranty covering parts and labor. The warranty does not cover: water damage after repair, physical damage, unauthorized repairs, or software issues caused by user.',
          ),

          _buildSection(
            '5. Limitation of Liability',
            'SmartFix Tech shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from our services, including but not limited to loss of data.',
          ),

          _buildSection(
            '6. Pricing and Payment',
            'Prices are subject to change without notice. Payment is due upon service completion. We accept credit/debit cards, UPI, and cash.',
          ),

          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Effective Date: February 2026',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),

          _buildSection(
            'Information We Collect',
            '• Personal Information: Name, phone number, email address\n• Device Information: IMEI number, device model, serial number\n• Service History: Previous repairs, issues reported\n• Payment Information: Transaction details (we don\'t store card numbers)',
          ),

          _buildSection(
            'How We Use Your Information',
            '• To provide repair services\n• To communicate about service status\n• To improve our services\n• To comply with legal obligations\n• To prevent fraud',
          ),

          _buildSection(
            'Data Protection',
            'We implement industry-standard security measures to protect your personal information. All data is encrypted during transmission and storage.',
          ),

          _buildSection(
            'Information Sharing',
            'We do not sell your personal information. We may share information with:\n• Service partners (with your consent)\n• Law enforcement (when required by law)\n• Payment processors (for transactions)',
          ),

          _buildSection(
            'Your Rights',
            '• Access your personal data\n• Correct inaccurate data\n• Request data deletion\n• Opt-out of marketing communications\n• Export your data',
          ),

          _buildSection(
            'Data Retention',
            'We retain your information for as long as necessary to provide services and comply with legal obligations (typically 3 years).',
          ),

          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildRefundPolicy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Refund & Cancellation Policy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Last Updated: January 2024',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),

          _buildSection(
            'Service Cancellation',
            '• Free cancellation within 2 hours of booking\n• Cancellation after 2 hours: 25% fee\n• Cancellation after technician dispatch: 50% fee\n• Same-day cancellation: No refund',
          ),

          _buildSection(
            'Repair Refunds',
            'If we cannot complete the repair, you will receive a full refund. Partial refunds may be issued for:\n• Devices with additional damage found\n• Devices requiring parts we don\'t have\n• Customer changing mind mid-repair',
          ),

          _buildSection(
            'Warranty Claims',
            'If the same issue occurs within 90 days, we will repair at no cost. Refunds for warranty claims are considered on a case-by-case basis.',
          ),

          _buildSection(
            'Parts Replacement',
            'If we ordered parts for your device, cancellation fees may apply based on supplier return policies.',
          ),

          _buildSection(
            'Refund Process',
            '• Refunds processed within 5-7 business days\n• Original payment method will be credited\n• You will receive email confirmation\n• Contact support if refund not received',
          ),

          _buildSection(
            'Non-Refundable Items',
            '• Diagnostic fees (if repair is declined)\n• Shipping charges\n• Consumable items\n• Express service fees',
          ),

          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'For any legal inquiries or concerns, please contact us at:',
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'legal@smartfixtech.com',
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              }
            },
            child: const Row(
              children: [
                Icon(Icons.email, color: Colors.teal, size: 16),
                SizedBox(width: 8),
                Text(
                  'legal@smartfixtech.com',
                  style: TextStyle(
                    color: Colors.teal,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
