import 'package:flutter/material.dart';

import 'main.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: stardewTanBody,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Welcome Farmer!",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
              )
            ),
            const Text(
              "Welcome to Pelican Pass! We have Two features currently:"
                  "Villagers lets you look at the villager's gift preferences"
                  "Community center gives you a checklist for each bundle in the community center"
            )
          ]
      )
      )
    );
  }

}