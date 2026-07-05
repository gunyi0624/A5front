import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_page_header.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emergencyBackground,
      endDrawer: const AppDrawer(currentRoute: AppRoutes.emergency),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPageHeader(
                    title: '긴급 시설 위치 안내',
                    onMenuTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    '현재 위치 기준 5km 이내의\n긴급 시설을 확인하세요.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '응급상황 시 가까운 병원, 약국, 경찰서, 대사관 정보를 빠르게 확인할 수 있습니다.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 22),

                  _FilterChips(),

                  const SizedBox(height: 18),

                  _MapPreview(),

                  const SizedBox(height: 20),

                  Text(
                    '주변 긴급 시설',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const _FacilityCard(
                    icon: Icons.local_hospital_rounded,
                    title: '도쿄 중앙 병원',
                    category: '병원',
                    distance: '1.2km',
                    address: '도쿄도 치요다구 주변',
                    phone: '+81-3-0000-0000',
                  ),

                  const _FacilityCard(
                    icon: Icons.local_pharmacy_rounded,
                    title: '24시 약국',
                    category: '약국',
                    distance: '850m',
                    address: '도쿄역 인근',
                    phone: '+81-3-1111-1111',
                  ),

                  const _FacilityCard(
                    icon: Icons.local_police_rounded,
                    title: '마루노우치 경찰서',
                    category: '경찰서',
                    distance: '1.8km',
                    address: '도쿄도 치요다구 마루노우치',
                    phone: '110',
                  ),

                  const _FacilityCard(
                    icon: Icons.account_balance_rounded,
                    title: '대한민국 대사관',
                    category: '대사관',
                    distance: '4.6km',
                    address: '도쿄도 미나토구 주변',
                    phone: '+81-3-3452-7611',
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

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final filters = [
      '전체',
      '병원',
      '약국',
      '경찰서',
      '대사관',
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == 0;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.emergency : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? AppColors.emergency : AppColors.border,
              ),
            ),
            child: Text(
              filters[index],
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3E3),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFFC9C9),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),

          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.emergency.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.emergency.withOpacity(0.35),
                  width: 2,
                ),
              ),
            ),
          ),

          const Center(
            child: Icon(
              Icons.my_location_rounded,
              color: AppColors.emergency,
              size: 36,
            ),
          ),

          const Positioned(
            top: 42,
            left: 58,
            child: _MapMarker(
              icon: Icons.local_hospital_rounded,
              label: '병원',
            ),
          ),

          const Positioned(
            right: 52,
            top: 78,
            child: _MapMarker(
              icon: Icons.local_pharmacy_rounded,
              label: '약국',
            ),
          ),

          const Positioned(
            left: 74,
            bottom: 56,
            child: _MapMarker(
              icon: Icons.local_police_rounded,
              label: '경찰',
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.radio_button_checked_rounded,
                    color: AppColors.emergency,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '현재 위치 기준 반경 5km',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MapMarker({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.emergency.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.emergency,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.emergency,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String category;
  final String distance;
  final String address;
  final String phone;

  const _FacilityCard({
    required this.icon,
    required this.title,
    required this.category,
    required this.distance,
    required this.address,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: AppColors.emergency.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: AppColors.emergency,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      distance,
                      style: const TextStyle(
                        color: AppColors.emergency,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  '$category · $address',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call_rounded, size: 18),
                        label: Text(phone),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.emergency,
                          side: const BorderSide(color: AppColors.emergency),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    SizedBox(
                      height: 40,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.emergency,
                          minimumSize: const Size(82, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          '길찾기',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final thinRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.38)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (double y = 35; y < size.height; y += 48) {
      canvas.drawLine(
        Offset(12, y),
        Offset(size.width - 12, y + 18),
        thinRoadPaint,
      );
    }

    for (double x = 30; x < size.width; x += 58) {
      canvas.drawLine(
        Offset(x, 10),
        Offset(x - 16, size.height - 10),
        thinRoadPaint,
      );
    }

    canvas.drawLine(
      Offset(20, size.height * 0.68),
      Offset(size.width - 22, size.height * 0.28),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.25, 18),
      Offset(size.width * 0.72, size.height - 18),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
