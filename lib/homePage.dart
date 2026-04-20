import 'package:flutter/material.dart';

import 'main.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: stardewTanBody,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome Farmer!",
              style: TextStyle(
                fontSize: screenWidth * .1,
                fontWeight: FontWeight.bold
              )
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Aligns text and gif to the top
              children: [
                // 1. WRAP YOUR TEXT IN EXPANDED
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to Pelican Pass! We have Two features currently:\n"
                        " \"Villagers\" lets you look at the villager's gift preferences\n"
                        " \"Community\" center gives you a checklist for each bundle in the community center\n",
                        style: TextStyle(
                          fontSize: screenWidth * .03
                      )
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16), // A little breathing room

                // 2. THE GIF (With a set size)
                SizedBox(
                  width: 100, // Explicit size keeps the GIF from taking over
                  height: 100,
                  child: Image.network(
                    'https://media1.tenor.com/m/dsAkCR4X4V0AAAAC/junimo-stardew.gif', // Direct GIF link
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            )

          ]
      )
      )
    );
  }

}