import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _orderUpdates = true;
  bool _promotions = false;
  int _selectedIndex = 0;

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Account Section
            Card(
              margin: const EdgeInsets.all(12),
              elevation: 2,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: const Text("John Doe",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("johndoe@email.com"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to Edit Profile page
                  },
                ),
              ),
            ),

            // Change Password
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: ListTile(
                title: const Text("Change Password"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to Change Password page
                },
              ),
            ),

            // Notifications
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Order Updates"),
                    value: _orderUpdates,
                    onChanged: (val) {
                      setState(() {
                        _orderUpdates = val;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Promotions"),
                    value: _promotions,
                    onChanged: (val) {
                      setState(() {
                        _promotions = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Privacy Settings
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: ListTile(
                title: const Text("Privacy Settings"),
                subtitle: const Text("Data Sharing"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to Privacy Settings page
                },
              ),
            ),

            // Help & Support
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    title: const Text("FAQ"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to FAQ page
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text("Contact Us"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to Contact page
                    },
                  ),
                ],
              ),
            ),

            // Log Out
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  // Log out action
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
