import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/providers/entity_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    final userId = context.read<AuthServiceProvider>().userId;
    if (userId != null) {
      context.read<EntityProvider>().fetchUserExperience(userId);
      context.read<EntityProvider>().fetchUserCollections(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Consumer<EntityProvider>(
        builder: (context, provider, child) {
          final xp = provider.userExperience;
          final collections = provider.userCollections;

          if (xp == null && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (xp != null) _buildLevelCard(xp.currentLevel, xp.totalXp, xp.entitiesCollected),
                const SizedBox(height: 24),
                const Text(
                  'Collection History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (collections != null && collections.collections.isNotEmpty)
                  ...collections.collections.map((collection) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: collection.entityType?.iconUrl != null
                              ? NetworkImage(collection.entityType!.iconUrl!)
                              : null,
                          child: collection.entityType?.iconUrl == null
                              ? const Icon(Icons.stars)
                              : null,
                        ),
                        title: Text(collection.entityType?.name ?? 'Unknown Item'),
                        subtitle: Text('Collected: ${_formatDate(collection.collectedAt)}'),
                        trailing: Text(
                          '+${collection.xpEarned} XP',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  })
                else if (provider.isLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ))
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No collections yet. Go explore!'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(int level, int totalXp, int count) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Level',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    '$level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalXp Total XP',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                '$count Items',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
