import 'package:currensee_convertor_app/CurrencyConvertor.dart';
import 'package:currensee_convertor_app/conversion_history_screen.dart';
import 'package:currensee_convertor_app/new_trend.dart';
import 'package:currensee_convertor_app/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // Track the index of the selected item

  // List of widgets corresponding to different tabs in the BottomNavigationBar
  final List<Widget> _pages = [
    CurrencyConverter(), // Currency converter screen
    ConversionHistoryScreen(), // Placeholder for history
    NewsTrendsScreen(), // Placeholder for alerts
    Center(child: Text('Settings')), // Placeholder for settings
  ];

  final List<String> _titles = [
    'Currency Converter',
    'Conversion History',
    'Rate Alerts',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(color: AppColors.white),
        ), // Title for each page
        backgroundColor: AppColors.secondaryColor,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(color: AppColors.white),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary2Color,
              ),
            ),
            ListTile(
              title: Text('Set Rate'),
              onTap: () {
                Navigator.pushNamed(context, '/setrate');
              },
            ),
            ListTile(
              title: Text('FAQs'),
              onTap: () {
                Navigator.pushNamed(context, '/faqs');
              },
            ),
            ListTile(
              title: Text('Feedback'),
              onTap: () {
                Navigator.pushNamed(context, '/feedback');
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                try {
                  await FirebaseAuth.instance
                      .signOut(); // Logs out from Firebase
                  Navigator.pushReplacementNamed(
                      context, '/'); // Redirect after logout
                } catch (e) {
                  print('Error logging out: $e'); // Error handling
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Converter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'News',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.primary2Color,
        onTap: _onItemTapped, // Handle tap events
      ),
    );
  }
}
