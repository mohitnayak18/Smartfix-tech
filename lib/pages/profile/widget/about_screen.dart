import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'About App',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Logo/Header
            Container(
              padding: const EdgeInsets.only(
                left: 45,
                right: 45,
                top: 30,
                bottom: 30,
              ),
              color: Colors.teal.withOpacity(0.1),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SmartFix Tech',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your Trusted Mobile Service Partner',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // App Details
            _buildInfoTile(
              icon: Icons.info_outline,
              title: 'App Version',
              value: '1.0.0',
            ),
            _buildInfoTile(
              icon: Icons.update,
              title: 'Last Updated',
              value: 'February 2026',
            ),
            _buildInfoTile(
              icon: Icons.android,
              title: 'Compatibility',
              value: 'Android 5.0+',
            ),
            // _buildInfoTile(
            //   icon: Icons.ios_share,
            //   title: 'iOS Compatibility',
            //   value: 'iOS 12.0+',
            // ),
            _buildInfoTile(
              icon: Icons.storage,
              title: 'App Size',
              value: '~55 MB',
            ),

            const Divider(
              height: 2,
              thickness: 3,
              color: Color.fromARGB(255, 218, 217, 217),
            ),

            // Features Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Features',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    Icons.home_repair_service,
                    'Mobile Repair Services',
                    'Expert repair for all mobile brands',
                  ),
                  _buildFeatureItem(
                    Icons.person,
                    'Professional Technicians',
                    'Certified and experienced technicians',
                  ),
                  _buildFeatureItem(
                    Icons.local_offer,
                    'Best Prices',
                    'Competitive rates and special offers',
                  ),
                  _buildFeatureItem(
                    Icons.track_changes,
                    'Real-time Tracking',
                    'Track your repair status anytime',
                  ),
                  _buildFeatureItem(
                    Icons.support_agent,
                    '24/7 Support',
                    'Round-the-clock customer assistance',
                  ),
                  _buildFeatureItem(
                    Icons.security,
                    'Secure Service',
                    'Your device safety is our priority',
                  ),
                ],
              ),
            ),

            const Divider(
              height: 2,
              thickness: 3,
              color: Color.fromARGB(255, 218, 217, 217),
            ),

            // Developer Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Developed By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.code, color: Colors.white),
                    ),
                    title: Text('SmartFix Tech Team'),
                    subtitle: Text('Version 1.0.0'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'support@smartfixtech.com',
                        query: 'subject=About App Inquiry',
                      );
                      if (await canLaunchUrl(emailLaunchUri)) {
                        await launchUrl(emailLaunchUri);
                      }
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Contact Developer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
