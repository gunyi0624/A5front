import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/app_confirm_dialog.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController searchController = TextEditingController();

  final List<_ScheduleItem> schedules = [
    _ScheduleItem(
      title: '도쿄 여행',
      region: '도쿄',
      period: '2026.07.02 ~ 2026.07.05',
      duration: '3박 4일',
      status: '진행 중',
      theme: '식도락 · 쇼핑 · 힐링',
      isCompleted: false,
    ),
    _ScheduleItem(
      title: '오사카 가족 여행',
      region: '오사카',
      period: '2026.08.10 ~ 2026.08.13',
      duration: '3박 4일',
      status: '예정',
      theme: '가족 · 맛집 · 관광',
      isCompleted: false,
    ),
    _ScheduleItem(
      title: '후쿠오카 짧은 여행',
      region: '후쿠오카',
      period: '2026.03.15 ~ 2026.03.17',
      duration: '2박 3일',
      status: '완료',
      theme: '힐링 · 온천 · 식도락',
      isCompleted: true,
    ),
  ];

  String keyword = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<_ScheduleItem> get filteredSchedules {
    if (keyword.trim().isEmpty) return schedules;

    final query = keyword.trim().toLowerCase();

    return schedules.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.region.toLowerCase().contains(query) ||
          item.period.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _showDeleteDialog(_ScheduleItem item) async {
    final result = await showAppConfirmDialog(
      context: context,
      title: '일정을 삭제하시겠습니까?',
      message: '${item.title} 일정이 삭제됩니다.',
      confirmText: '삭제',
      type: AppConfirmDialogType.danger,
    );

    if (result) {
      setState(() {
        schedules.remove(item);
      });
    }
  }

  Future<void> _showRenameDialog(_ScheduleItem item) async {
    final controller = TextEditingController(text: item.title);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('일정 제목 수정'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '새 제목을 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    setState(() {
      item.title = result;
    });
  }

  void _showCardMenu(_ScheduleItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BottomSheetAction(
                  icon: Icons.edit_rounded,
                  label: '제목 수정',
                  onTap: () {
                    Navigator.pop(context);
                    _showRenameDialog(item);
                  },
                ),
                _BottomSheetAction(
                  icon: Icons.delete_rounded,
                  label: '삭제',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteDialog(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredSchedules;

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: const AppDrawer(currentRoute: AppRoutes.schedule),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPageHeader(
                    title: '일정 조회',
                    onMenuTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),

                  const SizedBox(height: 22),

                  Text(
                    '저장된 여행 일정을\n확인해보세요.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '여행 제목, 지역, 기간으로 원하는 일정을 빠르게 찾을 수 있습니다.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 22),

                  _SearchBox(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        keyword = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Text(
                        '전체 일정',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${items.length}개',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (items.isEmpty)
                    _EmptySchedule()
                  else
                    ...items.map(
                          (item) => _ScheduleCard(
                        item: item,
                        onTap: () => context.go('/result'),
                        onMoreTap: () => _showCardMenu(item),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '여행 제목, 지역 또는 기간 검색',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final _ScheduleItem item;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _ScheduleCard({
    required this.item,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = item.isCompleted ? AppColors.textSecondary : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        item.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.flight_takeoff_rounded,
                        color: statusColor,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${item.region} · ${item.duration}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: onMoreTap,
                      icon: const Icon(Icons.more_vert_rounded),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_month_rounded,
                        text: item.period,
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.interests_rounded,
                        text: item.theme,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '상세보기',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '검색 결과가 없습니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 제목, 지역, 기간으로 검색해보세요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BottomSheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _BottomSheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: itemColor),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleItem {
  String title;
  final String region;
  final String period;
  final String duration;
  final String status;
  final String theme;
  final bool isCompleted;

  _ScheduleItem({
    required this.title,
    required this.region,
    required this.period,
    required this.duration,
    required this.status,
    required this.theme,
    required this.isCompleted,
  });
}