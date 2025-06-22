import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class MorningGoalsScreen extends ConsumerStatefulWidget {
  final List<String> previousTryItems;

  const MorningGoalsScreen({
    super.key,
    required this.previousTryItems,
  });

  @override
  ConsumerState<MorningGoalsScreen> createState() => _MorningGoalsScreenState();
}

class _MorningGoalsScreenState extends ConsumerState<MorningGoalsScreen> {
  final List<TextEditingController> _goalControllers = [];
  final List<bool> _selectedTryItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeTryItems();
    _initializeGoals();
  }

  void _initializeTryItems() {
    _selectedTryItems.addAll(
      List.generate(widget.previousTryItems.length, (index) => false),
    );
  }

  void _initializeGoals() {
    final appState = ref.read(appStateProvider);
    final existingGoals = appState.todayReflection?.morningGoals ?? [];

    if (existingGoals.isNotEmpty) {
      for (final goal in existingGoals) {
        _goalControllers.add(TextEditingController(text: goal));
      }
    } else {
      _addNewGoal();
    }
  }

  @override
  void dispose() {
    for (final controller in _goalControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewGoal() {
    setState(() {
      _goalControllers.add(TextEditingController());
    });
  }

  void _removeGoal(int index) {
    setState(() {
      _goalControllers[index].dispose();
      _goalControllers.removeAt(index);
    });
  }

  void _addSelectedTryItems() {
    for (int i = 0; i < widget.previousTryItems.length; i++) {
      if (_selectedTryItems[i]) {
        _goalControllers.add(
          TextEditingController(text: widget.previousTryItems[i]),
        );
      }
    }
    setState(() {
      _selectedTryItems.fillRange(0, _selectedTryItems.length, false);
    });
  }

  Future<void> _saveGoals() async {
    setState(() {
      _isLoading = true;
    });

    final goals = _goalControllers
        .map((controller) => controller.text.trim())
        .where((goal) => goal.isNotEmpty)
        .toList();

    if (goals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 하나의 목표를 입력해주세요.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final appState = ref.read(appStateProvider);
      await appState.saveMorningGoals(goals);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오늘의 목표가 저장되었습니다.')),
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
        title: const Text('아침 목표 설정'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveGoals,
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
                    '저장',
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
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            if (widget.previousTryItems.isNotEmpty) ...[
              _buildPreviousTryItemsSection(),
              const SizedBox(height: 24),
            ],
            _buildGoalsSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
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
                  Icons.wb_sunny,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  '좋은 아침입니다!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '오늘 하루를 의미있게 보내기 위한 목표를 설정해보세요.\n어제의 TRY 항목을 참고하여 연속성 있는 성장을 만들어가요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousTryItemsSection() {
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
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '어제의 TRY 항목',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '어제 시도해보기로 한 항목들입니다. 오늘 목표에 포함하고 싶은 항목을 선택하세요.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ...List.generate(widget.previousTryItems.length, (index) {
              return CheckboxListTile(
                title: Text(widget.previousTryItems[index]),
                value: _selectedTryItems[index],
                onChanged: (value) {
                  setState(() {
                    _selectedTryItems[index] = value ?? false;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }),
            if (_selectedTryItems.any((selected) => selected)) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addSelectedTryItems,
                  icon: const Icon(Icons.add),
                  label: const Text('선택한 항목을 목표에 추가'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
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
            const SizedBox(height: 16),
            ...List.generate(_goalControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _goalControllers[index],
                        decoration: InputDecoration(
                          labelText: '목표 ${index + 1}',
                          hintText: '구체적이고 실행 가능한 목표를 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    if (_goalControllers.length > 1) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeGoal(index),
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
                onPressed: _addNewGoal,
                icon: const Icon(Icons.add),
                label: const Text('목표 추가'),
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
        onPressed: _isLoading ? null : _saveGoals,
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
                '목표 저장하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
