import 'package:flutter/material.dart';
import 'main.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final user = supabase.auth.currentUser;

    //get username else set to first part of email, else set to farmer
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
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to Pelican Pass! We have two features currently:\n\n"
                            "Villagers\n"
                            " • This lets you look at the villager's gift preferences. \n\n"
                            "Community Center\n"
                            " • This gives you a checklist for each bundle. Make sure to make an account to save your checklists! \n",
                        style: TextStyle(
                          color: stardewDarkBrown,
                          fontSize: (screenWidth * .04).clamp(12, 18),
                        ),
                      ),
                    ], // End of Column children
                  ), // End of Column
                ),
                const SizedBox(width: 16),  //spacer
                Expanded(
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