import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String aboutDescription =
"India’s Trusted Mobile Repair Platform\n\n"
"At SmartFix Technology, our goal is to make mobile repair services easier, faster, and more reliable than ever before. We are committed to building a trustworthy platform that offers professional repair solutions for all major smartphone brands.\n\n"
"With our seamless user experience and skilled technicians, we ensure a hassle-free service experience for customers across various repair needs such as screen replacement, battery issues, software problems, and more.\n\n"
"Our platform is designed to provide convenience with doorstep service, transparent pricing, secure handling of devices, and timely updates. Whether it’s a minor fix or a major repair, we aim to deliver quality service you can trust.\n\n"
"With reliable support, easy booking, and secure service processes, you can now repair your device smarter, faster, and stress-free in just a few clicks.\n\n"
"#RepairMadeSimple";
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔥 Gradient Header (Modern Style)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.phone_android,
                    color: Colors.teal,
                    size: 35,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "SmartFix Technology",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Book. Repair. Relax.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🔥 Info Cards (Horizontal Style)
                Row(
                  children: [
                    Expanded(child: _miniCard("Version", "1.0.8")),
                    const SizedBox(width: 10),
                    Expanded(child: _miniCard("Update", "April 2026")),
                  ],
                ),
                const SizedBox(height: 10),
                _miniCard("Android", "12.0+"),

                const SizedBox(height: 20),

                // 🔥 Feature List (Modern List)
                const Text(
                  "Features",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),

                _modernTile(Icons.build, "Repair Services"),
                _modernTile(Icons.person, "Expert Technicians"),
                _modernTile(Icons.price_check, "Best Pricing"),
                // _modernTile(Icons.track_changes, "Live Tracking"),
                _modernTile(Icons.security, "Secure Service"),

                const SizedBox(height: 20),

                // 🔥 Action Buttons (Premium Style)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    final Uri email = Uri(
                      scheme: 'mailto',
                      path: 'mohitknayak18@gmail.com',
                    );
                    await launchUrl(email);
                  },
                  child: Text(
                    "Contact Support",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                SizedBox(height: 10),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    _launchPlayStore();
                  },
                  child: const Text(
                    "Rate App ⭐",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),

                // const SizedBox(height: 20),
                const SizedBox(height: 20),

// 🔥 About Description Section
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "About SmartFix",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        aboutDescription,
        style: TextStyle(
          color: Colors.grey.shade700,
          height: 1.5,
          fontSize: 13,
        ),
      ),
    ],
  ),
),

                const Center(
                  child: Text(
                    "© 2026 SmartFix Technology",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPlayStore() async {
    final Uri url = Uri.parse(
      "https://play.google.com/store/apps/details?id=com.flutter.smartfixapp&pcampaignid=web_share",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch Play Store';
    }
  }

  // 🔹 Mini Card
  Widget _miniCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // 🔹 Modern Tile
  Widget _modernTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }
}
