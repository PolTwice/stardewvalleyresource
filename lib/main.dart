import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homePage.dart';
import 'package:stardewvalleyresource/supabasetest.dart';

const Color stardewDarkBrown = Color(0xFF52180E); // Icons and labels
const Color stardewMediumBrown = Color(0xFFEE961E); // AppBar and NavBar background
const Color stardewTanBody = Color(0xFFF8D387); // Main content background
const Color stardewShadow = Color(0xFFE1A363);

Future<void> main() async {
  // Ensure Flutter is ready before calling Supabase
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://phtgafsgcuvdhamorlkd.supabase.co',
    anonKey: 'sb_publishable__40jXzUzI1R-TFv3dYqRuA_7sAyGsw1',
  );

  runApp(
      MaterialApp(
          title: 'Pelican Pass',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'StardewFont',
            useMaterial3: true,
          ),
          home: const StardewOutline()
      )
  );
}

// Quick access to the Supabase client
final supabase = Supabase.instance.client;

//
class StardewOutline extends StatefulWidget {
  const StardewOutline({super.key});

  @override
  State<StardewOutline> createState() => _StardewOutlineState();
}

class _StardewOutlineState extends State<StardewOutline> {
  // Track the currently selected tab
  int _selectedIndex = 0;

  // List of unique pages for each tab (we will build these later)
  static List<Widget> _pages = <Widget>[
    HomePage(),
    Center(child: Text('Villagers Data will load here', style: TextStyle(color: Color(0xFF52180E)))),
    Center(child: Text('Community Centre Data will load here', style: TextStyle(color: Color(0xFF52180E)))),
  ];

  // Function to handle tab taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Defines the precise colors from your format image


    return Scaffold(
      backgroundColor: stardewTanBody, // Matches the large tan area

      // 1. TOP APP BAR (The thin brown header)
      appBar: AppBar(
        title: Text("Pelican Pass"),
        backgroundColor: stardewMediumBrown,
        shadowColor: stardewShadow,
        elevation: 4,
        shape:
            const Border(
              bottom: BorderSide(
                color: stardewDarkBrown,
                width: 4
              )
            ),

        // The burger menu icon
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: stardewDarkBrown,
          onPressed: () {
            // Add drawer functionality here later if needed
          },
        ),
      ),

      // 2. MAIN BODY (Shows the selected page content)
      body: _pages[_selectedIndex],

      // 3. BOTTOM NAVIGATION BAR (The brown footer)
      bottomNavigationBar: Container(
        // The container provides the background color and the top border line
        decoration: const BoxDecoration(
          color: stardewMediumBrown,
          border: Border(
            top: BorderSide(color: stardewDarkBrown, width: 2.0), // The dark line separator
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            // Villagers Tab (using person icon)
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Villagers',
            ),
            // Community Centre Tab (using house icon)
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Community Centre',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          // Customizing the colors and style to match the format
          backgroundColor: Colors.transparent, // Uses the Container's color
          elevation: 0,
          selectedItemColor: stardewDarkBrown, // Color when active
          unselectedItemColor: stardewDarkBrown.withOpacity(0.8), // Slightly faded when inactive
          showUnselectedLabels: true,
          // Pixel-style text formatting
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        ),
      ),
    );
  }
}