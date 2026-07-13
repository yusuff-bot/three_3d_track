import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'profileeditpage.dart';
import 'faq.dart';
import 'orderhistory.dart';
import 'ownerdashboard.dart';

class SettingsPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String phoneNumber;

  const SettingsPage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.phoneNumber = "+91 1234567890",
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String userName;
  late String userEmail;
  late String phoneNumber;
  bool orderUpdates = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    userEmail = widget.userEmail;
    phoneNumber = widget.phoneNumber;
    _checkOwnerRole();
  }

  Future<void> _checkOwnerRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data()?['role'] == 'owner') {
          setState(() {
            _isOwner = true;
          });
        }
      } catch (_) {}
    }
  }

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
            const Text(
              "3dtrack162914@gmail.com",
              style: TextStyle(
                color: Color(0xFF1AB3E6),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
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

  void _sendOrderUpdateSMS() {
    if (orderUpdates) {
      print("Order update SMS sent to $phoneNumber");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const SizedBox(),
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
              // Account Info
              const Text(
                "Account Information",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(userName),
                subtitle: Text("$userEmail\n$phoneNumber"),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileEditPage(
                          name: userName,
                          email: userEmail,
                          phone: phoneNumber,
                          onSave: (newName, newEmail, newPhone) {
                            setState(() {
                              userName = newName;
                              userEmail = newEmail;
                              phoneNumber = newPhone;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              ListTile(
                title: const Text("Order History"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Notifications
              const Text(
                "Notifications",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SwitchListTile(
                title: const Text("Order Updates"),
                value: orderUpdates,
                onChanged: (val) {
                  setState(() {
                    orderUpdates = val;
                    _sendOrderUpdateSMS();
                  });
                },
              ),

              const SizedBox(height: 24),

              // Settings Section
              const Text(
                "Settings",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("About Us"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text("Contact Us"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _launchEmail(context),
              ),
              ListTile(
                leading: const Icon(Icons.star_rate_outlined),
                title: const Text("Reviews & Ratings"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewRatingPage(
                        userName: userName,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Help & Support
              const Text(
                "Help & Support",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ListTile(
                title: const Text("FAQ"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FAQPage()),
                  );
                },
              ),

              if (_isOwner) ...[
                const SizedBox(height: 24),
                const Text(
                  "Owner Portal",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.blueAccent),
                  title: const Text("Switch to Owner Dashboard"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OwnerDashboard(username: userEmail),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user_role');
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const Login()),
                            (route) => false,
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Log Out",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

// -------- About Us Page ----------
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "3D_TRACK is a smart and intuitive platform built to simplify every step of a 3D printing business."
              "Our goal is to streamline production, management, and customer interaction for 3D printing shops and individuals who bring ideas to life through innovation.\n"
              "We combine technology, creativity, and convenience to create a seamless workflow from order placement to final delivery.\n\n"
              "💡 Our Mission\n"
              "To empower makers, designers, and businesses with a platform that makes 3D printing management effortless, transparent, and efficient.\n\n"
              "🤝 Our Vision\n"
              "To be the go-to digital hub for 3D printing enterprises — bridging the gap between creativity and management through powerful tools.We aim to provide high-quality 3D printing management solutions that make tracking, managing, and analyzing printing projects effortless.",
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}

// -------- Interactive Review & Rating Page ----------
class ReviewRatingPage extends StatefulWidget {
  final String userName;
  const ReviewRatingPage({super.key, required this.userName});

  @override
  State<ReviewRatingPage> createState() => _ReviewRatingPageState();
}

class _ReviewRatingPageState extends State<ReviewRatingPage> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _seedDefaultReviewsIfEmpty();
  }

  Future<void> _seedDefaultReviewsIfEmpty() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('reviews').limit(1).get();
      if (snap.docs.isEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        final defaultReviews = [
          {"name": "Alice", "rating": 5, "comment": "Excellent products and fast delivery!", "timestamp": FieldValue.serverTimestamp()},
          {"name": "Bob", "rating": 4, "comment": "Good quality but packaging could improve.", "timestamp": FieldValue.serverTimestamp()},
        ];
        for (var review in defaultReviews) {
          final docRef = FirebaseFirestore.instance.collection('reviews').doc();
          batch.set(docRef, review);
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  void _addReview() async {
    if (_selectedRating == 0 || _commentController.text.trim().isEmpty) return;

    final comment = _commentController.text.trim();
    final rating = _selectedRating;

    setState(() {
      _selectedRating = 0;
      _commentController.clear();
    });

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        "name": widget.userName,
        "rating": rating,
        "comment": comment,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit review: $e")),
        );
      }
    }
  }

  Widget _buildStarSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
            (index) => IconButton(
          onPressed: () {
            setState(() => _selectedRating = index + 1);
          },
          icon: Icon(
            index < _selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(review["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: List.generate(
                5,
                    (index) => Icon(
                  index < review["rating"] ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(review["comment"]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews & Ratings"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStarSelector(),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: "Write your review...",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Submit Review"),
            ),
            const Divider(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "All Reviews",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text("No reviews yet."));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _buildReviewCard(data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
