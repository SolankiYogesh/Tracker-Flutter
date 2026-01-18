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

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthServiceProvider>().userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                queryCache.invalidateQueries([ApiQueries.leaderboardKey]),
          ),
        ],
      ),
      body: QueryBuilder<LeaderboardResponse, Exception>(
        options: QueryOptions(
          queryKey: QueryKey([ApiQueries.leaderboardKey]),
          queryFn: ApiQueries.fetchLeaderboard,
        ),
        builder: (context, query) {
          if (query.isLoading && query.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (query.isError) {
            return Center(child: Text('Error: ${query.error}'));
          }

          final leaderboard = query.data;

          if (leaderboard == null || leaderboard.leaderboard.isEmpty) {
            return const Center(child: Text('No data available yet.'));
          }

          final entries = leaderboard.leaderboard;
          final topThree = entries.take(3).toList();
          final rest = entries.skip(3).toList();

          return RefreshIndicator(
            onRefresh: () async {
              queryCache.invalidateQueries([ApiQueries.leaderboardKey]);
            },
            child: ListView(
              padding: EdgeInsets.all(context.w(16)),
              children: [
                if (topThree.isNotEmpty) _buildTopThree(context, topThree),
                SizedBox(height: context.h(20)),
                if (rest.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: context.h(10)),
                    child: Text(
                      'Runners Up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: context.sp(18),
                      ),
                    ),
                  ),
                ...rest.map((e) => _buildRankItem(context, e, currentUserId)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopThree(BuildContext context, List<LeaderboardEntry> entries) {
    LeaderboardEntry? first = entries.isNotEmpty ? entries[0] : null;
    LeaderboardEntry? second = entries.length > 1 ? entries[1] : null;
    LeaderboardEntry? third = entries.length > 2 ? entries[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          Expanded(
            child: _buildPodiumItem(
              context,
              second,
              2,
              Colors.grey.shade300,
              context.h(100),
            ),
          ),
        if (first != null)
          Expanded(
            child: _buildPodiumItem(
              context,
              first,
              1,
              Colors.amber.shade300,
              context.h(130),
            ),
          ),
        if (third != null)
          Expanded(
            child: _buildPodiumItem(
              context,
              third,
              3,
              Colors.brown.shade300,
              context.h(80),
            ),
          ),
      ],
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    LeaderboardEntry entry,
    int place,
    Color color,
    double height,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: context.w(place == 1 ? 35 : 28),
          backgroundColor: color,
          child: CircleAvatar(
            radius: context.w(place == 1 ? 32 : 25),
            backgroundImage: entry.picture != null
                ? CachedNetworkImageProvider(entry.picture!)
                : null,
            child: entry.picture == null ? const Icon(Icons.person) : null,
          ),
        ),
        SizedBox(height: context.h(8)),
        Text(
          entry.name ?? 'User',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: context.sp(14),
          ),
        ),
        Text(
          '${entry.totalXp} XP',
          style: TextStyle(fontSize: context.sp(12), color: Colors.grey),
        ),
        SizedBox(height: context.h(8)),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.w(8)),
            ),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$place',
                style: TextStyle(
                  fontSize: context.sp(32),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(
    BuildContext context,
    LeaderboardEntry entry,
    String? currentUserId,
  ) {
    final isMe = entry.userId == currentUserId;
    return Card(
      elevation: isMe ? 4 : 1,
      color: isMe ? Colors.blue.withValues(alpha: 0.1) : null,
      margin: EdgeInsets.only(bottom: context.h(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(
            '#${entry.rank}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: context.sp(16),
            ),
          ),
        ),
        title: Text(
          entry.name ?? 'Unknown',
          style: TextStyle(
            fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
            fontSize: context.sp(16),
          ),
        ),
        subtitle: Text(
          'Level ${entry.currentLevel} • ${entry.entitiesCollected} Items',
          style: TextStyle(fontSize: context.sp(14)),
        ),
        trailing: Text(
          '${entry.totalXp} XP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: context.sp(14),
          ),
        ),
      ),
    );
  }
}
