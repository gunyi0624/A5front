import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_confirm_dialog.dart';

class ItineraryResultPage extends StatefulWidget {
  const ItineraryResultPage({super.key});

  @override
  State<ItineraryResultPage> createState() => _ItineraryResultPageState();
}

class _ItineraryResultPageState extends State<ItineraryResultPage> {
  bool isSaved = false;

  final List<_ItineraryItem> items = [
    _ItineraryItem(
      time: '09:00',
      title: '도쿄역',
      description: '여행 시작 지점',
      category: '교통',
    ),
    _ItineraryItem(
      time: '10:00',
      title: '아사쿠사 센소지',
      description: '도쿄 대표 전통 사찰 관광',
      category: '관광',
    ),
    _ItineraryItem(
      time: '12:30',
      title: '우에노 맛집 거리',
      description: '현지 음식 중심 점심 식사',
      category: '식사',
    ),
    _ItineraryItem(
      time: '14:00',
      title: '우에노 공원',
      description: '산책과 휴식 중심 일정',
      category: '힐링',
    ),
    _ItineraryItem(
      time: '16:00',
      title: '아키하바라',
      description: '쇼핑 및 서브컬처 거리 탐방',
      category: '쇼핑',
    ),
  ];

  Future<bool> _handleBack() async {
    if (isSaved) {
      context.go('/schedule');
      return false;
    }

    final result = await showAppLeaveDialog(
      context: context,
      title: '일정을 저장하시겠습니까?',
      message: '저장하지 않으면 생성된 일정이 사라집니다.',
      saveText: '저장',
      discardText: '저장하지 않기',
      cancelText: '취소',
    );

    if (!mounted) return false;

    if (result == AppLeaveDialogResult.save) {
      setState(() {
        isSaved = true;
      });

      context.go('/schedule');
    } else if (result == AppLeaveDialogResult.discard) {
      context.go('/home');
    }

    return false;
  }

  void _saveSchedule() {
    setState(() {
      isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('일정이 저장되었습니다.'),
      ),
    );

    context.go('/schedule');
  }

  Future<void> _deleteItem(_ItineraryItem item) async {
    final result = await showAppConfirmDialog(
      context: context,
      title: '일정을 삭제하시겠습니까?',
      message: '${item.time} ${item.title} 일정이 삭제됩니다.',
      confirmText: '삭제',
      type: AppConfirmDialogType.danger,
    );

    if (!result) return;

    setState(() {
      items.remove(item);
      items.add(
        _ItineraryItem(
          time: item.time,
          title: '비어 있는 시간',
          description: '삭제된 일정입니다. 필요하면 새 장소를 추천받아 수정할 수 있습니다.',
          category: '공백',
          isEmpty: true,
        ),
      );

      items.sort((a, b) => a.time.compareTo(b.time));
      isSaved = false;
    });
  }

  void _showEditRecommendations(_ItineraryItem item) {
    final recommendations = [
      _Recommendation(
        title: '긴자 거리',
        description: '쇼핑과 카페를 함께 즐길 수 있는 지역',
        category: '쇼핑',
      ),
      _Recommendation(
        title: '스미다 공원',
        description: '가볍게 산책하기 좋은 강변 공원',
        category: '힐링',
      ),
      _Recommendation(
        title: '도쿄 국립박물관',
        description: '일본 문화와 역사를 볼 수 있는 박물관',
        category: '문화',
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.time} 대체 장소 추천',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '같은 시간대에 넣을 수 있는 장소를 선택하세요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                ...recommendations.map(
                      (recommendation) {
                    return _RecommendationCard(
                      recommendation: recommendation,
                      onTap: () {
                        setState(() {
                          final index = items.indexOf(item);
                          if (index != -1) {
                            items[index] = _ItineraryItem(
                              time: item.time,
                              title: recommendation.title,
                              description: recommendation.description,
                              category: recommendation.category,
                            );
                          }
                          isSaved = false;
                        });

                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showItemMenu(_ItineraryItem item) {
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
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI 대체 장소 추천',
                  onTap: () {
                    Navigator.pop(context);
                    _showEditRecommendations(item);
                  },
                ),
                _BottomSheetAction(
                  icon: Icons.delete_rounded,
                  label: '삭제',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    _deleteItem(item);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _regenerateSchedule() async {
    setState(() {
      isSaved = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI가 새로운 일정을 추천했습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: _handleBack,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI 일정 결과',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSaved
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isSaved ? '저장됨' : '저장 전',
                        style: TextStyle(
                          color: isSaved ? AppColors.success : const Color(0xFF9A6B00),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TripSummaryCard(),

                      const SizedBox(height: 22),

                      Text(
                        '1일차 일정',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ...items.map(
                            (item) => _TimelineItem(
                          item: item,
                          onMoreTap: () => _showItemMenu(item),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: _saveSchedule,
                      child: const Text('일정 저장'),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _regenerateSchedule,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          '다시 AI 추천받기',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '도쿄 여행',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '2026-07-02(목) · 3박 4일 · 식도락 / 쇼핑 / 힐링',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final _ItineraryItem item;
  final VoidCallback onMoreTap;

  const _TimelineItem({
    required this.item,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.isEmpty ? AppColors.textSecondary : AppColors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          child: Text(
            item.time,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),

        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 94,
              color: AppColors.border,
            ),
          ],
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item.isEmpty ? AppColors.background : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: item.isEmpty
                  ? Border.all(color: AppColors.border)
                  : null,
              boxShadow: item.isEmpty
                  ? null
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                        ),
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
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final _Recommendation recommendation;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.place_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${recommendation.category} · ${recommendation.description}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
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

class _ItineraryItem {
  final String time;
  final String title;
  final String description;
  final String category;
  final bool isEmpty;

  _ItineraryItem({
    required this.time,
    required this.title,
    required this.description,
    required this.category,
    this.isEmpty = false,
  });
}

class _Recommendation {
  final String title;
  final String description;
  final String category;

  _Recommendation({
    required this.title,
    required this.description,
    required this.category,
  });
}