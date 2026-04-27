import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'villagerDetails.dart';
import 'main.dart';

class VillagersPage extends StatefulWidget {
  const VillagersPage({super.key});

  @override
  State<VillagersPage> createState() => _VillagersPageState();
}

class _VillagersPageState extends State<VillagersPage> {
  // future for getting data from the vilager table
  late Future<List<Map<String, dynamic>>> _villagersFuture;

  @override
  void initState() {
    super.initState();
    //get villager list
    _villagersFuture = Supabase.instance.client
        .from('Villagers')
        .select()
        .order('VillagerName', ascending: true);
  }

  //function for building villager icons
  Widget _buildVillagerCard({
    required String name,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          //picture
          AspectRatio(
            aspectRatio: 1, // square
            child: Container(
              decoration: BoxDecoration(
                color: stardewBorderLight,
                border: Border.all(color: stardewDarkBrown, width: 3),
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: stardewDarkBrown, width: 2),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.person, color: stardewDarkBrown),
                ),
              ),
            ),
          ),

          //text
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              name,
              style: TextStyle(
                color: stardewDarkBrown,
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background is handled by StardewOutline
      body: Column(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Pelican Town Villagers",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (screenWidth * .08).clamp(24, 60),
                fontWeight: FontWeight.bold,
                color: stardewDarkBrown,
                height: 1.2,
              ),
            ),
          ),

          // grid of villagers
          Expanded(
            //for getting info from databse
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _villagersFuture,
              builder: (context, snapshot) {
                //if we are still waiting for connection
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: stardewDarkBrown));
                }
                //if there is an eror when connecting
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                //we get the datam or we get an empty array if null
                final villagers = snapshot.data ?? [];

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  //we have a smart grid
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200, // max size for each card
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75, // Keeps the vertical height proportional
                  ),
                  itemCount: villagers.length,

                  //build villager entries
                  itemBuilder: (context, index) {
                    final villager = villagers[index];
                    return _buildVillagerCard(
                      name: villager['VillagerName'] ?? 'Unknown',
                      imageUrl: villager['imageURL'] ?? '',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VillagerDetailPage(villager: villager),
                          ),
                        );
                      }
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}