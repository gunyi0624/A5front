import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/trip_bottom_navigation.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_step_indicator.dart';

/// Places 검색 결과를 연결할 때 카드의 표시와 장소 데이터를 함께 유지합니다.
class AccommodationPlace {
  final String name;
  final String? placeId;
  final String? address;
  final double? latitude;
  final double? longitude;

  const AccommodationPlace({
    required this.name,
    this.placeId,
    this.address,
    this.latitude,
    this.longitude,
  });
}

class TripAccommodationPage extends StatefulWidget {
  /// 추후 여행 기간 화면에서 전달할 날짜 범위입니다.
  final DateTimeRange? travelPeriod;

  const TripAccommodationPage({super.key, this.travelPeriod});

  @override
  State<TripAccommodationPage> createState() => _TripAccommodationPageState();
}

class _TripAccommodationPageState extends State<TripAccommodationPage> {
  final List<_AccommodationEntry> _accommodations = [];
  late final DateTime _defaultFirstDate;
  late final DateTime _defaultLastDate;

  @override
  void initState() {
    super.initState();
    _defaultFirstDate = DateUtils.dateOnly(DateTime.now());
    _defaultLastDate = DateTime(_defaultFirstDate.year + 2);
  }

  Future<void> _pickDate(
    _AccommodationEntry entry, {
    required bool isStart,
  }) async {
    final firstDate = DateUtils.dateOnly(
      widget.travelPeriod?.start ?? _defaultFirstDate,
    );
    final lastDate = DateUtils.dateOnly(
      widget.travelPeriod?.end ?? _defaultLastDate,
    );
    // 반대편 날짜를 경계로 사용해 종료일이 시작일보다 앞서지 않게 합니다.
    final lowerBound = isStart ? firstDate : entry.startDate ?? firstDate;
    final upperBound = isStart ? entry.endDate ?? lastDate : lastDate;
    final initialDate =
        (isStart ? entry.startDate : entry.endDate) ?? lowerBound;
    final picked = await showDatePicker(
      context: context,
      firstDate: lowerBound,
      lastDate: upperBound,
      initialDate: initialDate,
      helpText: isStart ? '숙소 시작일 선택' : '숙소 종료일 선택',
      cancelText: '취소',
      confirmText: '선택',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (!mounted || picked == null || !_accommodations.contains(entry)) return;
    setState(() {
      if (isStart) {
        entry.startDate = picked;
      } else {
        entry.endDate = picked;
      }
    });
  }

  Future<AccommodationPlace?> _searchPlace() async {
    // 추후 Places 검색 화면이 선택한 장소 객체를 반환하도록 연결합니다.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google 지도 장소 검색은 API 연결 단계에서 활성화됩니다.')),
    );
    return null;
  }

  Future<void> _selectPlace(_AccommodationEntry entry) async {
    final place = await _searchPlace();
    if (!mounted || place == null || !_accommodations.contains(entry)) return;
    setState(() => entry.place = place);
  }

  @override
  Widget build(BuildContext context) {
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
                      '어디에서\n머무르시나요?',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900, height: 1.25),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '숙소는 선택 사항입니다. 정해진 숙소가 없다면 다음 단계로 이동해주세요.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_accommodations.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          '아직 등록한 숙소가 없습니다.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    for (var index = 0; index < _accommodations.length; index++)
                      _AccommodationCard(
                        key: ObjectKey(_accommodations[index]),
                        number: index + 1,
                        entry: _accommodations[index],
                        onStartDate: () =>
                            _pickDate(_accommodations[index], isStart: true),
                        onEndDate: () =>
                            _pickDate(_accommodations[index], isStart: false),
                        onPlace: () => _selectPlace(_accommodations[index]),
                        onDelete: () => setState(() {
                          _accommodations.removeAt(index);
                        }),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _accommodations.add(_AccommodationEntry());
                        }),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('숙소 추가'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.all(18),
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
            ),
            TripBottomNavigation(
              onPrevious: () => context.go(AppRoutes.tripRegion),
              onNext: () => context.go(AppRoutes.tripFixedSchedule),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccommodationEntry {
  DateTime? startDate;
  DateTime? endDate;
  AccommodationPlace? place;
}

class _AccommodationCard extends StatelessWidget {
  final int number;
  final _AccommodationEntry entry;
  final VoidCallback onStartDate;
  final VoidCallback onEndDate;
  final VoidCallback onPlace;
  final VoidCallback onDelete;

  const _AccommodationCard({
    super.key,
    required this.number,
    required this.entry,
    required this.onStartDate,
    required this.onEndDate,
    required this.onPlace,
    required this.onDelete,
  });

  String _dateText(DateTime? date) =>
      date == null ? '날짜 선택' : DateFormat('yyyy-MM-dd').format(date);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
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
              Expanded(
                child: Text(
                  '숙소 $number',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('삭제'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('숙박 기간', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _inputTile(
            '시작일',
            _dateText(entry.startDate),
            Icons.calendar_today_rounded,
            onStartDate,
          ),
          const SizedBox(height: 10),
          _inputTile(
            '종료일',
            _dateText(entry.endDate),
            Icons.calendar_today_rounded,
            onEndDate,
          ),
          const SizedBox(height: 20),
          const Text('숙소 장소', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _inputTile(
            entry.place?.name ?? '장소 선택',
            entry.place?.address ?? '숙소 또는 지역 검색',
            Icons.location_on_outlined,
            onPlace,
          ),
        ],
      ),
    );
  }

  Widget _inputTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
