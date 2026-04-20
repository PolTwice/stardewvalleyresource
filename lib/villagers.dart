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
  // 1. Create the Future to fetch data from your 'Villagers' table
  late Future<List<Map<String, dynamic>>> _villagersFuture;

  @override
  void initState() {
    super.initState();
    // Querying the database - make sure 'VillagerName' and 'image_url' match your Supabase columns
    _villagersFuture = Supabase.instance.client
        .from('Villagers')
        .select()
        .order('VillagerName', ascending: true);
  }

  Widget _buildVillagerCard({
    required String name,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1, // 1.0 makes it a perfect square
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
          // TITLE SECTION
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Pelican Town Villagers",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth*0.08,
                fontWeight: FontWeight.bold,
                color: stardewDarkBrown,
                height: 1.2,
              ),
            ),
          ),

          // THE GRID
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _villagersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: stardewDarkBrown));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final villagers = snapshot.data ?? [];

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200, // The "Maximum Size" for each card
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75, // Keeps the vertical height proportional
                  ),
                  itemCount: villagers.length,
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