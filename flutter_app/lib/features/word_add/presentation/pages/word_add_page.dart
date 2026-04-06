import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Context label options for word sources
const _contextOptions = [
  '电影/美剧', '小说/书籍', '新闻报道', '播客/演讲',
  '工作中', '日常对话', '社交媒体', '考试真题', '其他'
];

/// Word entry form state
class WordEntry {
  final String word;
  final String meaning;
  final String context;
  final String customContext;
  final String pronunciation;
  final String notes;

  const WordEntry({
    this.word = '',
    this.meaning = '',
    this.context = '',
    this.customContext = '',
    this.pronunciation = '',
    this.notes = '',
  });

  WordEntry copyWith({
    String? word, String? meaning, String? context,
    String? customContext, String? pronunciation, String? notes,
  }) {
    return WordEntry(
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      context: context ?? this.context,
      customContext: customContext ?? this.customContext,
      pronunciation: pronunciation ?? this.pronunciation,
      notes: notes ?? this.notes,
    );
  }

  bool get isValid => word.trim().isNotEmpty && meaning.trim().isNotEmpty;
}

class WordAddNotifier extends StateNotifier<WordEntry> {
  WordAddNotifier() : super(const WordEntry());

  void updateWord(String v) => state = state.copyWith(word: v);
  void updateMeaning(String v) => state = state.copyWith(meaning: v);
  void updateContext(String v) => state = state.copyWith(context: v);
  void updateCustomContext(String v) => state = state.copyWith(customContext: v);
  void updatePronunciation(String v) => state = state.copyWith(pronunciation: v);
  void updateNotes(String v) => state = state.copyWith(notes: v);

  void reset() => state = const WordEntry();

  /// Save word locally (Hive) and optionally call backend
  Future<bool> save() async {
    if (!state.isValid) return false;
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: integrate Hive + API
    return true;
  }
}

final wordAddProvider = StateNotifierProvider<WordAddNotifier, WordEntry>((ref) => WordAddNotifier());

class WordAddPage extends ConsumerStatefulWidget {
  const WordAddPage({super.key});

  @override
  ConsumerState<WordAddPage> createState() => _WordAddPageState();
}

class _WordAddPageState extends ConsumerState<WordAddPage> {
  final _wordCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _pronCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _customCtxCtrl = TextEditingController();
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _wordCtrl.addListener(() => ref.read(wordAddProvider.notifier).updateWord(_wordCtrl.text));
    _meaningCtrl.addListener(() => ref.read(wordAddProvider.notifier).updateMeaning(_meaningCtrl.text));
    _pronCtrl.addListener(() => ref.read(wordAddProvider.notifier).updatePronunciation(_pronCtrl.text));
    _notesCtrl.addListener(() => ref.read(wordAddProvider.notifier).updateNotes(_notesCtrl.text));
    _customCtxCtrl.addListener(() => ref.read(wordAddProvider.notifier).updateCustomContext(_customCtxCtrl.text));
  }

  @override
  void dispose() {
    _wordCtrl.dispose(); _meaningCtrl.dispose(); _pronCtrl.dispose();
    _notesCtrl.dispose(); _customCtxCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_wordCtrl.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入单词')));
      return;
    }
    if (!_meaningCtrl.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入释义')));
      return;
    }
    setState(() => _saving = true);
    final ok = await ref.read(wordAddProvider.notifier).save();
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('单词保存成功 ✓')));
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存失败，请重试')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加单词'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        actions: [TextButton(onPressed: _saved ? null : _handleSave, child: _saving
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('保存', style: TextStyle(fontWeight: FontWeight.w600)))],
      ),
      body: _saved ? _SuccessView(onAddMore: () {
        ref.read(wordAddProvider.notifier).reset();
        _wordCtrl.clear(); _meaningCtrl.clear(); _pronCtrl.clear(); _notesCtrl.clear();
        setState(() => _saved = false);
      }) : _FormView(
        wordCtrl: _wordCtrl, meaningCtrl: _meaningCtrl, pronCtrl: _pronCtrl,
        notesCtrl: _notesCtrl, customCtxCtrl: _customCtxCtrl,
      ),
    );
  }
}

class _FormView extends ConsumerWidget {
  final TextEditingController wordCtrl, meaningCtrl, pronCtrl, notesCtrl, customCtxCtrl;
  const _FormView({required this.wordCtrl, required this.meaningCtrl, required this.pronCtrl,
      required this.notesCtrl, required this.customCtxCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(wordAddProvider);
    final notifier = ref.read(wordAddProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Word input (large, prominent)
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('单词 *', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(controller: wordCtrl,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: '输入英文单词', border: InputBorder.none,
                  filled: false, contentPadding: EdgeInsets.zero),
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
            ),
          ]),
        ),
        const SizedBox(height: AppSizes.paddingMd),

        // Meaning
        _Label('释义 *'),
        const SizedBox(height: 6),
        TextField(controller: meaningCtrl, maxLines: 2,
          decoration: const InputDecoration(hintText: '输入中文释义（可多行）')),
        const SizedBox(height: AppSizes.paddingMd),

        // Pronunciation
        _Label('音标（可选）'),
        const SizedBox(height: 6),
        TextField(controller: pronCtrl,
          decoration: const InputDecoration(hintText: '如：/prəˌnʌnsiˈeɪʃn/')),
        const SizedBox(height: AppSizes.paddingMd),

        // Context chips
        _Label('来源语境'),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: _contextOptions.map((opt) {
          final selected = entry.context == opt;
          return ChoiceChip(
            label: Text(opt),
            selected: selected,
            onSelected: (_) => notifier.updateContext(selected ? '' : opt),
            selectedColor: AppColors.primary.withOpacity(0.15),
            labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal),
          );
        }).toList()),
        const SizedBox(height: AppSizes.paddingSm),

        // Custom context input (shown when "其他" is selected)
        if (entry.context == '其他') ...[
          const SizedBox(height: 6),
          TextField(controller: customCtxCtrl,
            decoration: const InputDecoration(hintText: '请输入自定义语境来源')),
        ],
        const SizedBox(height: AppSizes.paddingMd),

        // Notes
        _Label('笔记（可选）'),
        const SizedBox(height: 6),
        TextField(controller: notesCtrl, maxLines: 3,
          decoration: const InputDecoration(hintText: '例句、同义词、记忆技巧...')),
        const SizedBox(height: 32),

        // Save button
        SizedBox(width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {}, // handled by _handleSave in parent
            icon: const Icon(Icons.save_outlined),
            label: const Text('保存到词库'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, AppSizes.buttonHeightLg),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onAddMore;
  const _SuccessView({required this.onAddMore});
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 64)),
        const SizedBox(height: 24),
        Text('保存成功！', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('单词已加入你的词库，稍后可在 AI 场景中复习。',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 32),
        OutlinedButton.icon(onPressed: onAddMore, icon: const Icon(Icons.add), label: const Text('继续添加')),
      ])));
  }
}
