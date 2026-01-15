import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/models/entity_model.dart';
import 'package:tracker/providers/entity_provider.dart';
import 'package:tracker/providers/auth_service_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntityProvider>().fetchLeaderboard();
    });
  }

  Future<void> _refresh() async {
    await context.read<EntityProvider>().fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Consumer<EntityProvider>(
        builder: (context, provider, child) {
          final leaderboard = provider.leaderboard;
          final currentUserId = context.watch<AuthServiceProvider>().userId;

          if (leaderboard == null && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (leaderboard == null || leaderboard.leaderboard.isEmpty) {
            return const Center(child: Text("No data available yet."));
          }

          final entries = leaderboard.leaderboard;
          final topThree = entries.take(3).toList();
          final rest = entries.skip(3).toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (topThree.isNotEmpty) _buildTopThree(topThree),
                const SizedBox(height: 20),
                if (rest.isNotEmpty) 
                  const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("Runners Up", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ...rest.map((e) => _buildRankItem(e, currentUserId)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopThree(List<LeaderboardEntry> entries) {
    // Expected order in standard podium: 2nd, 1st, 3rd
    // But list is sorted by rank 1, 2, 3.
    // So 0 is 1st, 1 is 2nd, 2 is 3rd.
    // Display order: Silver (1), Gold (0), Bronze (2)
    
    LeaderboardEntry? first = entries.isNotEmpty ? entries[0] : null;
    LeaderboardEntry? second = entries.length > 1 ? entries[1] : null;
    LeaderboardEntry? third = entries.length > 2 ? entries[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null) Expanded(child: _buildPodiumItem(second, 2, Colors.grey.shade300, 100)),
        if (first != null) Expanded(child: _buildPodiumItem(first, 1, Colors.amber.shade300, 130)),
        if (third != null) Expanded(child: _buildPodiumItem(third, 3, Colors.brown.shade300, 80)),
      ],
    );
  }

  Widget _buildPodiumItem(LeaderboardEntry entry, int place, Color color, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: place == 1 ? 35 : 28,
          backgroundColor: color,
          child: CircleAvatar(
             radius: place == 1 ? 32 : 25,
             backgroundImage: entry.picture != null ? NetworkImage(entry.picture!) : null,
             child: entry.picture == null ? const Icon(Icons.person) : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(entry.name ?? 'User', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold),),
        Text('${entry.totalXp} XP', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
                 "$place", 
                 style: TextStyle(
                     fontSize: 32, 
                     fontWeight: FontWeight.bold, 
                     color: color.withValues(alpha: 1.0) // Stronger color for number
                 )
               ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(LeaderboardEntry entry, String? currentUserId) {
    final isMe = entry.userId == currentUserId;
    return Card(
      elevation: isMe ? 4 : 1,
      color: isMe ? Colors.blue.withValues(alpha: 0.1) : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Text("#${entry.rank}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        title: Text(
            entry.name ?? 'Unknown',
            style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Text("Level ${entry.currentLevel} • ${entry.entitiesCollected} Items"),
        trailing: Text("${entry.totalXp} XP", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
      ),
    );
  }
}
