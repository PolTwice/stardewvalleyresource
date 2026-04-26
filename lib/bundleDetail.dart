import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class BundleDetailPage extends StatefulWidget {
  final Map<String, dynamic> bundle;

  const BundleDetailPage({super.key, required this.bundle});

  @override
  State<BundleDetailPage> createState() => _BundleDetailPageState();
}

class _BundleDetailPageState extends State<BundleDetailPage> {
  late Future<_BundleData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchBundleData();
  }

  Future<_BundleData> _fetchBundleData() async {
    final client = Supabase.instance.client;
    final bundleName = widget.bundle['name'];
    final user = client.auth.currentUser;

    // Fetch all items for this bundle (joined with Items for imageURL)
    final items = await client
        .from('BundleItems')
        .select('id, item_name, quantity, is_reward, Items(imageURL)')
        .eq('bundle_name', bundleName);

    // Fetch user completion state (only if logged in)
    Map<int, bool> completionMap = {};
    if (user != null && items.isNotEmpty) {
      final itemIds = (items as List).map((i) => i['id']).toList();
      final completions = await client
          .from('UserBundleItems')
          .select('bundle_item_id, is_complete')
          .eq('user_id', user.id)
          .inFilter('bundle_item_id', itemIds);

      for (final c in completions) {
        completionMap[c['bundle_item_id']] = c['is_complete'] ?? false;
      }
    }

    final List<_BundleItem> requirements = [];
    final List<_BundleItem> rewards = [];

    for (final item in items) {
      final bundleItem = _BundleItem(
        id: item['id'],
        itemName: item['item_name'],
        quantity: item['quantity'] ?? 1,
        imageUrl: item['Items']?['imageURL'] ?? '',
        isReward: item['is_reward'] ?? false,
        isComplete: completionMap[item['id']] ?? false,
      );
      if (bundleItem.isReward) {
        rewards.add(bundleItem);
      } else {
        requirements.add(bundleItem);
      }
    }

    return _BundleData(requirements: requirements, rewards: rewards);
  }

  Future<void> _toggleItem(_BundleItem item, bool newValue) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to save your progress!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Optimistic UI update
    setState(() {
      item.isComplete = newValue;
    });

    try {
      await client.from('UserBundleItems').upsert(
        {
          'user_id': user.id,
          'bundle_item_id': item.id,
          'is_complete': newValue,
        },
        onConflict: 'user_id,bundle_item_id',
      );
    } catch (e) {
      // Revert on failure
      if (mounted) {
        setState(() => item.isComplete = !newValue);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: stardewTanBody,
      appBar: AppBar(
        title: Text(widget.bundle['name']),
        backgroundColor: stardewShadow,
        foregroundColor: stardewDarkBrown,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: stardewDarkBrown, width: 4)),
      ),
      body: FutureBuilder<_BundleData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: stardewDarkBrown),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red)),
            );
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // REQUIREMENTS SECTION
              if (data.requirements.isNotEmpty) ...[
                _buildSectionContainer(
                  title: widget.bundle['name'],
                  items: data.requirements,
                  onToggle: _toggleItem,
                ),
                const SizedBox(height: 16),
              ],

              // REWARD SECTION
              if (data.rewards.isNotEmpty)
                _buildSectionContainer(
                  title: "Reward",
                  items: data.rewards,
                  onToggle: _toggleItem,
                  isReward: true,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<_BundleItem> items,
    required Future<void> Function(_BundleItem, bool) onToggle,
    bool isReward = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: stardewShadow.withOpacity(0.35),
        border: Border.all(color: stardewDarkBrown, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: stardewDarkBrown,
              ),
            ),
          ),
          const Divider(color: stardewDarkBrown, thickness: 2, height: 0),

          // Items
          ...items.map((item) => _BundleItemRow(
            item: item,
            onToggle: onToggle,
          )),
        ],
      ),
    );
  }
}

class _BundleItemRow extends StatefulWidget {
  final _BundleItem item;
  final Future<void> Function(_BundleItem, bool) onToggle;

  const _BundleItemRow({required this.item, required this.onToggle});

  @override
  State<_BundleItemRow> createState() => _BundleItemRowState();
}

class _BundleItemRowState extends State<_BundleItemRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: stardewDarkBrown, width: 1)),
      ),
      child: Row(
        children: [
          // Item image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: stardewBorderLight,
              border: Border.all(color: stardewDarkBrown, width: 2),
            ),
            child: widget.item.imageUrl.isNotEmpty
                ? Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, color: stardewDarkBrown),
                  )
                : const Icon(Icons.image_not_supported, color: stardewDarkBrown),
          ),
          const SizedBox(width: 12),

          // Item name + quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: stardewDarkBrown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "x${widget.item.quantity}",
                  style: TextStyle(
                    fontSize: 13,
                    color: stardewDarkBrown.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Checkbox
          GestureDetector(
            onTap: () {
              widget.onToggle(widget.item, !widget.item.isComplete);
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: stardewTanBody,
                border: Border.all(color: stardewDarkBrown, width: 2),
              ),
              child: widget.item.isComplete
                  ? const Icon(Icons.close, color: stardewDarkBrown, size: 20)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Data classes
class _BundleData {
  final List<_BundleItem> requirements;
  final List<_BundleItem> rewards;

  _BundleData({required this.requirements, required this.rewards});
}

class _BundleItem {
  final int id;
  final String itemName;
  final int quantity;
  final String imageUrl;
  final bool isReward;
  bool isComplete;

  _BundleItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.imageUrl,
    required this.isReward,
    required this.isComplete,
  });
}
