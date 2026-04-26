import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'bundleDetail.dart';

class CommunityCenterPage extends StatefulWidget {
  const CommunityCenterPage({super.key});

  @override
  State<CommunityCenterPage> createState() => _CommunityCenterPageState();
}

class _CommunityCenterPageState extends State<CommunityCenterPage> {
  late Future<List<Map<String, dynamic>>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _fetchRoomsWithBundles();
  }

  Future<List<Map<String, dynamic>>> _fetchRoomsWithBundles() async {
    final client = Supabase.instance.client;

    // Fetch rooms ordered by sort_order
    final rooms = await client
        .from('Rooms')
        .select()
        .order('sort_order', ascending: true);

    // Fetch all bundles
    final bundles = await client
        .from('Bundles')
        .select();

    // Group bundles by room_name
    final List<Map<String, dynamic>> result = [];
    for (final room in rooms) {
      final roomBundles = (bundles as List)
          .where((b) => b['room_name'] == room['name'])
          .toList();
      result.add({
        'name': room['name'],
        'orb_color': room['orb_color'],
        'bundles': roomBundles,
      });
    }
    return result;
  }

  Color _parseColor(String hex) {
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return stardewMediumBrown;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // TITLE
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "Community Center",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (screenWidth * 0.08).clamp(24.0, 48.0),
                fontWeight: FontWeight.bold,
                color: stardewDarkBrown,
                height: 1.2,
              ),
            ),
          ),

          // ROOMS LIST
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _roomsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: stardewDarkBrown),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final rooms = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final orbColor = _parseColor(room['orb_color'] ?? '#EE961E');
                    final bundles = room['bundles'] as List;

                    return _RoomSection(
                      roomName: room['name'],
                      orbColor: orbColor,
                      bundles: bundles,
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

class _RoomSection extends StatelessWidget {
  final String roomName;
  final Color orbColor;
  final List bundles;

  const _RoomSection({
    required this.roomName,
    required this.orbColor,
    required this.bundles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: stardewShadow.withOpacity(0.35),
        border: Border.all(color: stardewDarkBrown, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              roomName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: stardewDarkBrown,
              ),
            ),
          ),
          const Divider(color: stardewDarkBrown, thickness: 2, height: 0),

          // Bundle rows
          ...bundles.map((bundle) => _BundleRow(
            bundle: bundle,
            orbColor: orbColor,
          )),
        ],
      ),
    );
  }
}

class _BundleRow extends StatelessWidget {
  final Map<String, dynamic> bundle;
  final Color orbColor;

  const _BundleRow({required this.bundle, required this.orbColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BundleDetailPage(bundle: bundle),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: stardewDarkBrown, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Orb
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: orbColor,
                border: Border.all(color: stardewDarkBrown, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: orbColor.withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                bundle['name'],
                style: const TextStyle(
                  fontSize: 18,
                  color: stardewDarkBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: stardewDarkBrown),
          ],
        ),
      ),
    );
  }
}
