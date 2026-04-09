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
            'By accessing and using our repair services, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
          ),

          _buildSection(
            '2. Service Description',
            '''We provide professional repair services for electronic devices including smartphones, tablets, laptops, and other gadgets. All repairs are performed by certified technicians using quality parts.

Screen and display repairs,
Battery replacement services,
Water damage recovery,
Hardware and software troubleshooting,
Component replacement and upgrades''',
          ),

          _buildSection(
            '3. Customer Responsibilities',
            '• Before submitting your device for repair, customers must:\n• Backup all important data as we are not responsible for data loss\n• Disable all security features (Find My iPhone, Google Account Lock, etc.)\n• Ensure device is paid off (if financed)\n• Provide accurate information about the device issue\n• Remove any personal accessories (cases, screen protectors, SIM cards)\n• Present valid ID proof and contact information',
          ),

          _buildSection(
            '4. Service Warranty',
            'All repairs come with a 90-day warranty covering parts and labor. The warranty does not cover: water damage after repair, physical damage, unauthorized repairs, or software issues caused by user.',
          ),
          _buildSection(
            '5. Diagnostic Service',
            'Our diagnostic service is designed to identify issues with your device quickly and accurately. This service includes:\n• Comprehensive device assessment\n• Identification of hardware and software issues\n• Detailed report of findings\n• Recommendations for repair or replacement',
          ),
          _buildSection(
            '6. Limitation of Liability',
            '''We are not responsible for:

Any data loss during the repair process
Damage caused by liquid, physical impact, or misuse
Issues not related to the original repair
Compatibility issues with third-party accessories or software
Delays caused by parts availability or unforeseen circumstances''',
          ),

          _buildSection(
            '7. Pricing and Payment',
            'Prices are subject to change without notice. Payment is due upon service completion. We accept credit/debit cards, UPI, and cash.',
          ),

          _buildSection(
            '8. Contact Us',
            'If you have any questions or concerns about our policies, please contact us at support@smartfix.com.',
          ),
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
            '1. Introduction',
            'We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our repair services.',
          ),

          _buildSection(
            '2. Information We Collect',
            'We collect various types of information to provide and improve our services:\n\n'
                '• Personal Information: Name,phone number, and physical address\n'
                '• Device Information: Device model, IMEI/serial number, operating system, and issue description\n'
                '• Payment Information: Billing details and transaction records (processed securely)\n'
                '• Service Records: Repair history, warranty information, and service preferences\n'
                '• Communication Data: Customer service interactions, feedback, and support tickets',
          ),

          _buildSection(
            '3. How We Use Your Information',
            'Your information is used for the following purposes:\n\n'
                '• Processing and completing repair services\n'
                '• Communicating repair status and service updates\n'
                '• Maintaining service records and warranty information\n'
                '• Processing payments and generating invoices\n'
                '• Improving our services and customer experience\n'
                '• Sending promotional offers and service reminders (with consent)\n'
                '• Complying with legal obligations and regulatory requirements',
          ),

          _buildSection(
            '4. Data Security',
            'We implement industry-standard security measures to protect your personal information:\n\n'
                '• Encrypted data transmission and storage\n'
                '• Secure payment processing through certified gateways\n'
                '• Limited access to personal data by authorized personnel only\n'
                '• Regular security audits and system updates\n'
                '• Physical security measures at our service centers',
          ),

          _buildSection(
            '5. Device Data Privacy',
            'We understand the sensitive nature of data on your devices. Our technicians are trained to:\n\n'
                '• Access only necessary areas of your device for repair purposes\n'
                '• Not browse, copy, or share any personal data\n'
                '• Respect your privacy throughout the repair process\n'
                '• Delete all temporary data created during diagnostics\n\n'
                'Important: We strongly recommend backing up your data before repair, as we cannot guarantee data preservation during the repair process.',
          ),

          _buildSection(
            '6. Third-Party Sharing',
            'We do not sell, trade, or rent your personal information to third parties. We may share limited information with:\n\n'
                '• Payment processors for transaction completion\n'
                '• Shipping partners for device pickup and delivery\n'
                '• Parts suppliers for warranty claims (device info only)\n'
                '• Legal authorities when required by law',
          ),

          _buildSection(
            '7. Cookies and Tracking',
            'Our website uses cookies to enhance user experience and analyze site traffic. You can control cookie preferences through your browser settings. We use cookies for:\n\n'
                '• Maintaining user sessions and preferences\n'
                '• Analyzing website usage and performance\n'
                '• Personalizing content and advertisements',
          ),

          _buildSection(
            '8. Your Rights',
            'You have the right to:\n\n'
                '• Access your personal information we hold\n'
                '• Request correction of inaccurate data\n'
                '• Request deletion of your personal information\n'
                '• Opt-out of marketing communications\n'
                '• Withdraw consent for data processing',
          ),

          _buildSection(
            '9. Data Retention',
            'We retain your personal information for as long as necessary to provide services and comply with legal obligations. Service records are typically maintained for 3-5 years for warranty and support purposes.',
          ),

          _buildSection(
            '10. Children\'s Privacy',
            'Our services are not intended for children under 18. We do not knowingly collect personal information from minors without parental consent.',
          ),

          _buildSection(
            '11. Contact Us',
            'For any privacy-related questions or to exercise your rights, please contact our Data Protection Officer through our contact page or email us at privacy@company.com',
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
            'What\'s NOT Covered',
            '''The warranty does not cover damage caused by:

Any type of damages, Blank screen, any types of lines, any types of spots, colour spreading & flickering on screen Not Covered in warranty
We do not cover any type of accidental damage, and our warranty is invalid in all such circumstances. The warranty does not cover either indirect or direct harm or damage caused by accidents
Any display problems that occur without the need for user intervention and are connected to screen quality, notably visible lines and blank screens.
Excessive or serious damage to the device or screen, where there is a likelihood that internal components have been harmed. Significant visible damage may cause internal components to be harmed, resulting in screen or other system issues. Any part replacement for which such damage is reported at the time of order fulfillment is not covered by the warranty. As any component damage/malfunction would become evident after promptly disassembling the device and reassembly, Ongofix Repair or any of its representatives would not be accountable or liable for these issues.
Mishandling that causes the frame to bend, twist, or break will not be tolerated. Repeated mistreatment of the screen, such as a forceful push, may cause discoloration or line on the display.
Subsequent drops, whether accidental or intentional.
Water caused damage to the device.
Internal hardware tampering or altering
Damage caused by attempted client self-repairs
Unrelated to the repair, issues with software
Devices that have been jailbroken
Damages that are unrelated to the the original repairs
Any data loss that occurs as a consequence of the repair. (We urge customers to pull up a backup of their data before the repair service).
in case the device is transferred or sold to another user. The second-hand user will not be entitled to the warranty.
Warranty on Battery is NOT valid in case of excessive charging, battery swell, overnight charging or use of non-OEM Charging Cable/Adapters''',
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
            'Warranty Process',
            '''Report Issue: Contact us or visit our service center with your device and repair invoice
Diagnostic Check: Our technicians will examine the device to verify warranty eligibility
Approval: If the issue is covered under warranty, we'll proceed with the repair at no cost
Repair: The same or similar issue will be fixed using quality parts
Testing: Thorough quality testing before returning the device
Return: Device returned with extended warranty coverage for the repaired component''',
          ),
          _buildSection(
            'Important Notes',
            '''• Keep your repair invoice safe as it serves as proof of warranty
• Warranty coverage begins from the date of service completion
• Multiple repairs of the same issue will be covered under a single warranty period
• We reserve the right to replace instead of repair if deemed necessary
• Warranty terms may vary for specific promotional offers''',
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
