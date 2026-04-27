import 'package:flutter/material.dart';
import 'main.dart';

class VillagerDetailPage extends StatefulWidget {
  final Map<String, dynamic> villager; // Pass the villager data from the grid

  const VillagerDetailPage({super.key, required this.villager});

  @override
  State<VillagerDetailPage> createState() => _VillagerDetailPageState();
}

class _VillagerDetailPageState extends State<VillagerDetailPage> {
  // all preferences in one map. late means "trust me I'll get this stuff".
  //This is a map of strings (preferences) to a lists of items (item name and image url)
  late Future<Map<String, List<Map<String, dynamic>>>> _allPreferences;

  @override
  void initState() {
    super.initState();
    _allPreferences = _fetchAllPreferences();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchAllPreferences() async {
    final name = widget.villager['VillagerName'];

    // Fetch from all tables at the same time. wait lets us do it all at the same time
    final results = await Future.wait([
      supabase.from('VillagerLoves').select('Item, Items(imageURL)').eq('Villager', name),
      supabase.from('VillagerLikes').select('Item, Items(imageURL)').eq('Villager', name),
      supabase.from('VillagerNeutral').select('Item, Items(imageURL)').eq('Villager', name),
      supabase.from('VillagerDislikes').select('Item, Items(imageURL)').eq('Villager', name),
      supabase.from('VillagerHates').select('Item, Items(imageURL)').eq('Villager', name),
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
    return Scaffold(
      backgroundColor: stardewTanBody,
      appBar: AppBar(
        title: Text(widget.villager['VillagerName']),
        backgroundColor: stardewShadow,
        foregroundColor: stardewDarkBrown,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _allPreferences,
        builder: (context, snapshot) {
          //if we are still waiting for connection
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: stardewDarkBrown));
          }

          //if there is an eror when connecting
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // check for data
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No preferences found."));
          }

          //if we got here, then we know for sure the data is here
          final prefs = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Villager Portrait
              Row(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: stardewDarkBrown, width: 4),
                      color: stardewShadow
                    ),
                    child: Image.network(widget.villager['imageURL'], fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //villager name
                        Text(
                          widget.villager['VillagerName'].toString(),
                          style: TextStyle(
                              color: stardewDarkBrown,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        //villager description
                        Text(
                          widget.villager['Description'] ?? "This person is a cool guy.",
                          style: TextStyle(
                            color: stardewDarkBrown,
                            fontSize: 16,
                          ),
                          softWrap: true, // add text wrap
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // PREFERENCE SECTIONS
              _buildPreferenceSection("Loves", prefs['Loves']!, Color(0xFFCD1313)),
              _buildPreferenceSection("Likes", prefs['Likes']!, Color(0xFFFF8800)),
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
    //if not items, shrink to nothing
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: labelColor)),
        const Divider(color: stardewDarkBrown, thickness: 2),
        GridView.builder(
          shrinkWrap: true, // so that it shows properly in list view
          physics: const NeverScrollableScrollPhysics(), // never make this scrollable
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 70,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            // get the item from the preference table and then get the url joined from the item table
            final String itemImg = item['Items']['imageURL'] ?? '';

            //display name when hovering over the itme
            return Tooltip(
              message: item['Item'], // Shows name
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: stardewDarkBrown),
                  color: stardewShadow,
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