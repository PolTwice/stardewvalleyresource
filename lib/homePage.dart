import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final user = Supabase.instance.client.auth.currentUser;

    final String displayName = user?.userMetadata?['username'] ??
        user?.email?.split('@')[0] ??
        "Farmer";

    return Scaffold(
      backgroundColor: stardewTanBody,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome, $displayName!",
              style: TextStyle(
                color: stardewDarkBrown,
                fontSize: (screenWidth * .08).clamp(24, 60),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to Pelican Pass! We have two features currently:\n\n"
                            "• \"Villagers\" lets you look at the villager's gift preferences\n"
                            "• \"Community Center\" gives you a checklist for each bundle\n",
                        style: TextStyle(
                          color: stardewDarkBrown,
                          fontSize: (screenWidth * .04).clamp(12, 18),
                        ),
                      ),
                    ], // End of Column children
                  ), // End of Column
                ), // End of Expanded
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    'https://media1.tenor.com/m/dsAkCR4X4V0AAAAC/junimo-stardew.gif',
                    fit: BoxFit.contain,
                  ),
                ),
              ], // End of Row children
            ), // End of Row
          ], // End of Column children
        ), // End of Column
      ), // End of SingleChildScrollView
    );
  }
}