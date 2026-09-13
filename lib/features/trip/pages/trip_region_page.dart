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
  static const int maxSelectedRegions = 50;

  final Set<String> selectedRegions = {};
  final TextEditingController searchController = TextEditingController();

  final List<_RegionGroup> regionGroups = const [
    _RegionGroup(
      name: '홋카이도',
      description: '삿포로, 오타루, 하코다테 등 홋카이도 주요 여행 도시',
      cities: [
        '삿포로',
        '오타루',
        '하코다테',
        '아사히카와',
        '후라노',
      ],
    ),
    _RegionGroup(
      name: '도호쿠',
      description: '센다이, 아오모리 등 일본 북동부의 주요 여행 도시',
      cities: [
        '센다이',
        '아오모리',
        '히로사키',
        '모리오카',
        '야마가타',
        '아이즈와카마쓰',
      ],
    ),
    _RegionGroup(
      name: '간토',
      description: '도쿄, 요코하마 등 수도권 중심의 주요 여행 도시',
      cities: [
        '도쿄',
        '요코하마',
        '가마쿠라',
        '닛코',
        '가와고에',
        '지바',
      ],
    ),
    _RegionGroup(
      name: '주부',
      description: '나고야, 가나자와 등 일본 중부의 주요 여행 도시',
      cities: [
        '나고야',
        '가나자와',
        '다카야마',
        '마쓰모토',
        '시즈오카',
        '니가타',
      ],
    ),
    _RegionGroup(
      name: '간사이',
      description: '오사카, 교토, 고베 등 인기 여행 도시',
      cities: [
        '오사카',
        '교토',
        '고베',
        '나라',
        '히메지',
        '와카야마',
      ],
    ),
    _RegionGroup(
      name: '주고쿠',
      description: '히로시마, 오카야마 등 서일본의 주요 여행 도시',
      cities: [
        '히로시마',
        '오카야마',
        '구라시키',
        '돗토리',
        '마쓰에',
        '시모노세키',
      ],
    ),
    _RegionGroup(
      name: '시코쿠',
      description: '마쓰야마, 다카마쓰 등 시코쿠의 주요 여행 도시',
      cities: [
        '마쓰야마',
        '다카마쓰',
        '고치',
        '도쿠시마',
        '나루토',
      ],
    ),
    _RegionGroup(
      name: '규슈',
      description: '후쿠오카, 나가사키 등 규슈의 주요 여행 도시',
      cities: [
        '후쿠오카',
        '나가사키',
        '구마모토',
        '벳푸',
        '가고시마',
      ],
    ),
    _RegionGroup(
      name: '오키나와',
      description: '나하, 이시가키 등 오키나와의 주요 여행 도시',
      cities: [
        '나하',
        '이시가키',
        '미야코지마',
        '나고',
        '오키나와',
      ],
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _toggleRegion(String region) {
    if (selectedRegions.contains(region)) {
      setState(() {
        selectedRegions.remove(region);
      });
      return;
    }

    if (selectedRegions.length >= maxSelectedRegions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지역은 최대 50개까지 선택할 수 있습니다.'),
        ),
      );
      return;
    }

    setState(() {
      selectedRegions.add(region);
    });
  }

  void _removeRegion(String region) {
    setState(() {
      selectedRegions.remove(region);
    });
  }

  void _searchRegion() {
    final keyword = searchController.text.trim();

    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('검색할 도시 또는 지역을 입력해주세요.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google 지도 검색은 API 연결 단계에서 활성화됩니다.'),
      ),
    );
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
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
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
                      '대표도시를 선택하거나 검색을 통해 원하는 여행 지역을 추가할 수 있습니다.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _RegionSearchBar(
                      controller: searchController,
                      onSearch: _searchRegion,
                    ),

                    const SizedBox(height: 22),

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

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
              child: _SelectedRegionBox(
                selectedRegions: selectedList,
                onRemove: _removeRegion,
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

class _RegionSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _RegionSearchBar({
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          hintText: '도시 또는 지역 검색',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          suffixIcon: IconButton(
            onPressed: onSearch,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
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
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 21,
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

          const SizedBox(height: 10),

          if (selectedRegions.isEmpty)
            const Text(
              '아직 선택한 지역이 없습니다.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: selectedRegions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final region = selectedRegions[index];

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
                },
              ),
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
    final selectedCount = group.cities
        .where((city) => selectedRegions.contains(city))
        .length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
          children: group.cities.map((city) {
            final selected = selectedRegions.contains(city);

            return CheckboxListTile(
              value: selected,
              onChanged: (_) => onToggleRegion(city),
              dense: true,
              activeColor: AppColors.primary,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                city,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color:
                  selected ? AppColors.primary : AppColors.textPrimary,
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
  final List<String> cities;

  const _RegionGroup({
    required this.name,
    required this.description,
    required this.cities,
  });
}