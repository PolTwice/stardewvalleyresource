import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'authentication.dart';
import 'homePage.dart';
import 'villagers.dart';
import 'communityCenter.dart';

const Color stardewDarkBrown = Color(0xFF52180E);
const Color stardewMediumBrown = Color(0xFFEE961E);
const Color stardewTanBody = Color(0xFFF8D387);
const Color stardewShadow = Color(0xFFE1A363);
const Color stardewBorderLight = Color(0xFFE1A363);


Future<void> main() async {
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
          appBarTheme: const AppBarTheme(surfaceTintColor: Colors.transparent),
        ),
        // Define named routes here
        initialRoute: '/',
        routes: {
          '/': (context) => const StardewOutline(),
        },
      )
  );
}

final supabase = Supabase.instance.client;

class StardewOutline extends StatefulWidget {
  const StardewOutline({super.key});

  @override
  State<StardewOutline> createState() => _StardewOutlineState();
}

class _StardewOutlineState extends State<StardewOutline> {
  // Set the initial index to 2 (Our "Hidden" Home index)
  int _selectedIndex = 2;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Resets the inner stack whenever a tab is clicked
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: stardewTanBody,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 4),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: stardewShadow, width: 4)),
          ),
          child: AppBar(
            title: GestureDetector(
              onTap: () => _onItemTapped(2), // Home
              child: const Text(
                  "Pelican Pass",
                  style: TextStyle(fontWeight: FontWeight.bold, color: stardewDarkBrown)
              ),
            ),
            backgroundColor: stardewMediumBrown,
            elevation: 0,
            shape: const Border(bottom: BorderSide(color: stardewDarkBrown, width: 4)),
            // Inside your StardewOutline build method
            actions: [
              IconButton(
                onPressed: () async {
                  if (Supabase.instance.client.auth.currentUser != null) {
                    // Log out if already logged in
                    await Supabase.instance.client.auth.signOut();
                    _onItemTapped(2); // Go back to Home
                  } else {
                    _onItemTapped(3); // Go to Auth Page
                  }
                },
                icon: Icon(
                  // Change icon based on auth state
                  Supabase.instance.client.auth.currentUser != null
                      ? Icons.logout
                      : Icons.login_outlined,
                  color: stardewDarkBrown,
                ),
              )
            ],
          ),
        ),
      ),

      body: Navigator(
        key: ValueKey(_selectedIndex),
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) {
              // 2. Updated Switch Logic to include AuthPage
              switch (_selectedIndex) {
                case 0:
                  return const VillagersPage();
                case 1:
                  return const CommunityCenterPage();
                case 2:
                  return HomePage();
                case 3:
                  return const AuthPage(); // Your login/register widget
                default:
                  return HomePage();
              }
            },
          );
        },
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: stardewMediumBrown,
          border: Border(top: BorderSide(color: stardewDarkBrown, width: 4.0)),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Villagers'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_sharp), label: 'Centre'),
          ],
          // 3. Prevent the bar from highlighting an item if on Home (2) or Auth (3)
          currentIndex: _selectedIndex > 1 ? 0 : _selectedIndex,
          selectedItemColor: _selectedIndex > 1 ? stardewDarkBrown.withAlpha(200) : stardewDarkBrown,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          unselectedItemColor: stardewDarkBrown.withAlpha(200),
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}