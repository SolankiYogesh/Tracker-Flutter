import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tracker/models/entity_model.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:fquery/fquery.dart';
import 'package:tracker/network/api_queries.dart';
import 'package:tracker/main.dart' show queryCache;
import 'package:fquery_core/fquery_core.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthServiceProvider>().userId;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              queryCache.invalidateQueries([
                ApiQueries.userExperienceKey,
                userId,
              ]);
              queryCache.invalidateQueries([
                ApiQueries.userCollectionsKey,
                userId,
              ]);
            },
          ),
        ],
      ),
      body: QueryBuilder<UserExperience, Exception>(
        options: QueryOptions(
          queryKey: QueryKey([ApiQueries.userExperienceKey, userId]),
          queryFn: () => ApiQueries.fetchUserExperience(userId),
        ),
        builder: (context, xpQuery) {
          return QueryBuilder<UserCollectionsResponse, Exception>(
            options: QueryOptions(
              queryKey: QueryKey([ApiQueries.userCollectionsKey, userId]),
              queryFn: () => ApiQueries.fetchUserCollections(userId),
            ),
            builder: (context, collectionsQuery) {
              final xp = xpQuery.data;
              final collections = collectionsQuery.data;

              if ((xpQuery.isLoading && xp == null) ||
                  (collectionsQuery.isLoading && collections == null)) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async {
                  queryCache.invalidateQueries([
                    ApiQueries.userExperienceKey,
                    userId,
                  ]);
                  queryCache.invalidateQueries([
                    ApiQueries.userCollectionsKey,
                    userId,
                  ]);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (xp != null)
                      _buildLevelCard(
                        xp.currentLevel,
                        xp.totalXp,
                        xp.entitiesCollected,
                      ),
                    const SizedBox(height: 24),
                    const Text(
                      'Collection History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (collections != null &&
                        collections.collections.isNotEmpty)
                      ...collections.collections.map((collection) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  collection.entityType?.iconUrl != null
                                  ? CachedNetworkImageProvider(
                                      collection.entityType!.iconUrl!,
                                    )
                                  : null,
                              child: collection.entityType?.iconUrl == null
                                  ? const Icon(Icons.stars)
                                  : null,
                            ),
                            title: Text(
                              collection.entityType?.name ?? 'Unknown Item',
                            ),
                            subtitle: Text(
                              'Collected: ${_formatDate(collection.collectedAt)}',
                            ),
                            trailing: Text(
                              '+${collection.xpEarned} XP',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      })
                    else if (collectionsQuery.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
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
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 32,
                ),
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
