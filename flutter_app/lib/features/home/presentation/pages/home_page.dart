import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

/// Daily learning summary data
class DailySummary {
  final int wordsLearnedToday;
  final int wordsToReview;
  final int scenesCompleted;
  final int currentStreak;
  final double todayProgress;
  final String greeting;

  const DailySummary({
    required this.wordsLearnedToday,
    required this.wordsToReview,
    required this.scenesCompleted,
    required this.currentStreak,
    required this.todayProgress,
    required this.greeting,
  });
}

class HomeNotifier extends StateNotifier<AsyncValue<DailySummary>> {
  HomeNotifier() : super(const AsyncValue.loading()) { _loadSummary(); }

  Future<void> _loadSummary() async {
    await Future.delayed(const Duration(milliseconds: 600));
    state = AsyncValue.data(DailySummary(
      wordsLearnedToday: 7,
      wordsToReview: 23,
      scenesCompleted: 1,
      currentStreak: 5,
      todayProgress: 0.7,
      greeting: _buildGreeting(),
    ));
  }

  String _buildGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早安 ☀️';
    if (hour < 18) return '下午好 🌤️';
    return '晚上好 🌙';
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadSummary();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, AsyncValue<DailySummary>>((ref) => HomeNotifier());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('LinguaFlow'),
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {})],
      ),
      body: summaryAsync.when(
        data: (s) => _HomeBody(summary: s),
        loading: () => const LoadingWidget(message: '加载中...'),
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline, title: '加载失败', subtitle: e.toString(),
          actionLabel: '重试', onAction: () => ref.read(homeProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final DailySummary summary;
  const _HomeBody({required this.summary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _GreetingCard(summary: summary),
        const SizedBox(height: AppSizes.paddingMd),
        Text('今日进度', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.paddingSm),
        _TodayProgressCard(progress: summary.todayProgress),
        const SizedBox(height: AppSizes.paddingLg),
        Text('快速开始', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.paddingSm),
        _QuickActionGrid(wordsToReview: summary.wordsToReview),
        const SizedBox(height: AppSizes.paddingLg),
        Text('学习数据', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.paddingSm),
        _StatsRow(summary: summary),
        const SizedBox(height: 80),
      ]),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final DailySummary summary;
  const _GreetingCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(summary.greeting, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text('今日目标：学习 ${LearningDefaults.dailyWordGoal} 个单词',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85))),
        const SizedBox(height: 12),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 16),
              const SizedBox(width: 2),
              Text('${summary.currentStreak}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ])),
          const SizedBox(width: 8),
          Text('${summary.currentStreak} 天连续学习', style: const TextStyle(color: Colors.white, fontSize: 13)),
        ]),
      ]),
    );
  }
}

class _TodayProgressCard extends StatelessWidget {
  final double progress;
  const _TodayProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Card(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('今日学习进度', style: Theme.of(context).textTheme.titleMedium),
          Text('$pct%', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: LinearProgressIndicator(value: progress, minHeight: 8,
              backgroundColor: AppColors.divider, valueColor: const AlwaysStoppedAnimation(AppColors.primary))),
      ])));
  }
}

class _QuickActionGrid extends StatelessWidget {
  final int wordsToReview;
  const _QuickActionGrid({required this.wordsToReview});

  @override
  Widget build(BuildContext context) {
    return GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.paddingSm, mainAxisSpacing: AppSizes.paddingSm, childAspectRatio: 1.4,
      children: [
        _ActionCard(icon: Icons.add_circle_outline, label: '添加单词', subtitle: '录入今日生词',
            color: AppColors.primary, onTap: () => context.push(AppRoutes.wordAdd)),
        _ActionCard(icon: Icons.auto_awesome_outlined, label: 'AI场景', subtitle: '故事中记单词',
            color: AppColors.secondary, onTap: () => context.push('${AppRoutes.sceneLearn}?sceneId=new')),
        _ActionCard(icon: Icons.refresh, label: '复习', subtitle: '$wordsToReview 个待复习',
            color: AppColors.warning, onTap: () => context.go(AppRoutes.review)),
        _ActionCard(icon: Icons.quiz_outlined, label: '听写练习', subtitle: '巩固记忆',
            color: AppColors.info, onTap: () {}),
      ]);
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String label; final String subtitle; final Color color; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: AppSizes.iconLg),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ]))));
  }
}

class _StatsRow extends StatelessWidget {
  final DailySummary summary;
  const _StatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatCard(label: '今日已学', value: '${summary.wordsLearnedToday}', unit: '词',
          icon: Icons.book_outlined, color: AppColors.primary)),
      const SizedBox(width: AppSizes.paddingSm),
      Expanded(child: _StatCard(label: '待复习', value: '${summary.wordsToReview}', unit: '词',
          icon: Icons.refresh, color: AppColors.warning)),
      const SizedBox(width: AppSizes.paddingSm),
      Expanded(child: _StatCard(label: '场景完成', value: '${summary.scenesCompleted}', unit: '个',
          icon: Icons.auto_awesome, color: AppColors.secondary)),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label; final String value; final String unit; final IconData icon; final Color color;
  const _StatCard({required this.label, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold)),
          Text(unit, style: Theme.of(context).textTheme.bodySmall),
        ]),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ])));
  }
}
