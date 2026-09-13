import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/trip_step_indicator.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_bottom_navigation.dart';

class TripThemePage extends StatefulWidget {
  const TripThemePage({super.key});

  @override
  State<TripThemePage> createState() => _TripThemePageState();
}

class _TripThemePageState extends State<TripThemePage> {
  static const int maxThemeSelection = 3;

  final Set<String> selectedThemes = {};

  final List<_ThemeItem> themes = const [
    _ThemeItem(
      name: '맛집',
      description: '현지 음식과 인기 맛집 탐방',
      icon: Icons.restaurant_rounded,
    ),
    _ThemeItem(
      name: '쇼핑',
      description: '상점가, 백화점, 기념품 쇼핑',
      icon: Icons.shopping_bag_rounded,
    ),
    _ThemeItem(
      name: '관광',
      description: '대표 명소와 유명 관광지 방문',
      icon: Icons.location_city_rounded,
    ),
    _ThemeItem(
      name: '힐링',
      description: '여유로운 산책과 편안한 휴식',
      icon: Icons.spa_rounded,
    ),
    _ThemeItem(
      name: '사진',
      description: '사진 명소와 감성적인 장소',
      icon: Icons.photo_camera_rounded,
    ),
    _ThemeItem(
      name: '애니메이션',
      description: '애니메이션, 캐릭터, 굿즈 명소',
      icon: Icons.animation_rounded,
    ),
    _ThemeItem(
      name: '문화',
      description: '사찰, 박물관, 전통 문화 체험',
      icon: Icons.temple_buddhist_rounded,
    ),
    _ThemeItem(
      name: '자연',
      description: '공원, 바다, 산 등 자연 명소',
      icon: Icons.park_rounded,
    ),
    _ThemeItem(
      name: '야경',
      description: '전망대와 야경 명소 감상',
      icon: Icons.nightlight_round,
    ),
    _ThemeItem(
      name: '온천',
      description: '온천과 료칸에서 즐기는 휴식',
      icon: Icons.hot_tub_rounded,
    ),
    _ThemeItem(
      name: '액티비티',
      description: '체험, 놀이공원, 활동 중심 여행',
      icon: Icons.local_activity_rounded,
    ),
    _ThemeItem(
      name: '카페',
      description: '카페 탐방과 디저트 즐기기',
      icon: Icons.local_cafe_rounded,
    ),
  ];

  void _goNext() {
    if (selectedThemes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행 테마를 하나 이상 선택해주세요.'),
        ),
      );
      return;
    }

    context.go(AppRoutes.tripTransport);
  }

  void _toggleTheme(String theme) {
    if (selectedThemes.contains(theme)) {
      setState(() {
        selectedThemes.remove(theme);
      });
      return;
    }

    if (selectedThemes.length >= maxThemeSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행 테마는 최대 3개까지 선택할 수 있습니다.'),
        ),
      );
      return;
    }

    setState(() {
      selectedThemes.add(theme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(currentStep: 7),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TripStepIndicator(currentStep: 7),

                    const SizedBox(height: 34),

                    Text(
                      '어떤 여행을\n원하시나요?',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '원하는 테마를 최대 3개까지 선택하면 AI가 취향에 맞는 장소를 조합합니다.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedThemes.isEmpty
                                  ? '여행 테마를 선택해주세요.'
                                  : '선택한 테마: ${selectedThemes.join(', ')}',
                              style: TextStyle(
                                color: selectedThemes.isEmpty
                                    ? AppColors.textSecondary
                                    : AppColors.primary,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedThemes.length}/$maxThemeSelection',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: themes.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.92,
                      ),
                      itemBuilder: (context, index) {
                        final theme = themes[index];
                        final selected = selectedThemes.contains(theme.name);

                        return _ThemeCard(
                          theme: theme,
                          selected: selected,
                          onTap: () => _toggleTheme(theme.name),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            TripBottomNavigation(
              onPrevious: () => context.go(AppRoutes.tripCompanion),
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final _ThemeItem theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      theme.icon,
                      color: color,
                      size: 30,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    theme.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    theme.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeItem {
  final String name;
  final String description;
  final IconData icon;

  const _ThemeItem({
    required this.name,
    required this.description,
    required this.icon,
  });
}
