import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/trip_step_indicator.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_bottom_navigation.dart';
import '../../../core/router/app_router.dart';

class TripRegionPage extends StatefulWidget {
  const TripRegionPage({super.key});

  @override
  State<TripRegionPage> createState() => _TripRegionPageState();
}

class _TripRegionPageState extends State<TripRegionPage> {
  final Set<String> selectedRegions = {};

  final List<_RegionGroup> regionGroups = const [
    _RegionGroup(
      name: '홋카이도',
      description: '삿포로, 오타루, 하코다테 등 북해도 여행 지역',
      prefectures: [
        '홋카이도',
      ],
    ),
    _RegionGroup(
      name: '도호쿠',
      description: '아오모리, 센다이 등 일본 북동부 지역',
      prefectures: [
        '미야기',
        '아오모리',
        '이와테',
        '아키타',
        '야마가타',
        '후쿠시마',
      ],
    ),
    _RegionGroup(
      name: '간토',
      description: '도쿄, 요코하마 등 수도권 중심 지역',
      prefectures: [
        '도쿄',
        '가나가와',
        '지바',
        '사이타마',
        '이바라키',
        '도치기',
        '군마',
      ],
    ),
    _RegionGroup(
      name: '주부',
      description: '나고야, 시즈오카, 나가노 등 일본 중부 지역',
      prefectures: [
        '아이치',
        '시즈오카',
        '나가노',
        '야마나시',
        '기후',
        '니가타',
        '도야마',
        '이시카와',
        '후쿠이',
      ],
    ),
    _RegionGroup(
      name: '간사이',
      description: '오사카, 교토, 고베, 나라 중심의 인기 여행 지역',
      prefectures: [
        '오사카',
        '교토',
        '효고',
        '나라',
        '시가',
        '와카야마',
        '미에',
      ],
    ),
    _RegionGroup(
      name: '주고쿠',
      description: '히로시마, 오카야마, 돗토리 등 서일본 지역',
      prefectures: [
        '히로시마',
        '오카야마',
        '야마구치',
        '돗토리',
        '시마네',
      ],
    ),
    _RegionGroup(
      name: '시코쿠',
      description: '가가와, 에히메 등 조용한 로컬 여행 지역',
      prefectures: [
        '가가와',
        '에히메',
        '도쿠시마',
        '고치',
      ],
    ),
    _RegionGroup(
      name: '규슈·오키나와',
      description: '후쿠오카, 나가사키, 오키나와 등 남부 여행 지역',
      prefectures: [
        '후쿠오카',
        '오키나와',
        '구마모토',
        '나가사키',
        '오이타',
        '가고시마',
        '미야자키',
        '사가',
      ],
    ),
  ];

  void _toggleRegion(String region) {
    setState(() {
      if (selectedRegions.contains(region)) {
        selectedRegions.remove(region);
      } else {
        selectedRegions.add(region);
      }
    });
  }

  void _removeRegion(String region) {
    setState(() {
      selectedRegions.remove(region);
    });
  }

  void _goPrevious() {
    context.go(AppRoutes.tripFixedSchedule);
  }

  void _goNext() {
    if (selectedRegions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행할 지역을 하나 이상 선택해주세요.'),
        ),
      );
      return;
    }

    context.go(AppRoutes.tripCompanion);
  }

  @override
  Widget build(BuildContext context) {
    final selectedList = selectedRegions.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(currentStep: 4),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TripStepIndicator(currentStep: 4),

                    const SizedBox(height: 34),

                    Text(
                      '어느 지역으로\n떠나시나요?',
                      style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '여행할 도도부현을 여러 개 선택하면 선택한 지역에 맞는 장소와 동선을 추천합니다.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _SelectedRegionBox(
                      selectedRegions: selectedList,
                      onRemove: _removeRegion,
                    ),

                    const SizedBox(height: 20),

                    ...regionGroups.map(
                          (group) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RegionExpansionCard(
                          group: group,
                          selectedRegions: selectedRegions,
                          onToggleRegion: _toggleRegion,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            TripBottomNavigation(
              onPrevious: _goPrevious,
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedRegionBox extends StatelessWidget {
  final List<String> selectedRegions;
  final ValueChanged<String> onRemove;

  const _SelectedRegionBox({
    required this.selectedRegions,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 23,
              ),
              const SizedBox(width: 8),
              Text(
                '선택한 지역',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${selectedRegions.length}개',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (selectedRegions.isEmpty)
            const Text(
              '아직 선택한 지역이 없습니다.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedRegions.map((region) {
                return InputChip(
                  label: Text(
                    region,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onDeleted: () => onRemove(region),
                  deleteIcon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                  ),
                  backgroundColor: const Color(0xFFEFF6FF),
                  side: const BorderSide(
                    color: Color(0xFFBFDBFE),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _RegionExpansionCard extends StatelessWidget {
  final _RegionGroup group;
  final Set<String> selectedRegions;
  final ValueChanged<String> onToggleRegion;

  const _RegionExpansionCard({
    required this.group,
    required this.selectedRegions,
    required this.onToggleRegion,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCount = group.prefectures
        .where((prefecture) => selectedRegions.contains(prefecture))
        .length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 6,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (selectedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$selectedCount개 선택',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              group.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          children: group.prefectures.map((prefecture) {
            final selected = selectedRegions.contains(prefecture);

            return CheckboxListTile(
              value: selected,
              onChanged: (_) => onToggleRegion(prefecture),
              dense: true,
              activeColor: AppColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                prefecture,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RegionGroup {
  final String name;
  final String description;
  final List<String> prefectures;

  const _RegionGroup({
    required this.name,
    required this.description,
    required this.prefectures,
  });
}