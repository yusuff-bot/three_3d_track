import 'package:flutter/material.dart'; // <-- Add this import

//-------------------------------------------------
// Reusable Widget: Bottom Navigation Bar
// (Based on common element in screenshots)
//-------------------------------------------------
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        // Handle navigation logic here
        // e.g., using a PageController or Navigator
      },
      type: BottomNavigationBarType.fixed, // Shows all labels
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Expenses',
        ),
      ],
    );
  }
}