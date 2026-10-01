import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/trip_bottom_navigation.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_step_indicator.dart';

class TripThemePage extends StatefulWidget {
  const TripThemePage({
    super.key,
  });

  @override
  State<TripThemePage> createState() =>
      _TripThemePageState();
}

class _TripThemePageState extends State<TripThemePage> {
  static const int maxThemeSelection = 3;

  final Set<String> selectedThemes = {};

  // =========================================================
  // 여행 테마 목록
  //
  // 테마 항목 자체는 아직 최종 확정 전이므로
  // 현재 목록을 그대로 유지합니다.
  // =========================================================

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

  // =========================================================
  // 테마 선택 / 선택 해제
  //
  // 최대 3개까지 선택 가능하며,
  // 이미 선택한 항목을 다시 누르면 선택이 해제됩니다.
  // =========================================================

  void _toggleTheme(
      String theme,
      ) {
    if (selectedThemes.contains(theme)) {
      setState(() {
        selectedThemes.remove(theme);
      });

      return;
    }

    if (selectedThemes.length >= maxThemeSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '여행 테마는 최대 3개까지 선택할 수 있습니다.',
          ),
        ),
      );

      return;
    }

    setState(() {
      selectedThemes.add(theme);
    });
  }

  // =========================================================
  // 다음 단계 이동
  // 최소 1개의 테마는 선택해야 합니다.
  // =========================================================

  void _goNext() {
    if (selectedThemes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '여행 테마를 하나 이상 선택해주세요.',
          ),
        ),
      );

      return;
    }

    context.go(
      AppRoutes.tripTransport,
    );
  }

  // =========================================================
  // 화면 구성
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(
              currentStep: 7,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  20,
                  22,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const TripStepIndicator(
                      currentStep: 7,
                    ),

                    const SizedBox(
                      height: 34,
                    ),

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

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      '원하는 테마를 최대 3개까지 선택하면 AI가 취향에 맞는 장소를 조합합니다.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        color:
                        AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // =================================================
                    // 현재 선택한 테마 표시
                    // =================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        14,
                      ),
                      decoration: BoxDecoration(
                        color:
                        AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              selectedThemes.isEmpty
                                  ? '여행 테마를 선택해주세요.'
                                  : '선택한 테마: ${selectedThemes.join(', ')}',
                              style: TextStyle(
                                color:
                                selectedThemes.isEmpty
                                    ? AppColors
                                    .textSecondary
                                    : AppColors
                                    .primary,
                                fontWeight:
                                FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Text(
                            '${selectedThemes.length}/$maxThemeSelection',
                            style: const TextStyle(
                              color:
                              AppColors.primary,
                              fontWeight:
                              FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // =================================================
                    // 반응형 테마 카드 영역
                    //
                    // 일반적인 휴대폰 폭에서는 2열,
                    // 매우 좁은 화면에서는 1열로 전환합니다.
                    //
                    // GridView처럼 높이를 고정하지 않기 때문에
                    // 테마명이나 설명이 길어져도 카드가 자연스럽게
                    // 아래로 늘어납니다.
                    // =================================================

                    LayoutBuilder(
                      builder: (
                          context,
                          constraints,
                          ) {
                        const spacing = 14.0;

                        final availableWidth =
                            constraints.maxWidth;

                        final useSingleColumn =
                            availableWidth < 330;

                        final cardWidth =
                        useSingleColumn
                            ? availableWidth
                            : (availableWidth -
                            spacing) /
                            2;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final theme in themes)
                              SizedBox(
                                width: cardWidth,
                                child: _ThemeCard(
                                  theme: theme,
                                  selected:
                                  selectedThemes
                                      .contains(
                                    theme.name,
                                  ),
                                  onTap: () {
                                    _toggleTheme(
                                      theme.name,
                                    );
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            TripBottomNavigation(
              onPrevious: () {
                context.go(
                  AppRoutes.tripCompanion,
                );
              },
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// 개별 테마 카드
//
// 카드 폭을 기준으로 아이콘과 글자 크기를 조절하며,
// 텍스트 길이에 따라 카드 높이가 자동으로 늘어납니다.
// ===========================================================

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
  Widget build(
      BuildContext context,
      ) {
    final color =
    selected
        ? AppColors.primary
        : AppColors.textSecondary;

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        // 카드 폭에 따라 내부 요소 크기를 조금씩 조정
        final compact =
            constraints.maxWidth < 160;

        final cardPadding =
        compact ? 14.0 : 18.0;

        final iconBoxSize =
        compact ? 46.0 : 52.0;

        final iconSize =
        compact ? 26.0 : 30.0;

        final titleSize =
        compact ? 17.0 : 19.0;

        return Material(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(
            24,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius:
            BorderRadius.circular(
              24,
            ),
            child: AnimatedContainer(
              duration:
              const Duration(
                milliseconds: 180,
              ),
              width: double.infinity,

              // 카드 높이를 고정하지 않고 최소 높이만 지정
              constraints:
              const BoxConstraints(
                minHeight: 190,
              ),

              padding:
              EdgeInsets.all(
                cardPadding,
              ),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(
                  24,
                ),
                border: Border.all(
                  color:
                  selected
                      ? AppColors.primary
                      : AppColors.border,
                  width:
                  selected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    selected
                        ? AppColors.primary
                        .withValues(
                      alpha: 0.12,
                    )
                        : Colors.black
                        .withValues(
                      alpha: 0.04,
                    ),
                    blurRadius: 18,
                    offset:
                    const Offset(
                      0,
                      8,
                    ),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // =============================================
                      // 테마 아이콘
                      // =============================================

                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration:
                        BoxDecoration(
                          color:
                          color.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                        ),
                        child: Icon(
                          theme.icon,
                          color: color,
                          size: iconSize,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // =============================================
                      // 테마 이름
                      //
                      // maxLines를 강제하지 않아서
                      // 긴 이름도 자연스럽게 줄바꿈됩니다.
                      // =============================================

                      Padding(
                        padding:
                        const EdgeInsets.only(
                          right: 22,
                        ),
                        child: Text(
                          theme.name,
                          softWrap: true,
                          style: TextStyle(
                            fontSize:
                            titleSize,
                            height: 1.2,
                            fontWeight:
                            FontWeight.w900,
                            color:
                            selected
                                ? AppColors
                                .primary
                                : AppColors
                                .textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // =============================================
                      // 테마 설명
                      // 설명이 길어져도 자동 줄바꿈
                      // =============================================

                      Text(
                        theme.description,
                        softWrap: true,
                        style:
                        Theme.of(
                          context,
                        )
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color:
                          AppColors
                              .textSecondary,
                          height: 1.4,
                          fontSize:
                          compact
                              ? 12.5
                              : null,
                        ),
                      ),
                    ],
                  ),

                  // =============================================
                  // 선택 상태 체크 표시
                  // =============================================

                  if (selected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width:
                        compact
                            ? 26
                            : 28,
                        height:
                        compact
                            ? 26
                            : 28,
                        decoration:
                        const BoxDecoration(
                          color:
                          AppColors.primary,
                          shape:
                          BoxShape.circle,
                        ),
                        child: Icon(
                          Icons
                              .check_rounded,
                          color:
                          Colors.white,
                          size:
                          compact
                              ? 17
                              : 19,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================
// 테마 데이터 모델
// ===========================================================

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