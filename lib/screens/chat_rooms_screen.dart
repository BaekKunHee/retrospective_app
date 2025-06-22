import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class ChatRoomsScreen extends ConsumerWidget {
  const ChatRoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 회고'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateChatRoomDialog(context, ref);
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final appState = ref.watch(appStateProvider);
          if (!appState.canUseGroupFeatures) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '그룹 회고 기능 잠금',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '그룹 회고 기능을 사용하려면\n90일 내에 30회 이상의 개인 회고를 완료해야 합니다.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    LinearProgressIndicator(
                      value: (appState.currentUser?.reflectionCount ?? 0) / 30,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '진행률: ${appState.currentUser?.reflectionCount ?? 0}/30',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          final chatRooms = appState.chatRooms;
          final joinedChatRooms = appState.joinedChatRooms;

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: '참여 중인 방'),
                    Tab(text: '전체 방'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildJoinedChatRoomsList(context, joinedChatRooms),
                      _buildAllChatRoomsList(context, chatRooms, appState),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJoinedChatRoomsList(
      BuildContext context, List<dynamic> joinedRooms) {
    if (joinedRooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '참여 중인 그룹 회고방이 없습니다.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '새로운 방을 만들거나 기존 방에 참여해보세요!',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: joinedRooms.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.group),
            ),
            title: const Text('샘플 그룹 회고방'),
            subtitle: const Text('참여자 3명 • 활성'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('채팅 기능은 준비 중입니다.')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAllChatRoomsList(BuildContext context, List<dynamic> chatRooms,
      AppStateProvider appState) {
    if (chatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 생성된 그룹 회고방이 없습니다.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '첫 번째 그룹 회고방을 만들어보세요!',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton.icon(
                  onPressed: () => _showCreateChatRoomDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('그룹 회고방 만들기'),
                );
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: chatRooms.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.group),
            ),
            title: const Text('샘플 그룹 회고방'),
            subtitle: const Text('참여자 2/5명 • 모집 중'),
            trailing: ElevatedButton(
              onPressed: appState.canJoinMoreChatRooms
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('그룹 참여 기능은 준비 중입니다.')),
                      );
                    }
                  : null,
              child: const Text('참여'),
            ),
          ),
        );
      },
    );
  }

  void _showCreateChatRoomDialog(BuildContext context, WidgetRef ref) {
    final appState = ref.read(appStateProvider);

    if (!appState.canUseGroupFeatures) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 기능을 사용하려면 더 많은 개인 회고를 작성해주세요.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('그룹 회고방 만들기'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '방 이름',
                hintText: '예: 스타트업 팀 회고',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '방 설명',
                hintText: '이 그룹 회고방에 대한 간단한 설명',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('그룹 회고방 생성 기능은 준비 중입니다.')),
              );
            },
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }
}
