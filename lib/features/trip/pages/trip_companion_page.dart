import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/trip_step_indicator.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_bottom_navigation.dart';

class TripCompanionPage extends StatefulWidget {
  const TripCompanionPage({super.key});

  @override
  State<TripCompanionPage> createState() => _TripCompanionPageState();
}

class _TripCompanionPageState extends State<TripCompanionPage> {
  String? selectedCompanion;

  final List<_CompanionItem> companions = const [
    _CompanionItem(
      name: '혼자',
      description: '나만의 속도로 즐기는 여행',
      icon: Icons.person_rounded,
    ),
    _CompanionItem(
      name: '친구',
      description: '함께 즐기는 자유로운 여행',
      icon: Icons.groups_rounded,
    ),
    _CompanionItem(
      name: '연인',
      description: '감성적인 데이트 여행',
      icon: Icons.favorite_rounded,
    ),
    _CompanionItem(
      name: '가족',
      description: '편안하고 안전한 가족 여행',
      icon: Icons.family_restroom_rounded,
    ),
    _CompanionItem(
      name: '부모님',
      description: '무리 없는 효도 여행',
      icon: Icons.elderly_rounded,
    ),
    _CompanionItem(
      name: '아이 동반',
      description: '아이와 함께하는 일정',
      icon: Icons.child_care_rounded,
    ),
    _CompanionItem(
      name: '직장동료',
      description: '함께 이동하기 좋은 일정',
      icon: Icons.business_center_rounded,
    ),
    _CompanionItem(
      name: '기타',
      description: '상황에 맞춰 직접 조정',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  void _goNext() {
    if (selectedCompanion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('동행자를 선택해주세요.'),
        ),
      );
      return;
    }

    context.go('/trip/theme');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(currentStep: 3),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TripStepIndicator(currentStep: 3),

                    const SizedBox(height: 34),

                    Text(
                      '누구와 함께\n여행하시나요?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '동행자 유형에 따라 이동 거리, 식사, 휴식 시간 등을 다르게 추천합니다.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 28),

                    ...companions.map(
                          (companion) {
                        final selected = selectedCompanion == companion.name;

                        return _CompanionCard(
                          companion: companion,
                          selected: selected,
                          onTap: () {
                            setState(() {
                              selectedCompanion = companion.name;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            TripBottomNavigation(
              onPrevious: () => context.go('/trip/region'),
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionCard extends StatelessWidget {
  final _CompanionItem companion;
  final bool selected;
  final VoidCallback onTap;

  const _CompanionCard({
    required this.companion,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    companion.icon,
                    color: color,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companion.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        companion.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                if (selected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanionItem {
  final String name;
  final String description;
  final IconData icon;

  const _CompanionItem({
    required this.name,
    required this.description,
    required this.icon,
  });
}