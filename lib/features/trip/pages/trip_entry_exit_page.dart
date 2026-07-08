import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/trip_bottom_navigation.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_step_indicator.dart';

class TripEntryExitPage extends StatefulWidget {
  const TripEntryExitPage({super.key});

  @override
  State<TripEntryExitPage> createState() => _TripEntryExitPageState();
}

class _TripEntryExitPageState extends State<TripEntryExitPage> {
  String? entryCity;
  String? exitCity;
  TimeOfDay? entryTime;
  TimeOfDay? exitTime;

  final List<String> prefectures = const [
    '홋카이도',
    '아오모리',
    '이와테',
    '미야기',
    '아키타',
    '야마가타',
    '후쿠시마',
    '도쿄',
    '가나가와',
    '사이타마',
    '지바',
    '이바라키',
    '도치기',
    '군마',
    '니가타',
    '도야마',
    '이시카와',
    '후쿠이',
    '야마나시',
    '나가노',
    '기후',
    '시즈오카',
    '아이치',
    '미에',
    '오사카',
    '교토',
    '효고',
    '나라',
    '시가',
    '와카야마',
    '돗토리',
    '시마네',
    '오카야마',
    '히로시마',
    '야마구치',
    '도쿠시마',
    '가가와',
    '에히메',
    '고치',
    '후쿠오카',
    '사가',
    '나가사키',
    '구마모토',
    '오이타',
    '미야자키',
    '가고시마',
    '오키나와',
  ];

  Future<void> _selectCity({
    required String title,
    required ValueChanged<String> onSelected,
  }) async {
    final selectedCity = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return _CitySearchBottomSheet(
          title: title,
          cities: prefectures,
        );
      },
    );

    if (selectedCity != null) {
      onSelected(selectedCity);
    }
  }

  Future<void> _selectTime({
    required TimeOfDay? initialTime,
    required ValueChanged<TimeOfDay> onSelected,
  }) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: '시간 선택',
      cancelText: '취소',
      confirmText: '확인',
    );

    if (selectedTime != null) {
      onSelected(selectedTime);
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '시간 선택';

    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hourOfPeriod(hour);

    return '$period $displayHour:$minute';
  }

  int hourOfPeriod(int hour) {
    if (hour == 0) return 12;
    if (hour > 12) return hour - 12;
    return hour;
  }

  void _goNext() {
    context.go(AppRoutes.tripFixedSchedule);
  }

  void _goPrevious() {
    context.go(AppRoutes.tripPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(currentStep: 2),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: TripStepIndicator(currentStep: 2),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '입출국 정보를 입력해주세요',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '입국 도시와 출국 도시를 입력하면 더 정확한 여행 일정을 만들 수 있어요.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 22),

                    _EntryExitCard(
                      title: '입국 정보',
                      cityLabel: '입국 도시',
                      cityValue: entryCity,
                      timeLabel: '입국 예정 시간',
                      timeValue: _formatTime(entryTime),
                      onCityTap: () {
                        _selectCity(
                          title: '입국 도시 선택',
                          onSelected: (city) {
                            setState(() {
                              entryCity = city;
                            });
                          },
                        );
                      },
                      onTimeTap: () {
                        _selectTime(
                          initialTime: entryTime,
                          onSelected: (time) {
                            setState(() {
                              entryTime = time;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    _EntryExitCard(
                      title: '출국 정보',
                      cityLabel: '출국 도시',
                      cityValue: exitCity,
                      timeLabel: '출국 예정 시간',
                      timeValue: _formatTime(exitTime),
                      onCityTap: () {
                        _selectCity(
                          title: '출국 도시 선택',
                          onSelected: (city) {
                            setState(() {
                              exitCity = city;
                            });
                          },
                        );
                      },
                      onTimeTap: () {
                        _selectTime(
                          initialTime: exitTime,
                          onSelected: (time) {
                            setState(() {
                              exitTime = time;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '입출국 정보를 입력하지 않으면 추후 입력 시 일정이 변동될 수 있습니다.',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
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
              onPrevious: _goPrevious,
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryExitCard extends StatelessWidget {
  final String title;
  final String cityLabel;
  final String? cityValue;
  final String timeLabel;
  final String timeValue;
  final VoidCallback onCityTap;
  final VoidCallback onTimeTap;

  const _EntryExitCard({
    required this.title,
    required this.cityLabel,
    required this.cityValue,
    required this.timeLabel,
    required this.timeValue,
    required this.onCityTap,
    required this.onTimeTap,
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          _SelectField(
            label: cityLabel,
            value: cityValue ?? '도시 선택',
            icon: Icons.location_city_rounded,
            isPlaceholder: cityValue == null,
            onTap: onCityTap,
          ),
          const SizedBox(height: 12),
          _SelectField(
            label: timeLabel,
            value: timeValue,
            icon: Icons.access_time_rounded,
            isPlaceholder: timeValue == '시간 선택',
            onTap: onTimeTap,
          ),
        ],
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPlaceholder;
  final VoidCallback onTap;

  const _SelectField({
    required this.label,
    required this.value,
    required this.icon,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: isPlaceholder
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CitySearchBottomSheet extends StatefulWidget {
  final String title;
  final List<String> cities;

  const _CitySearchBottomSheet({
    required this.title,
    required this.cities,
  });

  @override
  State<_CitySearchBottomSheet> createState() => _CitySearchBottomSheetState();
}

class _CitySearchBottomSheetState extends State<_CitySearchBottomSheet> {
  final TextEditingController controller = TextEditingController();
  late List<String> filteredCities;

  @override
  void initState() {
    super.initState();
    filteredCities = widget.cities;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _filter(String keyword) {
    setState(() {
      filteredCities = widget.cities
          .where((city) => city.contains(keyword.trim()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: TextField(
                controller: controller,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: '도시 검색',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
                itemCount: filteredCities.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final city = filteredCities[index];

                  return ListTile(
                    title: Text(
                      city,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () => Navigator.pop(context, city),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}