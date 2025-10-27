import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "question": "How do I track my order?",
      "answer": "Go to your account and check the order history tab."
    },
    {
      "question": "How do I change my account information?",
      "answer": "Click the edit icon in your profile to update your details."
    },
    {
      "question": "How can I get promotions?",
      "answer": "Enable promotions toggle to receive special offers."
    },
    {
      "question": "What to do if my order is delayed?",
      "answer": "Contact support using the contact us option in profile."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FAQ")),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            title: Text(faq['question']!),
            children: [Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(faq['answer']!),
            )],
          );
        },
      ),
    );
  }
}
