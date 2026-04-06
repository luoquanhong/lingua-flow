import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

/// Mastery level for a word
enum WordMastery { newWord, learning, familiar, mastered }

/// A word due for review
class ReviewWord {
  final String id;
  final String word;
  final String meaning;
  final String? sentence;
  final WordMastery mastery;
  final int daysOverdue;

  const ReviewWord({required this.id, required this.word, required this.meaning,
      this.sentence, required this.mastery, required this.daysOverdue});
}

class ReviewState {
  final List<ReviewWord> words;
  final int currentIndex;
  final bool showingAnswer;
  final ReviewMode mode;
  final bool isLoading;
  final String? error;

  const ReviewState({this.words = const [], this.currentIndex = 0,
      this.showingAnswer = false, this.mode = ReviewMode.flip,
      this.isLoading = false, this.error});

  ReviewWord? get currentWord => words.isEmpty ? null : words[currentIndex];
  int get total => words.length;
  int get remaining => total - currentIndex;
  double get progress => total == 0 ? 0 : currentIndex / total;

  ReviewState copyWith({List<ReviewWord>? words, int? currentIndex,
      bool? showingAnswer, ReviewMode? mode, bool? isLoading, String? error}) {
    return ReviewState(words: words ?? this.words, currentIndex: currentIndex ?? this.currentIndex,
        showingAnswer: showingAnswer ?? this.showingAnswer, mode: mode ?? this.mode,
        isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
  }
}

enum ReviewMode { flip, type, choice }

class ReviewNotifier extends StateNotifier<ReviewState> {
  ReviewNotifier() : super(const ReviewState(isLoading: true)) { _load(); }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final words = [
      ReviewWord(id: '1', word: 'stakeholder', meaning: 'n. 利益相关者', mastery: WordMastery.learning, daysOverdue: 1),
      ReviewWord(id: '2', word: 'proposal', meaning: 'n. 提案; 建议书', sentence: 'She submitted a detailed proposal.',
          mastery: WordMastery.familiar, daysOverdue: 3),
      ReviewWord(id: '3', word: 'deadline', meaning: 'n. 最后期限', mastery: WordMastery.newWord, daysOverdue: 0),
      ReviewWord(id: '4', word: 'approve', meaning: 'v. 批准; 同意', mastery: WordMastery.learning, daysOverdue: 2),
      ReviewWord(id: '5', word: 'budget', meaning: 'n. 预算', mastery: WordMastery.mastered, daysOverdue: 7),
      ReviewWord(id: '6', word: 'leverage', meaning: 'v. 杠杆化; 利用', mastery: WordMastery.newWord, daysOverdue: 0),
      ReviewWord(id: '7', word: 'milestone', meaning: 'n. 里程碑', mastery: WordMastery.learning, daysOverdue: 1),
      ReviewWord(id: '8', word: 'optimize', meaning: 'v. 优化', mastery: WordMastery.familiar, daysOverdue: 4),
    ];
    state = state.copyWith(words: words, isLoading: false);
  }

  void reveal() => state = state.copyWith(showingAnswer: true);
  void next() {
    if (state.currentIndex < state.total - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1, showingAnswer: false);
    } else {
      // All done
      state = state.copyWith(currentIndex: state.total);
    }
  }
  void setMode(ReviewMode mode) => state = state.copyWith(mode: mode);
}

final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>((ref) => ReviewNotifier());

class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(reviewProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('复习'),
        actions: [
          if (!st.isLoading && st.words.isNotEmpty)
            PopupMenuButton<ReviewMode>(
              icon: const Icon(Icons.tune),
              onSelected: (mode) => ref.read(reviewProvider.notifier).setMode(mode),
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: ReviewMode.flip, child: Text('翻转卡片')),
                const PopupMenuItem(value: ReviewMode.type, child: Text('输入回忆')),
                const PopupMenuItem(value: ReviewMode.choice, child: Text('选择回忆')),
              ],
            ),
        ],
      ),
      body: st.isLoading
          ? const LoadingWidget(message: '加载复习列表...')
          : st.error != null
              ? EmptyStateWidget(icon: Icons.error_outline, title: '出错了', subtitle: st.error!, actionLabel: '重试',
                  onAction: () {})
              : st.words.isEmpty
                  ? EmptyStateWidget(icon: Icons.check_circle_outline, title: '太棒了！', subtitle: '暂无待复习单词',
                      actionLabel: '去学习', onAction: () {})
                  : st.currentIndex >= st.total
                      ? _AllDoneView(words: st.words)
                      : _ReviewCard(st: st),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  final ReviewState st;
  const _ReviewCard({required this.st});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final word = st.currentWord!;

    return Column(children: [
      // Progress + stats bar
      _ReviewTopBar(st: st),
      Expanded(child: GestureDetector(
        onTap: () {
          if (!st.showingAnswer) ref.read(reviewProvider.notifier).reveal();
        },
        child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: _FlipCard(word: word, show: st.showingAnswer)))),
      // Action buttons
      if (st.showingAnswer) _AnswerActions(st: st),
    ]);
  }
}

class _ReviewTopBar extends StatelessWidget {
  final ReviewState st;
  const _ReviewTopBar({required this.st});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('剩余 ${st.remaining} 个', style: Theme.of(context).textTheme.labelMedium),
          Text('${st.currentIndex + 1} / ${st.total}', style: Theme.of(context).textTheme.labelMedium),
        ]),
        const SizedBox(height: 4),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: st.progress, minHeight: 4,
              backgroundColor: AppColors.divider, valueColor: const AlwaysStoppedAnimation(AppColors.primary))),
      ]));
  }
}

class _FlipCard extends StatelessWidget {
  final ReviewWord word;
  final bool show;
  const _FlipCard({required this.word, required this.show});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.elevationMd,
      child: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
        child: show ? _AnswerSide(word: word) : _QuestionSide(word: word)));
  }
}

class _QuestionSide extends StatelessWidget {
  final ReviewWord word;
  const _QuestionSide({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('q'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        _MasteryBadge(mastery: word.mastery),
        const SizedBox(height: 24),
        Text(word.word, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('点击卡片查看释义', style: Theme.of(context).textTheme.bodySmall),
      ]));
  }
}

class _AnswerSide extends StatelessWidget {
  final ReviewWord word;
  const _AnswerSide({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('a'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(word.word, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(word.meaning, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
        if (word.sentence != null) ...[
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background,
                borderRadius: BorderRadius.circular(8)),
            child: Text(word.sentence!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic, color: AppColors.textSecondary))),
        ],
        if (word.daysOverdue > 0) ...[
          const SizedBox(height: 12),
          Text('已逾期 $daysOverdue 天', style: TextStyle(color: AppColors.error, fontSize: 12)),
        ],
      ])));
  }

  String get daysOverdue => '${word.daysOverdue}';
}

class _AnswerActions extends ConsumerWidget {
  final ReviewState st;
  const _AnswerActions({required this.st});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Row(children: [
        Expanded(child: _ActionBtn(
          icon: Icons.refresh, label: '忘记', color: AppColors.error,
          onTap: () => ref.read(reviewProvider.notifier).next())),
        const SizedBox(width: 12),
        Expanded(child: _ActionBtn(
          icon: Icons.tips_and_updates_outlined, label: '模糊', color: AppColors.warning,
          onTap: () => ref.read(reviewProvider.notifier).next())),
        const SizedBox(width: 12),
        Expanded(child: _ActionBtn(
          icon: Icons.check_circle_outline, label: '记住', color: AppColors.success,
          onTap: () => ref.read(reviewProvider.notifier).next())),
      ])));
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ])));
  }
}

class _MasteryBadge extends StatelessWidget {
  final WordMastery mastery;
  const _MasteryBadge({required this.mastery});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (mastery) {
      WordMastery.newWord => ('新词', AppColors.info),
      WordMastery.learning => ('学习中', AppColors.warning),
      WordMastery.familiar => ('熟悉', AppColors.secondary),
      WordMastery.mastered => ('已掌握', AppColors.success),
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)));
  }
}

class _AllDoneView extends StatelessWidget {
  final List<ReviewWord> words;
  const _AllDoneView({required this.words});

  @override
  Widget build(BuildContext context) {
    // Simulate Ebbinghaus summary
    return SingleChildScrollView(padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(children: [
        const SizedBox(height: 32),
        Container(padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
          child: const Icon(Icons.celebration, color: AppColors.success, size: 64)),
        const SizedBox(height: 24),
        Text('今日复习完成！', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('${words.length} 个单词已复习完毕', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 32),
        Text('艾宾浩斯记忆曲线', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(height: 200, child: _EbbinghausChart(words: words)),
        const SizedBox(height: 24),
        Card(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(children: [
            _StatRow(label: '新词', value: '${words.where((w) => w.mastery == WordMastery.newWord).length}', color: AppColors.info),
            const Divider(),
            _StatRow(label: '学习中', value: '${words.where((w) => w.mastery == WordMastery.learning).length}', color: AppColors.warning),
            const Divider(),
            _StatRow(label: '熟悉', value: '${words.where((w) => w.mastery == WordMastery.familiar).length}', color: AppColors.secondary),
            const Divider(),
            _StatRow(label: '已掌握', value: '${words.where((w) => w.mastery == WordMastery.mastered).length}', color: AppColors.success),
          ]))),
      ]));
  }
}

class _StatRow extends StatelessWidget {
  final String label; final String value; final Color color;
  const _StatRow({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12), Expanded(child: Text(label)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ]));
  }
}

class _EbbinghausChart extends StatelessWidget {
  final List<ReviewWord> words;
  const _EbbinghausChart({required this.words});

  @override
  Widget build(BuildContext context) {
    // Simulate retention decay curve
    final points = [
      const FlSpot(0, 1.0),
      const FlSpot(1, 0.58),
      const FlSpot(3, 0.44),
      const FlSpot(7, 0.36),
      const FlSpot(14, 0.28),
      const FlSpot(30, 0.25),
      const FlSpot(60, 0.21),
    ];
    return LineChart(LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, interval: 1,
          getTitlesWidget: (val, _) => Text('${val.toInt()}d',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)))),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: points,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true, color: AppColors.primary.withOpacity(0.1)),
        ),
      ],
    ));
  }
}
