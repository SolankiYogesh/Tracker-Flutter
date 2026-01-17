import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tracker/models/entity_model.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:fquery/fquery.dart';
import 'package:tracker/network/api_queries.dart';
import 'package:tracker/main.dart' show queryCache;
import 'package:fquery_core/fquery_core.dart';
import 'package:tracker/utils/responsive_utils.dart';

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
                  padding: EdgeInsets.all(context.w(16)),
                  children: [
                    if (xp != null)
                      _buildLevelCard(
                        context,
                        xp.currentLevel,
                        xp.totalXp,
                        xp.entitiesCollected,
                      ),
                    SizedBox(height: context.h(24)),
                    Text(
                      'Collection History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: context.sp(18),
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    if (collections != null &&
                        collections.collections.isNotEmpty)
                      ...collections.collections.map((collection) {
                        return Card(
                          margin: EdgeInsets.only(bottom: context.h(12)),
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

  Widget _buildLevelCard(
    BuildContext context,
    int level,
    int totalXp,
    int count,
  ) {
    return Container(
      padding: EdgeInsets.all(context.w(24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.w(20)),
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: context.w(10),
            offset: Offset(0, context.h(5)),
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
                  Text(
                    'Level',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$level',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(44),
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(context.w(12)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: context.w(32),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalXp Total XP',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count Items',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: context.sp(15),
                  fontWeight: FontWeight.w500,
                ),
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
