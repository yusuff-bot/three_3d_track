import 'package:flutter/material.dart';
import 'login.dart';
import 'sign_in.dart';
import 'owners_login.dart';
import 'term_page.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // clean white background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Hero Image (Top)
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: Image.asset(
                    'assets/wp.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.3, // taller image
                  ),
                ),

                const SizedBox(height: 32),

                // 🔹 Title
                const Text(
                  "Welcome to 3D Track App",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Description
                const Text(
                  "Monitor your 3D prints in real time and manage your workflow effortlessly.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280), // gray
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 40),

                // 🔹 Log In Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF), // blue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 Sign Up Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6), // light gray
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151), // dark gray
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 230),

                // 🔹 Footer Links
                Column(
                  children: [
                    // 🔹 Terms & Privacy Policy
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsAndConditionsPage(
                              userName: "Guest", // ✅ Fix: pass username
                            ),
                          ),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF), // light gray
                          ),
                          children: [
                            TextSpan(text: "By continuing, you agree to our "),
                            TextSpan(
                              text: "Terms & Privacy Policy",
                              style: TextStyle(
                                decoration: TextDecoration.underline, // underline only this part
                              ),
                            ),
                            TextSpan(text: "."),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🔹 Owner Login
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OwnerLoginPage()),
                        );
                      },
                      child: const Text(
                        "Owner Login",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
