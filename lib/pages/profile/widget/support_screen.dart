import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            // color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Quick Contact Section
            Container(
              padding: const EdgeInsets.only(
                left: 52,
                right: 52,
                top: 40,
                bottom: 30,
              ),
              color: Colors.teal.withOpacity(0.1),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.support_agent,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'re here 24/7 to assist you',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Contact Options
            _buildContactCard(
              icon: Icons.phone,
              title: 'Call Us',
              subtitle: 'Toll-free: 1800-123-4567',
              color: Colors.green,
              onTap: () async {
                final Uri telUri = Uri.parse('tel:18001234567');

                if (await canLaunchUrl(telUri)) {
                  await launchUrl(telUri, mode: LaunchMode.externalApplication);
                } else {
                  Get.snackbar("Error", "Could not launch dialer");
                }
              },
            ),

            // _buildContactCard(
            //   icon: Icons.phone,
            //   title: 'WhatsApp',
            //   subtitle: 'Chat with us on WhatsApp',
            //   color: const Color(0xFF25D366),
            //   onTap: () async {
            //     final Uri whatsappUri = Uri.parse(
            //       'https://wa.me/918888888888?text=Hello%20I%20need%20help%20with%20my%20device',
            //     );
            //     if (await canLaunchUrl(whatsappUri)) {
            //       await launchUrl(whatsappUri);
            //     }
            //   },
            // ),
            _buildContactCard(
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@smartfixtech.com',
              color: Colors.blue,
              onTap: () async {
                final Uri emailUri = Uri.parse(
                  'mailto:support@smartfixtech.com',
                );

                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(
                    emailUri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  Get.snackbar("Error", "Could not open email app");
                }
              },
            ),

            const SizedBox(height: 16),

            // FAQ Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFAQItem(
                    'How long does repair take?',
                    'Most repairs are completed within 2-4 hours. Complex repairs may take 24-48 hours.',
                  ),
                  _buildFAQItem(
                    'Do you provide warranty?',
                    'Yes, all repairs come with a 90-day warranty on parts and labor.',
                  ),
                  _buildFAQItem(
                    'Can I track my repair?',
                    'Yes, you can track your repair status in the "My Orders" section.',
                  ),
                  _buildFAQItem(
                    'What if I\'m not satisfied?',
                    'We offer a 7-day satisfaction guarantee. Contact us within 7 days of repair.',
                  ),
                  _buildFAQItem(
                    'Do you use genuine parts?',
                    'Yes, we use high-quality parts sourced from authorized distributors.',
                  ),
                  _buildFAQItem(
                    'Is my data safe?',
                    'We prioritize your data privacy. You should backup your data before service.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Report Issue
            // Padding(
            //   padding: const EdgeInsets.all(16),
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       _showReportIssueDialog(context);
            //     },
            //     icon: const Icon(Icons.report_problem),
            //     label: const Text('Report an Issue'),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.teal,
            //       foregroundColor: Colors.white,
            //       minimumSize: const Size(double.infinity, 50),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white10,
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  // void _showReportIssueDialog(BuildContext context) {
  //   final issueController = TextEditingController();

  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text('Report an Issue'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text(
  //             'Please describe your issue in detail',
  //             style: TextStyle(fontSize: 14, color: Colors.grey),
  //           ),
  //           const SizedBox(height: 16),
  //           TextField(
  //             controller: issueController,
  //             maxLines: 5,
  //             decoration: InputDecoration(
  //               hintText: 'Describe your issue...',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
  //         ElevatedButton(
  //           onPressed: () {
  //             if (issueController.text.isNotEmpty) {
  //               // Here you would send the issue to your backend
  //               Get.back();
  //               Get.snackbar(
  //                 'Issue Reported',
  //                 'We will look into this and get back to you soon.',
  //                 snackPosition: SnackPosition.BOTTOM,
  //                 backgroundColor: Colors.teal,
  //                 colorText: Colors.white,
  //               );
  //             }
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.teal,
  //             foregroundColor: Colors.white,
  //           ),
  //           child: const Text('Submit'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
