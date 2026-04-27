import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'authentication.dart';
import 'homePage.dart';
import 'villagers.dart';
import 'communityCenter.dart';

const Color stardewHighlighted = Color(0xFFA13219);
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

//supabase instance
final supabase = Supabase.instance.client;

//Outline that can be changed as needed
class StardewOutline extends StatefulWidget {
  const StardewOutline({super.key});

  @override
  State<StardewOutline> createState() => _StardewOutlineState();
}

class _StardewOutlineState extends State<StardewOutline> {
  // index starts at 2 which is the homepage
  int _selectedIndex = 2;

  //key to this navigator
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // ensures the stack is empty when we go back to that page
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: stardewTanBody,
      appBar: PreferredSize(
        //make the appbar a bit bigger for the decoration border
        preferredSize: const Size.fromHeight(kToolbarHeight + 4),
        child: Container(
          //border for the app bar
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: stardewShadow, width: 4)),
          ),
          child: AppBar(
            //allows for clicking of the title
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
            //login action
            actions: [
              TextButton.icon(
                onPressed: () async {
                  if (supabase.auth.currentUser != null) {
                    await supabase.auth.signOut(); //logout
                    _onItemTapped(2); //go back to home
                  } else {
                    _onItemTapped(3); // go to login
                  }
                },
                icon: Icon(
                  supabase.auth.currentUser != null ? Icons.logout : Icons.login,
                  color: stardewDarkBrown,
                ),
                label: Text(
                  supabase.auth.currentUser != null ? "Logout" : "Login",
                  style: const TextStyle(color: stardewDarkBrown, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),

      //navigator that holds page
      body: Navigator(
        key: ValueKey(_selectedIndex),  //everytime we navigate, it goes to a new instance
        //check which route to run
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) {
              switch (_selectedIndex) {
                case 0:
                  return const VillagersPage();
                case 1:
                  return const CommunityCenterPage();
                case 2:
                  return HomePage();
                case 3:
                  return const AuthPage();
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

          //trick the nav bar to look like nothing is selected when we are on the home or auth pages
          currentIndex: _selectedIndex > 1 ? 0 : _selectedIndex,
          selectedItemColor: _selectedIndex >1 ? stardewDarkBrown.withAlpha(200) : stardewHighlighted,
          unselectedItemColor: stardewDarkBrown.withAlpha(200),
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,

        ),
      ),
    );
  }
}