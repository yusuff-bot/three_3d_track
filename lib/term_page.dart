import 'package:flutter/material.dart';
import 'customerhomepage.dart'; // replace with actual customer homepage

class TermsAndConditionsPage extends StatefulWidget {
  final bool requireAgreement; // true for Sign Up, false for Login
  const TermsAndConditionsPage({
    super.key,
    this.requireAgreement = false,
  });

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _accepted = false;

  void _handleAccept() {
    if (_accepted) {
      Navigator.pop(context, true); // return true to Sign Up page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ You must accept Terms and Conditions to continue."),
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
        backgroundColor: widget.requireAgreement
            ? const Color(0xFF1AB3E6)
            : const Color(0xFF0D80F2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              " Terms & Conditions and Privacy Policy ",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              """
     Welcome to 3D Track! Before using your account, please read these Terms and Conditions carefully. By accessing or using our app, you agree to be bound by these terms.

1️. **Account Usage**
- By logging in or signing up, you agree to provide accurate and truthful information.
- You are responsible for maintaining the confidentiality of your account credentials.
- You must not share your account with others or allow unauthorized access.

2. **Purchases & Orders**
- All orders are subject to product availability, stock limitations, and store policies.
- 3D Track is not liable for delays caused by shipping partners or third-party services.
- Refunds, cancellations, or replacements are handled according to the seller’s policies and applicable laws.
- Prices, promotions, and discounts are subject to change without notice.

3. **Data Privacy**
- We collect personal data such as name, email, phone number, and order details to provide our services.
- Data is stored securely and will not be shared with third parties without consent except as required by law.
- You consent to receive order-related notifications, promotional emails, or updates from 3D Track.

4. **Payment & Security**
- Payments are processed via secure gateways. We do not store your card details or payment credentials.
- You must ensure sufficient funds for purchases and confirm payment details before submission.
- Any fraudulent payment attempts will result in account suspension or legal action.

5. **User Conduct**
- You agree not to misuse, manipulate, or exploit the app in any way.
- Prohibited actions include hacking, reverse engineering, spamming, and sharing inappropriate content.
- Users must respect the intellectual property rights of 3D Track and its partners.

6. **Content & Intellectual Property**
- All content, designs, and materials in the app are owned by 3D Track or its licensors.
- You may not copy, modify, distribute, or create derivative works without explicit permission.
- Uploaded designs or files must not infringe on third-party rights.

7. **Liability**
- 3D Track is not responsible for technical issues, connectivity problems, or loss of data.
- We disclaim liability for indirect, incidental, or consequential damages arising from app use.
- We are not liable for actions taken based on advice or information in the app.

8. **Modifications & Updates**
- Terms and conditions may change periodically. Continued use of the app constitutes acceptance of new terms.
- The app may be updated to include new features, which could change functionality.

9. **Termination*
- 3D Track reserves the right to suspend or terminate your account for violations of these terms.
- You may also request account deletion, subject to applicable laws and data retention policies.

10. **Governing Law**
- These terms are governed by applicable laws of your country or region.
- Any disputes will be subject to the jurisdiction of the relevant courts.

By using the 3D Track app, you acknowledge that you have read, understood, and agreed to these Terms, Conditions, and Privacy Policy. Your continued use confirms acceptance of any updates or modifications made to these terms.
"""
              ,
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 30),

            // Only show checkbox and continue button for Sign Up
            if (widget.requireAgreement) ...[
              Row(
                children: [
                  Checkbox(
                    value: _accepted,
                    activeColor: const Color(0xFF1AB3E6),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1AB3E6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _handleAccept,
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
