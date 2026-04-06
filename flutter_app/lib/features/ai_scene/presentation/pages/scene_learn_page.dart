import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Represents a fill-in-the-blank exercise in a scene
class SceneGap {
  final int index;
  final String wordId;
  final String display; // shown as underscore in story
  final String correctAnswer;
  String? userAnswer;
  bool get isCorrect => userAnswer?.trim().toLowerCase() == correctAnswer.trim().toLowerCase();

  const SceneGap({required this.index, required this.wordId, required this.display,
      required this.correctAnswer, this.userAnswer});
}

/// Represents an AI-generated learning scene
class LearningScene {
  final String id;
  final String title;
  final String genre; // e.g. "Office Drama", "Cafe Chat"
  final String storyText; // includes ___ placeholders
  final List<SceneGap> gaps;
  final List<String> vocabList; // words used in scene
  final int difficulty; // 1-3

  const LearningScene({required this.id, required this.title, required this.genre,
      required this.storyText, required this.gaps, required this.vocabList, this.difficulty = 1});

  int get correctCount => gaps.where((g) => g.isCorrect).length;
  double get score => gaps.isEmpty ? 0 : correctCount / gaps.length;
  bool get isComplete => gaps.every((g) => g.userAnswer != null);
}

/// State for scene learning
enum SceneLearnPhase { loading, reading, filling, result }

class SceneLearnState {
  final SceneLearnPhase phase;
  final LearningScene? scene;
  final int currentGapIndex;
  final String? error;

  const SceneLearnState({this.phase = SceneLearnPhase.loading, this.scene,
      this.currentGapIndex = 0, this.error});

  SceneLearnState copyWith({SceneLearnPhase? phase, LearningScene? scene,
      int? currentGapIndex, String? error}) {
    return SceneLearnState(
      phase: phase ?? this.phase,
      scene: scene ?? this.scene,
      currentGapIndex: currentGapIndex ?? this.currentGapIndex,
      error: error ?? this.error,
    );
  }
}

class SceneLearnNotifier extends StateNotifier<SceneLearnState> {
  final String sceneId;
  SceneLearnNotifier(this.sceneId) : super(const SceneLearnState()) { _loadScene(); }

  Future<void> _loadScene() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Mock scene — replace with API call to Go backend
    final scene = LearningScene(
      id: sceneId,
      title: 'The Client Meeting',
      genre: '职场对话',
      difficulty: 2,
      vocabList: ['stakeholder', 'proposal', 'deadline', 'approve', 'budget'],
      storyText: '''Sarah was preparing for an important __1__ meeting. 
The project __2__ was ready, but she was nervous about the __3__ discussion.

"Hi Sarah," said Tom, the main __4__. "Can we go over the __5__ one more time?"

Sarah smiled confidently and opened her laptop. The presentation was polished, 
and she had rehearsed every slide. She knew that getting __6__ from leadership 
would secure the next quarter's __7__ for her team.''',
      gaps: [
        SceneGap(index: 0, wordId: 'w1', display: '__1__', correctAnswer: 'stakeholder'),
        SceneGap(index: 1, wordId: 'w2', display: '__2__', correctAnswer: 'proposal'),
        SceneGap(index: 2, wordId: 'w3', display: '__3__', correctAnswer: 'deadline'),
        SceneGap(index: 3, wordId: 'w4', display: '__4__', correctAnswer: 'stakeholder'),
        SceneGap(index: 4, wordId: 'w5', display: '__5__', correctAnswer: 'budget'),
        SceneGap(index: 5, wordId: 'w6', display: '__6__', correctAnswer: 'approve'),
        SceneGap(index: 6, wordId: 'w7', display: '__7__', correctAnswer: 'budget'),
      ],
    );
    state = state.copyWith(scene: scene, phase: SceneLearnPhase.reading);
  }

  void proceedToFill() {
    state = state.copyWith(phase: SceneLearnPhase.filling, currentGapIndex: 0);
  }

  void submitAnswer(String answer) {
    if (state.scene == null) return;
    final gaps = List<SceneGap>.from(state.scene!.gaps);
    gaps[state.currentGapIndex] = SceneGap(
      index: state.currentGapIndex,
      wordId: gaps[state.currentGapIndex].wordId,
      display: gaps[state.currentGapIndex].display,
      correctAnswer: gaps[state.currentGapIndex].correctAnswer,
      userAnswer: answer,
    );
    final updatedScene = LearningScene(
      id: state.scene!.id, title: state.scene!.title, genre: state.scene!.genre,
      storyText: state.scene!.storyText, gaps: gaps,
      vocabList: state.scene!.vocabList, difficulty: state.scene!.difficulty,
    );

    final nextIndex = state.currentGapIndex + 1;
    if (nextIndex >= gaps.length) {
      state = state.copyWith(scene: updatedScene, phase: SceneLearnPhase.result);
    } else {
      state = state.copyWith(scene: updatedScene, currentGapIndex: nextIndex);
    }
  }

  void retry() {
    if (state.scene == null) return;
    final gaps = state.scene!.gaps.map((g) =>
      SceneGap(index: g.index, wordId: g.wordId, display: g.display,
          correctAnswer: g.correctAnswer)).toList();
    final scene = LearningScene(id: state.scene!.id, title: state.scene!.title,
        genre: state.scene!.genre, storyText: state.scene!.storyText,
        gaps: gaps, vocabList: state.scene!.vocabList,
        difficulty: state.scene!.difficulty);
    state = SceneLearnState(scene: scene, phase: SceneLearnPhase.filling, currentGapIndex: 0);
  }
}

final sceneLearnProvider = StateNotifierProvider.family<SceneLearnNotifier, SceneLearnState, String>(
  (ref, sceneId) => SceneLearnNotifier(sceneId),
);

class SceneLearnPage extends ConsumerWidget {
  final String sceneId;
  const SceneLearnPage({super.key, required this.sceneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(sceneLearnProvider(sceneId));
    return Scaffold(
      appBar: AppBar(title: Text(st.scene?.title ?? 'AI 场景学习')),
      body: switch (st.phase) {
        SceneLearnPhase.loading => const LoadingWidget(message: 'AI 正在生成场景...'),
        SceneLearnPhase.reading => _ReadingView(scene: st.scene!),
        SceneLearnPhase.filling => _FillView(st: st),
        SceneLearnPhase.result => _ResultView(st: st),
      },
    );
  }
}

class _ReadingView extends StatelessWidget {
  final LearningScene scene;
  const _ReadingView({required this.scene});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(Child: SingleChildScrollView(padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _GenreChip(genre: scene.genre),
            const SizedBox(width: 8),
            _DifficultyIndicator(level: scene.difficulty),
          ]),
          const SizedBox(height: 16),
          Text('阅读场景，思考划线单词的意思：',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingLg),
            child: _StoryWithGaps(text: scene.storyText, gaps: scene.gaps)))),
          const SizedBox(height: 16),
          Text('本场景词汇', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
              children: scene.vocabList.map((w) => Chip(label: Text(w))).toList()),
        ]))),
      SafeArea(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: SizedBox(width: double.infinity,
          child: ElevatedButton(onPressed: () {}, // handled by notifier in parent
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 52)),
            onPressed: () {}, child: const Text('开始填空练习 →'))))),
    ]);
  }
}

class _FillView extends ConsumerWidget {
  final SceneLearnState st;
  const _FillView({required this.st});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = st.scene!;
    final gap = scene.gaps[st.currentGapIndex];
    final answerCtrl = TextEditingController();

    return Column(children: [
      // Progress bar
      LinearProgressIndicator(
        value: (st.currentGapIndex + 1) / scene.gaps.length,
        backgroundColor: AppColors.divider,
        valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
      ),
      Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Text('${st.currentGapIndex + 1} / ${scene.gaps.length}',
            style: Theme.of(context).textTheme.labelMedium)),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('请填写划线单词：', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Hint: 回忆场景中这个词的用法', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          // Word hint card (shows surrounding context)
          Card(color: AppColors.primary.withOpacity(0.06),
            child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Row(children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('提示：这个词是 "${\_getHint(gap.display)}"',
                    style: const TextStyle(color: AppColors.primary))),
              ]))),
          const SizedBox(height: 24),
          TextField(controller: answerCtrl, autofocus: true,
            decoration: InputDecoration(
              hintText: '输入单词',
              suffixIcon: IconButton(icon: const Icon(Icons.send),
                onPressed: () => ref.read(sceneLearnProvider(st.scene!.id).notifier).submitAnswer(answerCtrl.text)),
            ),
            onSubmitted: (v) => ref.read(sceneLearnProvider(st.scene!.id).notifier).submitAnswer(v),
          ),
        ]))),
      SafeArea(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: SizedBox(width: double.infinity,
          child: ElevatedButton(onPressed: () => ref.read(sceneLearnProvider(st.scene!.id).notifier).submitAnswer(answerCtrl.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 52)),
            child: const Text('确认答案'))))),
    ]);
  }

  String _getHint(String display) {
    // Strip underscores for hint
    return display.replaceAll('_', '').trim();
  }
}

class _ResultView extends ConsumerWidget {
  final SceneLearnState st;
  const _ResultView({required this.st});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = st.scene!;
    final score = scene.score;
    final pct = (score * 100).round();

    Color scoreColor = AppColors.error;
    String scoreLabel = '继续加油';
    if (pct >= 80) { scoreColor = AppColors.success; scoreLabel = '太棒了！'; }
    else if (pct >= 50) { scoreColor = AppColors.warning; scoreLabel = '还不错'; }

    return SingleChildScrollView(padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(children: [
        const SizedBox(height: 32),
        Container(padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: scoreColor.withOpacity(0.12), shape: BoxShape.circle),
          child: Text('$pct%', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: scoreColor))),
        const SizedBox(height: 16),
        Text(scoreLabel, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('${scene.correctCount} / ${scene.gaps.length} 正确', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 32),
        Text('答案回顾', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(children: scene.gaps.map<Widget>((g) {
            final correct = g.isCorrect;
            return Padding(padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? AppColors.success : AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${g.display} → ${g.userAnswer ?? "（未填）"}',
                      style: TextStyle(color: correct ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600)),
                  if (!correct) Text('正确答案: ${g.correctAnswer}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success)),
                ])),
              ]));
          }).toList()))),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity,
          child: ElevatedButton(onPressed: () => ref.read(sceneLearnProvider(scene.id).notifier).retry(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
                foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 52)),
            child: const Text('再试一次'))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity,
          child: OutlinedButton(onPressed: () {}, child: const Text('返回首页'))),
      ]));
  }
}

class _GenreChip extends StatelessWidget {
  final String genre;
  const _GenreChip({required this.genre});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
      child: Text(genre, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)));
  }
}

class _DifficultyIndicator extends StatelessWidget {
  final int level;
  const _DifficultyIndicator({required this.level});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) =>
        Icon(Icons.star, size: 16, color: i < level ? AppColors.warning : AppColors.divider)));
  }
}

class _StoryWithGaps extends StatelessWidget {
  final String text;
  final List<SceneGap> gaps;
  const _StoryWithGaps({required this.text, required this.gaps});

  @override
  Widget build(BuildContext context) {
    // Highlight gap placeholders in story text
    final spans = <TextSpan>[];
    final pattern = RegExp(r'__\d+__');
    int lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(text: match.group(0),
          style: const TextStyle(backgroundColor: Color(0xFFFFFBEB),
              color: AppColors.warning, fontWeight: FontWeight.bold)));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) spans.add(TextSpan(text: text.substring(lastEnd)));

    return RichText(text: TextSpan(style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8), children: spans));
  }
}
