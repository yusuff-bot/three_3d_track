import 'package:flutter/material.dart';
import 'ResetPasswordPage.dart'; // Your ResetPasswordPage
import 'login.dart';
import 'myaccount.dart';

class SettingsPage extends StatelessWidget {
  final String userName;
  final String userEmail;

  const SettingsPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  void _launchEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Need Help?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("For assistance, contact:"),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // You could use url_launcher to open email here
              },
              child: const Text(
                "3dtrack162914@gmail.com",
                style: TextStyle(
                  color: Color(0xFF1AB3E6),
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const SizedBox(), // Remove back button since it’s a tab
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Information
              const Text(
                "Account Information",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(userName),
                subtitle: Text(userEmail),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Could open edit profile screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AccountScreen()),
                    );
                  },
                ),
              ),
              ListTile(
                title: const Text("Change Password"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Notifications
              const Text(
                "Notifications",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text("Order Updates"),
                value: false,
                onChanged: (val) {},
              ),
              SwitchListTile(
                title: const Text("Promotions"),
                value: false,
                onChanged: (val) {},
              ),

              const SizedBox(height: 24),

              // Privacy Settings
              const Text(
                "Privacy Settings",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text("Data Sharing Preferences"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to privacy settings page
                },
              ),

              const SizedBox(height: 24),

              // Help & Support
              const Text(
                "Help & Support",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text("FAQ"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to FAQ page
                },
              ),
              ListTile(
                title: const Text("Contact Us"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _launchEmail(context),
              ),

              const SizedBox(height: 32),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                          (route) => false,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Log Out",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
