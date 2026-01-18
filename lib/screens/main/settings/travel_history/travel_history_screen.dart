import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/models/travel_activity.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/theme/app_colors.dart';
import 'package:tracker/utils/responsive_utils.dart';
import 'package:intl/intl.dart';

enum TravelFilter { day, week, month }

class TravelHistoryScreen extends StatefulWidget {
  const TravelHistoryScreen({super.key});

  @override
  State<TravelHistoryScreen> createState() => _TravelHistoryScreenState();
}

class _TravelHistoryScreenState extends State<TravelHistoryScreen> {
  TravelFilter _selectedFilter = TravelFilter.day;
  List<TravelActivity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthServiceProvider>().appUser;
    if (user == null) return;

    DateTime from;
    final now = DateTime.now();
    switch (_selectedFilter) {
      case TravelFilter.day:
        from = DateTime(now.year, now.month, now.day);
        break;
      case TravelFilter.week:
        from = now.subtract(const Duration(days: 7));
        break;
      case TravelFilter.month:
        from = now.subtract(const Duration(days: 30));
        break;
    }

    final data = await DatabaseHelper().getTravelActivities(
      userId: user.id,
      from: from,
    );

    setState(() {
      _activities = data.map((e) => TravelActivity.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Insights'),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildFilterToggle(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _activities.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(context.w(16)),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildSummarySection(),
                        SizedBox(height: context.h(24)),
                        _buildHistoryList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: context.h(16),
        horizontal: context.w(16),
      ),
      padding: EdgeInsets.all(context.w(4)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(context.w(12)),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: TravelFilter.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter);
                _loadData();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.h(10)),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(context.w(8)),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    filter.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummarySection() {
    double walkingDist = 0;
    double vehicleDist = 0;
    double stillTime = 0; // minutes

    for (var a in _activities) {
      if (a.type == 'walking')
        walkingDist += a.distance;
      else if (a.type == 'vehicle')
        vehicleDist += a.distance;
      else
        stillTime += a.durationMinutes;
    }

    return Column(
      children: [
        Row(
          children: [
            _buildSummaryCard(
              'Walking',
              '${(walkingDist / 1000).toStringAsFixed(2)} km',
              Icons.directions_walk,
              Colors.orange,
            ),
            SizedBox(width: context.w(12)),
            _buildSummaryCard(
              'Vehicle',
              '${(vehicleDist / 1000).toStringAsFixed(2)} km',
              Icons.directions_car,
              AppColors.primary,
            ),
          ],
        ),
        SizedBox(height: context.h(12)),
        Row(
          children: [
            _buildSummaryCard(
              'Rest',
              '${(stillTime / 60).toStringAsFixed(1)} hrs',
              Icons.king_bed,
              AppColors.secondary,
            ),
            SizedBox(width: context.w(12)),
            _buildSummaryCard(
              'Total Sessions',
              '${_activities.length}',
              Icons.history,
              Colors.blueGrey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(context.w(16)),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(context.w(16)),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: context.w(24)),
            SizedBox(height: context.h(12)),
            Text(
              value,
              style: TextStyle(
                fontSize: context.sp(18),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: context.sp(12),
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.h(16)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _activities.length,
          separatorBuilder: (_, __) => SizedBox(height: context.h(12)),
          itemBuilder: (context, index) {
            final activity = _activities[index];
            return _buildActivityItem(activity);
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(TravelActivity activity) {
    IconData icon;
    Color color;
    switch (activity.type) {
      case 'walking':
        icon = Icons.directions_walk;
        color = Colors.orange;
        break;
      case 'vehicle':
        icon = Icons.directions_car;
        color = AppColors.primary;
        break;
      default:
        icon = Icons.king_bed;
        color = AppColors.secondary;
    }

    return Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(context.w(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(10)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: context.w(20)),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.type.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: context.sp(14),
                  ),
                ),
                Text(
                  '${DateFormat('HH:mm').format(activity.startTime)} - ${DateFormat('HH:mm').format(activity.endTime)}',
                  style: TextStyle(
                    fontSize: context.sp(12),
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${activity.durationMinutes.toStringAsFixed(0)} min',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(14),
                ),
              ),
              if (activity.distance > 0)
                Text(
                  '${(activity.distance / 1000).toStringAsFixed(2)} km',
                  style: TextStyle(
                    fontSize: context.sp(12),
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.explore_outlined,
            size: context.w(64),
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.3),
          ),
          SizedBox(height: context.h(16)),
          Text(
            'No travel activity recorded yet',
            style: TextStyle(
              fontSize: context.sp(16),
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: context.h(8)),
          Text(
            'Keep moving to see your insights!',
            style: TextStyle(
              fontSize: context.sp(12),
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
