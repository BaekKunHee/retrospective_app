import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class EveningKPTScreen extends ConsumerStatefulWidget {
  const EveningKPTScreen({super.key});

  @override
  ConsumerState<EveningKPTScreen> createState() => _EveningKPTScreenState();
}

class _EveningKPTScreenState extends ConsumerState<EveningKPTScreen> {
  final TextEditingController _keepController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final List<TextEditingController> _tryControllers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeKPT();
  }

  void _initializeKPT() {
    final appState = ref.read(appStateProvider);
    final reflection = appState.todayReflection;

    if (reflection != null) {
      _keepController.text = reflection.keep ?? '';
      _problemController.text = reflection.problem ?? '';

      if (reflection.tryItems.isNotEmpty) {
        for (final tryItem in reflection.tryItems) {
          _tryControllers.add(TextEditingController(text: tryItem));
        }
      } else {
        _addNewTryItem();
      }
    } else {
      _addNewTryItem();
    }
  }

  @override
  void dispose() {
    _keepController.dispose();
    _problemController.dispose();
    for (final controller in _tryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewTryItem() {
    setState(() {
      _tryControllers.add(TextEditingController());
    });
  }

  void _removeTryItem(int index) {
    setState(() {
      _tryControllers[index].dispose();
      _tryControllers.removeAt(index);
    });
  }

  Future<void> _saveKPT() async {
    final keep = _keepController.text.trim();
    final problem = _problemController.text.trim();
    final tryItems = _tryControllers
        .map((controller) => controller.text.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (keep.isEmpty && problem.isEmpty && tryItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 하나의 항목을 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = ref.read(appStateProvider);
      await appState.saveEveningKPT(keep, problem, tryItems);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오늘의 회고가 저장되었습니다. 수고하셨습니다!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저녁 KPT 회고'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveKPT,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '완료',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroSection(),
            const SizedBox(height: 24),
            _buildMorningGoalsSection(),
            const SizedBox(height: 24),
            _buildKeepSection(),
            const SizedBox(height: 24),
            _buildProblemSection(),
            const SizedBox(height: 24),
            _buildTrySection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.nightlight_round,
                  color: Colors.indigo,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '하루를 돌아보며',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'KPT 회고를 통해 오늘 하루를 정리해보세요.\n• Keep: 계속 유지하고 싶은 것\n• Problem: 문제가 되었던 것\n• Try: 내일 시도해보고 싶은 것',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorningGoalsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final appState = ref.watch(appStateProvider);
        final reflection = appState.todayReflection;
        final morningGoals = reflection?.morningGoals ?? [];

        if (morningGoals.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '오늘의 목표',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...morningGoals.map((goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeepSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.thumb_up,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Keep (계속할 것)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '오늘 잘했던 것, 계속 유지하고 싶은 것들을 적어보세요.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keepController,
              decoration: InputDecoration(
                hintText: '예: 일찍 일어나서 운동했다, 집중해서 업무를 처리했다...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Problem (문제점)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '오늘 문제가 되었던 것, 개선이 필요한 것들을 적어보세요.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _problemController,
              decoration: InputDecoration(
                hintText: '예: 늦게 잠들어서 피곤했다, 중요한 일을 미뤘다...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Try (시도할 것)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '내일 시도해보고 싶은 것들을 적어보세요. 이 항목들은 내일 아침 목표 설정 시 참고됩니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_tryControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tryControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Try ${index + 1}',
                          hintText: '내일 시도해보고 싶은 구체적인 행동을 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    if (_tryControllers.length > 1) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeTryItem(index),
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addNewTryItem,
                icon: const Icon(Icons.add),
                label: const Text('Try 항목 추가'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveKPT,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('저장 중...'),
                ],
              )
            : const Text(
                '회고 완료하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
