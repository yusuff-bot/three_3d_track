import 'package:flutter/material.dart';
import 'customerhomepage.dart'; // Make sure this points to your actual customer homepage file

class TermsAndConditionsPage extends StatefulWidget {
  final String userName; // Required username/email
  const TermsAndConditionsPage({super.key, required this.userName});

  @override
  State<TermsAndConditionsPage> createState() =>
      _TermsAndConditionsPageState(); // Proper state class
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _accepted = false;

  void _handleAccept() {
    if (_accepted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CustomerHomePage(userName: widget.userName,userEmail:"",
              ),// Pass username to homepage
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "❌ Login cannot be accepted until you accept Terms and Conditions.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D80F2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "📜 Terms & Conditions and Privacy Policy",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              """
Welcome to our store! Before using your account, please read these Terms and Conditions carefully.

1️⃣ **Account Usage**
By logging in, you agree to use this platform responsibly and to provide accurate information.

2️⃣ **Purchases & Orders**
All orders placed are subject to product availability and store policies. Refunds or replacements follow the seller’s guidelines.

3️⃣ **Data Privacy**
Your personal data (name, address, contact details) will be stored securely and used only for fulfilling your orders.

4️⃣ **Payment Security**
Payments are processed securely. We do not store card details or payment credentials.

5️⃣ **User Conduct**
You agree not to misuse or abuse the app, attempt fraud, or engage in harmful behavior.

6️⃣ **Liability**
We are not responsible for delivery delays or technical issues beyond our control.

7️⃣ **Changes to Policy**
We may update these terms periodically. Continued use of the app means you accept those updates.

By accepting, you agree to our Terms, Conditions, and Privacy Policy.
              """,
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Checkbox(
                  value: _accepted,
                  activeColor: const Color(0xFF0D80F2),
                  onChanged: (value) {
                    setState(() {
                      _accepted = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    "I have read and accept the Terms and Conditions.",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D80F2),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _handleAccept,
                  icon: const Icon(Icons.check),
                  label: const Text("Accept"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "❌ Login cannot be accepted until you accept Terms and Conditions.",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.close),
                  label: const Text("Don’t Accept"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
