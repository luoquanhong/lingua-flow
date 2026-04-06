import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_widget.dart';

class ProfileStats {
  final int totalWords;
  final int masteredWords;
  final int learningWords;
  final int currentStreak;
  final int longestStreak;
  final double totalMinutes;
  final List<DailyActivity> weeklyActivity;

  const ProfileStats({
    required this.totalWords, required this.masteredWords,
    required this.learningWords, required this.currentStreak,
    required this.longestStreak, required this.totalMinutes,
    required this.weeklyActivity,
  });
}

class DailyActivity {
  final String day;
  final int count;
  const DailyActivity(this.day, this.count);
}

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileStats>> {
  ProfileNotifier() : super(const AsyncValue.loading()) { _load(); }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 400));
    state = AsyncValue.data(ProfileStats(
      totalWords: 342,
      masteredWords: 89,
      learningWords: 201,
      currentStreak: 5,
      longestStreak: 21,
      totalMinutes: 1840,
      weeklyActivity: const [
        DailyActivity('Mon', 15),
        DailyActivity('Tue', 8),
        DailyActivity('Wed', 23),
        DailyActivity('Thu', 12),
        DailyActivity('Fri', 19),
        DailyActivity('Sat', 5),
        DailyActivity('Sun', 11),
      ],
    ));
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileStats>>((ref) => ProfileNotifier());

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: statsAsync.when(
        data: (stats) => _ProfileBody(stats: stats),
        loading: () => const LoadingWidget(message: '加载中...'),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final ProfileStats stats;
  const _ProfileBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Profile header
        _ProfileHeader(currentStreak: stats.currentStreak, longestStreak: stats.longestStreak),
        const SizedBox(height: AppSizes.paddingLg),

        // Vocabulary overview
        Text('词汇量概览', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.paddingSm),
        _VocabularyCard(stats: stats),
        const SizedBox(height: AppSizes.paddingLg),

        // Weekly activity chart
        Text('本周学习趋势', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.paddingSm),
        _WeeklyChart(activity: stats.weeklyActivity),
        const SizedBox(height: AppSizes.paddingLg),

        // Learning stats
        Text('学习数据', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.paddingSm),
        _LearningStatsGrid(stats: stats),
        const SizedBox(height: AppSizes.paddingLg),

        // Menu items
        Text('设置', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.paddingSm),
        _MenuSection(),
        const SizedBox(height: 40),
      ]));
  }
}

class _ProfileHeader extends StatelessWidget {
  final int currentStreak, longestStreak;
  const _ProfileHeader({required this.currentStreak, required this.longestStreak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(children: [
        CircleAvatar(radius: 32,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: const Icon(Icons.person, color: Colors.white, size: 36)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('英语学习者', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
            const SizedBox(width: 4),
            Text('$currentStreak 天连续学习  |  最长 $longestStreak 天',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
          ]),
        ])),
        Icon(Icons.qr_code, color: Colors.white.withOpacity(0.7), size: 28),
      ]));
  }
}

class _VocabularyCard extends StatelessWidget {
  final ProfileStats stats;
  const _VocabularyCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final mastery = stats.totalWords > 0 ? stats.masteredWords / stats.totalWords : 0.0;
    return Card(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('总词汇量', style: Theme.of(context).textTheme.titleMedium),
          Text('${stats.totalWords} 词', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: mastery, minHeight: 8,
              backgroundColor: AppColors.divider, valueColor: const AlwaysStoppedAnimation(AppColors.success))),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _MiniStat(label: '已掌握', value: '${stats.masteredWords}', color: AppColors.success),
          _MiniStat(label: '学习中', value: '${stats.learningWords}', color: AppColors.warning),
          _MiniStat(label: '生词', value: '${stats.totalWords - stats.masteredWords - stats.learningWords}', color: AppColors.info),
        ]),
      ])));
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value; final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ]);
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<DailyActivity> activity;
  const _WeeklyChart({required this.activity});

  @override
  Widget build(BuildContext context) {
    final maxVal = activity.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();
    return Card(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: SizedBox(height: 160,
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barGroups: List.generate(activity.length, (i) {
            final item = activity[i];
            return BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(
                toY: item.count.toDouble(),
                color: AppColors.primary,
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              )]);
          }),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, getTitlesWidget: (val, _) =>
              Text(activity[val.toInt()].day, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)))),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        )))));
  }
}

class _LearningStatsGrid extends StatelessWidget {
  final ProfileStats stats;
  const _LearningStatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.paddingSm, mainAxisSpacing: AppSizes.paddingSm, childAspectRatio: 1.6,
      children: [
        _StatTile(icon: Icons.timer_outlined, label: '累计学习', value: '${(stats.totalMinutes / 60).round()}h',
            color: AppColors.primary),
        _StatTile(icon: Icons.local_fire_department_outlined, label: '当前连续', value: '${stats.currentStreak} 天',
            color: Colors.orange),
        _StatTile(icon: Icons.emoji_events_outlined, label: '最长连续', value: '${stats.longestStreak} 天',
            color: AppColors.warning),
        _StatTile(icon: Icons.school_outlined, label: '掌握比例',
            value: '${((stats.masteredWords / (stats.totalWords == 0 ? 1 : stats.totalWords)) * 100).round()}%',
            color: AppColors.success),
      ]);
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _StatTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ]))),
      ]));
  }
}

class _MenuSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(child: Column(children: [
      _MenuItem(icon: Icons.notifications_outlined, label: '学习提醒',
          onTap: () {}, trailing: Switch(value: true, onChanged: (_) {})),
      const Divider(height: 1),
      _MenuItem(icon: Icons.calendar_today_outlined, label: '学习日历', onTap: () {}),
      const Divider(height: 1),
      _MenuItem(icon: Icons.bar_chart_outlined, label: '数据统计', onTap: () {}),
      const Divider(height: 1),
      _MenuItem(icon: Icons.download_outlined, label: '导出数据', onTap: () {}),
      const Divider(height: 1),
      _MenuItem(icon: Icons.settings_outlined, label: '设置', onTap: () {}),
      const Divider(height: 1),
      _MenuItem(icon: Icons.help_outline, label: '帮助与反馈', onTap: () {}),
    ]));
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  final Widget? trailing;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
