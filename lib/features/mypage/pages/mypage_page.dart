import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_page_header.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

enum NotificationFrequency {
  morning,
  afternoon,
  both,
}

class _MyPageState extends State<MyPage> {
  bool weatherNotificationEnabled = true;
  NotificationFrequency notificationFrequency = NotificationFrequency.both;

  TimeOfDay morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay afternoonTime = const TimeOfDay(hour: 18, minute: 0);

  Future<void> _pickTime({
    required bool isMorning,
  }) async {
    final initialTime = isMorning ? morningTime : afternoonTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isMorning ? '오전 알림 시간 선택' : '오후 알림 시간 선택',
      cancelText: '취소',
      confirmText: '확인',
    );

    if (picked == null) return;

    setState(() {
      if (isMorning) {
        morningTime = picked;
      } else {
        afternoonTime = picked;
      }
    });
  }

  String _formatTime(TimeOfDay time) {
    final isAm = time.hour < 12;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '${isAm ? '오전' : '오후'} $hour:$minute';
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('로그아웃하시겠습니까?'),
          content: const Text('현재 계정에서 로그아웃됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      context.go('/login');
    }
  }

  Future<void> _showWithdrawDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('회원탈퇴하시겠습니까?'),
          content: const Text(
            '회원 정보와 저장된 여행 일정이 모두 삭제되며 복구할 수 없습니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('회원탈퇴'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: const AppDrawer(currentRoute: AppRoutes.mypage),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPageHeader(
                    title: '마이페이지',
                    onMenuTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),

                  const SizedBox(height: 28),

                  _ProfileCard(),

                  const SizedBox(height: 18),

                  _SectionCard(
                    title: '기상 정보 알림',
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '날씨 변화와 여행 알림을 받아보세요.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Switch(
                          value: weatherNotificationEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              weatherNotificationEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Opacity(
                    opacity: weatherNotificationEnabled ? 1 : 0.45,
                    child: IgnorePointer(
                      ignoring: !weatherNotificationEnabled,
                      child: _SectionCard(
                        title: '알림 수신',
                        child: Column(
                          children: [
                            _RadioTile(
                              label: '오전만',
                              selected:
                              notificationFrequency == NotificationFrequency.morning,
                              onTap: () {
                                setState(() {
                                  notificationFrequency =
                                      NotificationFrequency.morning;
                                });
                              },
                            ),
                            _RadioTile(
                              label: '오후만',
                              selected:
                              notificationFrequency == NotificationFrequency.afternoon,
                              onTap: () {
                                setState(() {
                                  notificationFrequency =
                                      NotificationFrequency.afternoon;
                                });
                              },
                            ),
                            _RadioTile(
                              label: '오전 + 오후',
                              selected:
                              notificationFrequency == NotificationFrequency.both,
                              onTap: () {
                                setState(() {
                                  notificationFrequency = NotificationFrequency.both;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Opacity(
                    opacity: weatherNotificationEnabled ? 1 : 0.45,
                    child: IgnorePointer(
                      ignoring: !weatherNotificationEnabled,
                      child: _SectionCard(
                        title: '알림 시간',
                        child: Column(
                          children: [
                            if (notificationFrequency ==
                                NotificationFrequency.morning ||
                                notificationFrequency == NotificationFrequency.both)
                              _TimeTile(
                                label: '오전 시간',
                                time: _formatTime(morningTime),
                                onTap: () => _pickTime(isMorning: true),
                              ),
                            if (notificationFrequency ==
                                NotificationFrequency.afternoon ||
                                notificationFrequency == NotificationFrequency.both)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: notificationFrequency ==
                                      NotificationFrequency.both
                                      ? 12
                                      : 0,
                                ),
                                child: _TimeTile(
                                  label: '오후 시간',
                                  time: _formatTime(afternoonTime),
                                  onTap: () => _pickTime(isMorning: false),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _showLogoutDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _showWithdrawDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        '회원탈퇴',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 42,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '정건의',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'AI Travel Planner 사용자',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.schedule_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}