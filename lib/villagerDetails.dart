import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VillagerDetailPage extends StatefulWidget {
  final Map<String, dynamic> villager; // Pass the villager data from the grid

  const VillagerDetailPage({super.key, required this.villager});

  @override
  State<VillagerDetailPage> createState() => _VillagerDetailPageState();
}

class _VillagerDetailPageState extends State<VillagerDetailPage> {
  // We'll store all preferences in a single Map
  late Future<Map<String, List<Map<String, dynamic>>>> _allPreferences;

  @override
  void initState() {
    super.initState();
    _allPreferences = _fetchAllPreferences();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchAllPreferences() async {
    final name = widget.villager['VillagerName'];
    final client = Supabase.instance.client;

    // Fetch from all tables simultaneously (Systems efficiency!)
    final results = await Future.wait([
      client.from('VillagerLoves').select('Item, Items(imageURL)').eq('Villager', name),
      client.from('VillagerLikes').select('Item, Items(imageURL)').eq('Villager', name),
      client.from('VillagerNeutral').select('Item, Items(imageURL)').eq('Villager', name),
      client.from('VillagerDislikes').select('Item, Items(imageURL)').eq('Villager', name),
      client.from('VillagerHates').select('Item, Items(imageURL)').eq('Villager', name),
    ]);

    return {
      'Loves': List<Map<String, dynamic>>.from(results[0]),
      'Likes': List<Map<String, dynamic>>.from(results[1]),
      'Neutral': List<Map<String, dynamic>>.from(results[2]),
      'Dislikes': List<Map<String, dynamic>>.from(results[3]),
      'Hates': List<Map<String, dynamic>>.from(results[4]),
    };
  }

  @override
  Widget build(BuildContext context) {
    const Color stardewDarkBrown = Color(0xFF52180E);

    return Scaffold(
      backgroundColor: const Color(0xFFF8D387), // stardewTanBody
      appBar: AppBar(
        title: Text(widget.villager['VillagerName']),
        backgroundColor: const Color(0xFFEE961E),
        foregroundColor: stardewDarkBrown,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _allPreferences,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final prefs = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // BIG PORTRAIT SECTION
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: stardewDarkBrown, width: 4),
                  ),
                  child: Image.network(widget.villager['imageURL'], fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),

              // PREFERENCE SECTIONS
              _buildPreferenceSection("Loves", prefs['Loves']!, Colors.redAccent),
              _buildPreferenceSection("Likes", prefs['Likes']!, Colors.orangeAccent),
              _buildPreferenceSection("Neutral", prefs['Neutral']!, Colors.grey),
              _buildPreferenceSection("Dislikes", prefs['Dislikes']!, Colors.blueGrey),
              _buildPreferenceSection("Hates", prefs['Hates']!, Colors.black54),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreferenceSection(String title, List<Map<String, dynamic>> items, Color labelColor) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: labelColor)),
        const Divider(color: Color(0xFF52180E), thickness: 2),
        GridView.builder(
          shrinkWrap: true, // Crucial: allows Grid inside ListView
          physics: const NeverScrollableScrollPhysics(), // ListView handles scrolling
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 70,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            // Accessing the joined 'Items' table data
            final String itemImg = item['Items']['imageURL'] ?? '';

            return Tooltip(
              message: item['Item'], // Shows name on long-press
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF52180E)),
                  color: const Color(0xFFE1A363),
                ),
                child: Image.network(itemImg),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}