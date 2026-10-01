import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/trip_bottom_navigation.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_step_indicator.dart';

class TripRegionPage extends StatefulWidget {
  const TripRegionPage({
    super.key,
  });

  @override
  State<TripRegionPage> createState() =>
      _TripRegionPageState();
}

class _TripRegionPageState
    extends State<TripRegionPage> {
  // =========================================================
  // 일본의 전체 도도부현은 47개이므로 최대 47개까지 선택 가능
  // =========================================================

  static const int maxSelectedRegions = 47;

  final Set<String> selectedRegions = {};

  // =========================================================
  // 일본 9개 권역 + 47개 도도부현
  //
  // 기존의 대표도시 목록 대신 각 권역에 실제로 속하는
  // 도도부현을 표시합니다.
  // =========================================================

  final List<_RegionGroup> regionGroups = const [
    _RegionGroup(
      name: '홋카이도',
      description: '일본 최북단에 위치한 홋카이도 지역',
      prefectures: [
        '홋카이도',
      ],
    ),

    _RegionGroup(
      name: '도호쿠',
      description: '일본 혼슈 북동부에 위치한 도호쿠 지역',
      prefectures: [
        '아오모리',
        '이와테',
        '미야기',
        '아키타',
        '야마가타',
        '후쿠시마',
      ],
    ),

    _RegionGroup(
      name: '간토',
      description: '도쿄를 중심으로 한 일본 수도권 지역',
      prefectures: [
        '도쿄',
        '가나가와',
        '사이타마',
        '치바',
        '이바라키',
        '도치기',
        '군마',
      ],
    ),

    _RegionGroup(
      name: '주부',
      description: '일본 혼슈 중앙부에 위치한 주부 지역',
      prefectures: [
        '니가타',
        '도야마',
        '이시카와',
        '후쿠이',
        '야마나시',
        '나가노',
        '기후',
        '시즈오카',
        '아이치',
      ],
    ),

    _RegionGroup(
      name: '간사이(긴키)',
      description: '오사카와 교토를 중심으로 한 간사이 지역',
      prefectures: [
        '미에',
        '시가',
        '교토',
        '오사카',
        '효고',
        '나라',
        '와카야마',
      ],
    ),

    _RegionGroup(
      name: '주고쿠',
      description: '혼슈 서부에 위치한 주고쿠 지역',
      prefectures: [
        '돗토리',
        '시마네',
        '오카야마',
        '히로시마',
        '야마구치',
      ],
    ),

    _RegionGroup(
      name: '시코쿠',
      description: '일본의 네 주요 섬 중 하나인 시코쿠 지역',
      prefectures: [
        '도쿠시마',
        '가가와',
        '에히메',
        '고치',
      ],
    ),

    _RegionGroup(
      name: '규슈',
      description: '일본 남서부에 위치한 규슈 지역',
      prefectures: [
        '후쿠오카',
        '사가',
        '나가사키',
        '구마모토',
        '오이타',
        '미야자키',
        '가고시마',
      ],
    ),

    _RegionGroup(
      name: '오키나와',
      description: '일본 최남단의 섬 지역인 오키나와',
      prefectures: [
        '오키나와',
      ],
    ),
  ];

  // =========================================================
  // 도도부현 선택 / 선택 해제
  // =========================================================

  void _toggleRegion(
      String region,
      ) {
    if (selectedRegions.contains(region)) {
      setState(() {
        selectedRegions.remove(region);
      });

      return;
    }

    if (selectedRegions.length >=
        maxSelectedRegions) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '지역은 최대 47개까지 선택할 수 있습니다.',
          ),
        ),
      );

      return;
    }

    setState(() {
      selectedRegions.add(region);
    });
  }

  // =========================================================
  // 하단 선택 목록에서 개별 지역 삭제
  // =========================================================

  void _removeRegion(
      String region,
      ) {
    setState(() {
      selectedRegions.remove(region);
    });
  }

  // =========================================================
  // 페이지 이동
  // =========================================================

  void _goPrevious() {
    context.go(
      AppRoutes.tripEntryExit,
    );
  }

  void _goNext() {
    // 여행 지역은 최소 1개 이상 선택해야 함
    if (selectedRegions.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '여행할 지역을 하나 이상 선택해주세요.',
          ),
        ),
      );

      return;
    }

    context.go(
      AppRoutes.tripAccommodation,
    );
  }

  // =========================================================
  // 화면 구성
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final selectedList =
    selectedRegions.toList();

    return Scaffold(
      backgroundColor:
      AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(
              currentStep: 3,
            ),

            Expanded(
              child:
              SingleChildScrollView(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  22,
                  20,
                  22,
                  22,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const TripStepIndicator(
                      currentStep: 3,
                    ),

                    const SizedBox(
                      height: 34,
                    ),

                    Text(
                      '어느 지역으로\n떠나시나요?',
                      style:
                      Theme.of(
                        context,
                      )
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight
                            .w900,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      '여행하고 싶은 권역을 열어 도도부현을 하나 이상 선택해주세요.',
                      style:
                      Theme.of(
                        context,
                      )
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        color:
                        AppColors
                            .textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // 9개 권역별 도도부현 목록
                    ...regionGroups.map(
                          (group) =>
                          Padding(
                            padding:
                            const EdgeInsets
                                .only(
                              bottom: 12,
                            ),
                            child:
                            _RegionExpansionCard(
                              group:
                              group,
                              selectedRegions:
                              selectedRegions,
                              onToggleRegion:
                              _toggleRegion,
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // =================================================
            // 현재 선택된 도도부현 목록
            // =================================================

            Padding(
              padding:
              const EdgeInsets
                  .fromLTRB(
                22,
                10,
                22,
                10,
              ),
              child:
              _SelectedRegionBox(
                selectedRegions:
                selectedList,
                onRemove:
                _removeRegion,
              ),
            ),

            TripBottomNavigation(
              onPrevious:
              _goPrevious,
              onNext:
              _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// 선택된 도도부현 하단 표시 영역
//
// 선택된 지역을 Chip 형태로 보여주며
// 각 Chip의 X 버튼을 눌러 개별 삭제할 수 있습니다.
// ===========================================================

class _SelectedRegionBox
    extends StatelessWidget {
  final List<String> selectedRegions;

  final ValueChanged<String>
  onRemove;

  const _SelectedRegionBox({
    required this.selectedRegions,
    required this.onRemove,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets
          .fromLTRB(
        16,
        13,
        16,
        13,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        border:
        Border.all(
          color:
          AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withValues(
              alpha: 0.06,
            ),
            blurRadius: 14,
            offset:
            const Offset(
              0,
              -2,
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .check_circle_rounded,
                color:
                AppColors.primary,
                size: 21,
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                '선택한 지역',
                style:
                Theme.of(
                  context,
                )
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  fontWeight:
                  FontWeight
                      .w900,
                ),
              ),

              const Spacer(),

              Text(
                '${selectedRegions.length}개',
                style:
                const TextStyle(
                  color:
                  AppColors
                      .primary,
                  fontWeight:
                  FontWeight
                      .w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          if (selectedRegions
              .isEmpty)
            const Text(
              '아직 선택한 지역이 없습니다.',
              style:
              TextStyle(
                color:
                AppColors
                    .textSecondary,
                fontWeight:
                FontWeight
                    .w700,
              ),
            )
          else
            SizedBox(
              height: 40,
              child:
              ListView.separated(
                scrollDirection:
                Axis.horizontal,
                itemCount:
                selectedRegions
                    .length,
                separatorBuilder:
                    (_, __) =>
                const SizedBox(
                  width: 8,
                ),
                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final region =
                  selectedRegions[
                  index];

                  return InputChip(
                    label: Text(
                      region,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),
                    onDeleted:
                        () {
                      onRemove(
                        region,
                      );
                    },
                    deleteIcon:
                    const Icon(
                      Icons
                          .close_rounded,
                      size: 18,
                    ),
                    backgroundColor:
                    const Color(
                      0xFFEFF6FF,
                    ),
                    side:
                    const BorderSide(
                      color:
                      Color(
                        0xFFBFDBFE,
                      ),
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

// ===========================================================
// 권역별 도도부현 펼침 카드
//
// 예:
// 간토
// ├ 도쿄
// ├ 가나가와
// ├ 사이타마
// └ ...
//
// 각 도도부현을 개별 선택 / 해제할 수 있습니다.
// ===========================================================

class _RegionExpansionCard
    extends StatelessWidget {
  final _RegionGroup group;

  final Set<String>
  selectedRegions;

  final ValueChanged<String>
  onToggleRegion;

  const _RegionExpansionCard({
    required this.group,
    required this.selectedRegions,
    required this.onToggleRegion,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    // 해당 권역에서 현재 몇 개의 도도부현을
    // 선택했는지 계산
    final selectedCount =
        group.prefectures
            .where(
              (prefecture) =>
              selectedRegions
                  .contains(
                prefecture,
              ),
        )
            .length;

    return Container(
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border:
        Border.all(
          color:
          AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withValues(
              alpha: 0.03,
            ),
            blurRadius: 14,
            offset:
            const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Theme(
        data:
        Theme.of(
          context,
        ).copyWith(
          dividerColor:
          Colors.transparent,
        ),
        child:
        ExpansionTile(
          tilePadding:
          const EdgeInsets
              .symmetric(
            horizontal: 18,
            vertical: 6,
          ),

          childrenPadding:
          const EdgeInsets
              .fromLTRB(
            8,
            0,
            8,
            12,
          ),

          title: Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight
                        .w900,
                    fontSize: 17,
                    color:
                    AppColors
                        .textPrimary,
                  ),
                ),
              ),

              // 해당 권역에서 선택된 개수 표시
              if (selectedCount >
                  0)
                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFEFF6FF,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      999,
                    ),
                  ),
                  child: Text(
                    '$selectedCount개 선택',
                    style:
                    const TextStyle(
                      color:
                      AppColors
                          .primary,
                      fontSize: 12,
                      fontWeight:
                      FontWeight
                          .w900,
                    ),
                  ),
                ),
            ],
          ),

          subtitle: Padding(
            padding:
            const EdgeInsets
                .only(
              top: 4,
            ),
            child: Text(
              group.description,
              style:
              const TextStyle(
                color:
                AppColors
                    .textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),

          // 각 권역에 속한 도도부현
          children:
          group.prefectures
              .map(
                (
                prefecture,
                ) {
              final selected =
              selectedRegions
                  .contains(
                prefecture,
              );

              return CheckboxListTile(
                value:
                selected,

                onChanged:
                    (_) {
                  onToggleRegion(
                    prefecture,
                  );
                },

                dense:
                true,

                activeColor:
                AppColors.primary,

                controlAffinity:
                ListTileControlAffinity
                    .leading,

                title: Text(
                  prefecture,
                  style:
                  TextStyle(
                    fontWeight:
                    selected
                        ? FontWeight
                        .w900
                        : FontWeight
                        .w700,
                    color:
                    selected
                        ? AppColors
                        .primary
                        : AppColors
                        .textPrimary,
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

// ===========================================================
// 권역 데이터 모델
// ===========================================================

class _RegionGroup {
  final String name;
  final String description;

  final List<String>
  prefectures;

  const _RegionGroup({
    required this.name,
    required this.description,
    required this.prefectures,
  });
}