import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/trip_step_indicator.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_bottom_navigation.dart';

class TripTransportPage extends StatefulWidget {
  const TripTransportPage({super.key});

  @override
  State<TripTransportPage> createState() => _TripTransportPageState();
}

class _TripTransportPageState extends State<TripTransportPage> {
  String? selectedTransport;

  final List<_TransportItem> transports = const [
    _TransportItem(
      name: '도보 및 대중교통',
      description: '지하철, 버스, 도보를 중심으로 효율적인 동선을 추천합니다.',
      icon: Icons.directions_transit_rounded,
    ),
    _TransportItem(
      name: '차량 렌트',
      description: '렌터카 이동을 고려해 주차와 이동 거리를 반영합니다.',
      icon: Icons.directions_car_filled_rounded,
    ),
  ];

  void _goNext() {
    if (selectedTransport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주요 이동수단을 선택해주세요.'),
        ),
      );
      return;
    }

    context.go('/trip/fixed-schedule');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(currentStep: 5),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TripStepIndicator(currentStep: 5),

                    const SizedBox(height: 34),

                    Text(
                      '어떻게 이동할\n예정인가요?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '주요 이동수단에 따라 이동 시간, 동선, 휴식 시간을 다르게 계산합니다.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 32),

                    ...transports.map(
                          (transport) {
                        final selected = selectedTransport == transport.name;

                        return _TransportCard(
                          transport: transport,
                          selected: selected,
                          onTap: () {
                            setState(() {
                              selectedTransport = transport.name;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '차량 렌트를 선택한 경우 국제운전면허증 준비 여부를 반드시 확인하세요.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
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

            TripBottomNavigation(
              onPrevious: () => context.go('/trip/theme'),
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransportCard extends StatelessWidget {
  final _TransportItem transport;
  final bool selected;
  final VoidCallback onTap;

  const _TransportCard({
    required this.transport,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    transport.icon,
                    color: color,
                    size: 38,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transport.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transport.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                if (selected)
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
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

class _TransportItem {
  final String name;
  final String description;
  final IconData icon;

  const _TransportItem({
    required this.name,
    required this.description,
    required this.icon,
  });
}