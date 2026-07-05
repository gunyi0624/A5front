import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/trip_step_indicator.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_bottom_navigation.dart';

class TripRegionPage extends StatefulWidget {
  const TripRegionPage({super.key});

  @override
  State<TripRegionPage> createState() => _TripRegionPageState();
}

class _TripRegionPageState extends State<TripRegionPage> {
  String? selectedRegion;

  final List<_RegionItem> regions = const [
    _RegionItem(
      name: '도쿄',
      description: '쇼핑, 맛집, 도시 관광',
      icon: Icons.location_city_rounded,
    ),
    _RegionItem(
      name: '오사카',
      description: '먹거리, 유니버설, 활기찬 거리',
      icon: Icons.ramen_dining_rounded,
    ),
    _RegionItem(
      name: '교토',
      description: '전통, 사찰, 감성 여행',
      icon: Icons.temple_buddhist_rounded,
    ),
    _RegionItem(
      name: '후쿠오카',
      description: '가까운 거리, 맛집, 온천',
      icon: Icons.spa_rounded,
    ),
    _RegionItem(
      name: '삿포로',
      description: '눈, 자연, 겨울 여행',
      icon: Icons.ac_unit_rounded,
    ),
    _RegionItem(
      name: '오키나와',
      description: '바다, 휴양, 액티비티',
      icon: Icons.beach_access_rounded,
    ),
  ];

  void _goNext() {
    if (selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행 지역을 선택해주세요.'),
        ),
      );
      return;
    }

    context.go('/trip/companion');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(currentStep: 2),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TripStepIndicator(currentStep: 2),

                    const SizedBox(height: 34),

                    Text(
                      '어느 지역으로\n떠나시나요?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '여행할 일본 도시를 선택하면 해당 지역에 맞는 장소와 동선을 추천합니다.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 28),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: regions.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.92,
                      ),
                      itemBuilder: (context, index) {
                        final region = regions[index];
                        final selected = selectedRegion == region.name;

                        return _RegionCard(
                          region: region,
                          selected: selected,
                          onTap: () {
                            setState(() {
                              selectedRegion = region.name;
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
              onPrevious: () => context.go('/trip/period'),
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  final _RegionItem region;
  final bool selected;
  final VoidCallback onTap;

  const _RegionCard({
    required this.region,
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
                      region.icon,
                      color: color,
                      size: 30,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    region.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    region.description,
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

class _RegionItem {
  final String name;
  final String description;
  final IconData icon;

  const _RegionItem({
    required this.name,
    required this.description,
    required this.icon,
  });
}