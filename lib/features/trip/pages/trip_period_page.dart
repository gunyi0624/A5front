import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/trip_step_indicator.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_bottom_navigation.dart';
import '../../../core/router/app_router.dart';

enum TripPeriodInputType {
  dateRange,
  nightsOnly,
}

class TripPeriodPage extends StatefulWidget {
  const TripPeriodPage({super.key});

  @override
  State<TripPeriodPage> createState() => _TripPeriodPageState();
}

class _TripPeriodPageState extends State<TripPeriodPage> {
  DateTime? startDate;
  DateTime? endDate;

  TripPeriodInputType inputType = TripPeriodInputType.dateRange;
  int selectedNights = 3;

  late DateTime visibleMonth;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    visibleMonth = DateTime(now.year, now.month);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '날짜를 선택하세요';

    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];

    return '${DateFormat('yyyy-MM-dd').format(date)}($weekday)';
  }

  int? get _tripDays {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays + 1;
  }

  int? get _tripNights {
    if (_tripDays == null) return null;
    return _tripDays! - 1;
  }

  bool get _canGoNext {
    if (inputType == TripPeriodInputType.dateRange) {
      return startDate != null && endDate != null;
    }

    return selectedNights >= 0 && selectedNights <= 29;
  }

  String get _nightsOnlyText {
    final days = selectedNights + 1;
    return '$selectedNights박 $days일 여행';
  }

  void _selectDateRangeMode() {
    setState(() {
      inputType = TripPeriodInputType.dateRange;
    });
  }

  void _selectNightsOnlyMode() {
    setState(() {
      inputType = TripPeriodInputType.nightsOnly;
    });
  }

  void _increaseNights() {
    if (selectedNights >= 29) return;

    setState(() {
      selectedNights++;
      inputType = TripPeriodInputType.nightsOnly;
    });
  }

  void _decreaseNights() {
    if (selectedNights <= 0) return;

    setState(() {
      selectedNights--;
      inputType = TripPeriodInputType.nightsOnly;
    });
  }

  void _goPreviousMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    if (visibleMonth.year == currentMonth.year &&
        visibleMonth.month == currentMonth.month) {
      return;
    }

    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
    });
  }

  void _goNextMonth() {
    final now = DateTime.now();
    final limitMonth = DateTime(now.year + 2, now.month);

    if (visibleMonth.year == limitMonth.year &&
        visibleMonth.month == limitMonth.month) {
      return;
    }

    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    final today = _dateOnly(DateTime.now());

    if (date.isBefore(today)) return;

    setState(() {
      inputType = TripPeriodInputType.dateRange;

      if (startDate == null || endDate != null) {
        startDate = date;
        endDate = null;
        return;
      }

      if (date.isBefore(startDate!)) {
        startDate = date;
        endDate = null;
        return;
      }

      if (_isSameDate(date, startDate!)) {
        endDate = date;
        return;
      }

      endDate = date;
    });
  }

  void _resetDateRange() {
    setState(() {
      startDate = null;
      endDate = null;
    });
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _goNext() {
    if (!_canGoNext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('여행 기간을 선택하거나 숙박 일정을 입력해주세요.'),
        ),
      );
      return;
    }

    context.go(AppRoutes.tripEntryExit);
  }

  @override
  Widget build(BuildContext context) {
    final tripDays = _tripDays;
    final tripNights = _tripNights;
    final isDateRangeMode = inputType == TripPeriodInputType.dateRange;
    final isNightsOnlyMode = inputType == TripPeriodInputType.nightsOnly;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(currentStep: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TripStepIndicator(currentStep: 1),

                    const SizedBox(height: 34),

                    Text(
                      '여행 기간을\n선택해주세요.',
                      style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '정확한 날짜를 선택하거나, 아직 날짜가 정해지지 않았다면 숙박 일정만 입력할 수 있습니다.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _InputTypeSelector(
                      selectedType: inputType,
                      onDateRangeTap: _selectDateRangeMode,
                      onNightsOnlyTap: _selectNightsOnlyMode,
                    ),

                    const SizedBox(height: 22),

                    if (isDateRangeMode)
                      _DateRangeCard(
                        visibleMonth: visibleMonth,
                        startDate: startDate,
                        endDate: endDate,
                        startDateText: _formatDate(startDate),
                        endDateText: _formatDate(endDate),
                        startSelected: startDate != null,
                        endSelected: endDate != null,
                        tripNights: tripNights,
                        tripDays: tripDays,
                        onPreviousMonth: _goPreviousMonth,
                        onNextMonth: _goNextMonth,
                        onDateTap: _selectDate,
                        onResetTap: _resetDateRange,
                      ),

                    if (isNightsOnlyMode) ...[
                      _NightsOnlyCard(
                        nights: selectedNights,
                        displayText: _nightsOnlyText,
                        onDecrease: _decreaseNights,
                        onIncrease: _increaseNights,
                      ),
                      const SizedBox(height: 14),
                      const _NoticeBox(
                        text: '숙박 일정을 입력하는 경우 최대 29박 30일까지 선택할 수 있습니다.',
                      ),
                    ],
                  ],
                ),
              ),
            ),

            TripBottomNavigation(
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputTypeSelector extends StatelessWidget {
  final TripPeriodInputType selectedType;
  final VoidCallback onDateRangeTap;
  final VoidCallback onNightsOnlyTap;

  const _InputTypeSelector({
    required this.selectedType,
    required this.onDateRangeTap,
    required this.onNightsOnlyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InputTypeButton(
            title: '날짜 선택',
            selected: selectedType == TripPeriodInputType.dateRange,
            onTap: onDateRangeTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InputTypeButton(
            title: '숙박 일정만',
            selected: selectedType == TripPeriodInputType.nightsOnly,
            onTap: onNightsOnlyTap,
          ),
        ),
      ],
    );
  }
}

class _InputTypeButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _InputTypeButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final String startDateText;
  final String endDateText;
  final bool startSelected;
  final bool endSelected;
  final int? tripNights;
  final int? tripDays;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateTap;
  final VoidCallback onResetTap;

  const _DateRangeCard({
    required this.visibleMonth,
    required this.startDate,
    required this.endDate,
    required this.startDateText,
    required this.endDateText,
    required this.startSelected,
    required this.endSelected,
    required this.tripNights,
    required this.tripDays,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateTap,
    required this.onResetTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelectedRange = startDate != null || endDate != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 34,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '정확한 날짜 선택',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (hasSelectedRange)
                TextButton(
                  onPressed: onResetTap,
                  child: const Text(
                    '초기화',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          _DateRow(
            label: '시작일',
            value: startDateText,
            selected: startSelected,
          ),

          const SizedBox(height: 14),

          _DateRow(
            label: '종료일',
            value: endDateText,
            selected: endSelected,
          ),

          const SizedBox(height: 18),

          _CalendarView(
            visibleMonth: visibleMonth,
            startDate: startDate,
            endDate: endDate,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onDateTap: onDateTap,
          ),

          if (tripDays != null && tripNights != null) ...[
            const SizedBox(height: 18),
            _SelectedPeriodBox(
              text: '$tripNights박 $tripDays일 여행',
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarView extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateTap;

  const _CalendarView({
    required this.visibleMonth,
    required this.startDate,
    required this.endDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateTap,
  });

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime date) {
    if (startDate == null || endDate == null) return false;

    final current = _dateOnly(date);
    final start = _dateOnly(startDate!);
    final end = _dateOnly(endDate!);

    return current.isAfter(start) && current.isBefore(end);
  }

  bool _isRangeEdge(DateTime date) {
    if (startDate != null && _isSameDate(date, startDate!)) return true;
    if (endDate != null && _isSameDate(date, endDate!)) return true;
    return false;
  }

  List<DateTime?> _buildMonthCells() {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final lastDay = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);

    final leadingEmptyCount = firstDay.weekday % 7;
    final cells = <DateTime?>[];

    for (int i = 0; i < leadingEmptyCount; i++) {
      cells.add(null);
    }

    for (int day = 1; day <= lastDay.day; day++) {
      cells.add(DateTime(visibleMonth.year, visibleMonth.month, day));
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = _dateOnly(now);

    final currentMonth = DateTime(now.year, now.month);
    final limitMonth = DateTime(now.year + 2, now.month);

    final canGoPrevious =
    !(visibleMonth.year == currentMonth.year &&
        visibleMonth.month == currentMonth.month);

    final canGoNext =
    !(visibleMonth.year == limitMonth.year &&
        visibleMonth.month == limitMonth.month);

    final monthTitle = DateFormat('yyyy년 M월').format(visibleMonth);
    final cells = _buildMonthCells();
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MonthMoveButton(
                icon: Icons.chevron_left_rounded,
                onTap: canGoPrevious ? onPreviousMonth : null,
              ),
              Expanded(
                child: Text(
                  monthTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _MonthMoveButton(
                icon: Icons.chevron_right_rounded,
                onTap: canGoNext ? onNextMonth : null,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: weekdays.map((weekday) {
              final isSunday = weekday == '일';
              final isSaturday = weekday == '토';

              return Expanded(
                child: Text(
                  weekday,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSunday
                        ? AppColors.error
                        : isSaturday
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final date = cells[index];

              if (date == null) {
                return const SizedBox.shrink();
              }

              final dateOnly = _dateOnly(date);
              final isPast = dateOnly.isBefore(today);
              final isToday = _isSameDate(dateOnly, today);
              final isSelectedEdge = _isRangeEdge(dateOnly);
              final isInSelectedRange = _isInRange(dateOnly);

              return _CalendarDayCell(
                date: dateOnly,
                isPast: isPast,
                isToday: isToday,
                isSelectedEdge: isSelectedEdge,
                isInSelectedRange: isInSelectedRange,
                onTap: () => onDateTap(dateOnly),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isPast;
  final bool isToday;
  final bool isSelectedEdge;
  final bool isInSelectedRange;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.date,
    required this.isPast,
    required this.isToday,
    required this.isSelectedEdge,
    required this.isInSelectedRange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isSelectedEdge
        ? Colors.white
        : isPast
        ? AppColors.textSecondary.withOpacity(0.45)
        : AppColors.textPrimary;

    final backgroundColor = isSelectedEdge
        ? AppColors.primary
        : isInSelectedRange
        ? AppColors.primary.withOpacity(0.12)
        : Colors.transparent;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: isPast ? null : onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: isToday && !isSelectedEdge
                ? Border.all(color: AppColors.primary)
                : null,
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: textColor,
              fontWeight: isSelectedEdge || isToday
                  ? FontWeight.w900
                  : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthMoveButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _MonthMoveButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Material(
      color: disabled
          ? AppColors.border.withOpacity(0.45)
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color: disabled ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _NightsOnlyCard extends StatelessWidget {
  final int nights;
  final String displayText;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _NightsOnlyCard({
    required this.nights,
    required this.displayText,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.hotel_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '숙박 일정만 입력',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '정확한 날짜가 정해지지 않았을 때 사용할 수 있습니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundIconButton(
                  icon: Icons.remove_rounded,
                  onTap: onDecrease,
                  disabled: nights <= 0,
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Text(
                      '$nights박',
                      style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${nights + 1}일',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                _RoundIconButton(
                  icon: Icons.add_rounded,
                  onTap: onIncrease,
                  disabled: nights >= 29,
                ),
              ],
            ),

            const SizedBox(height: 18),

            _SelectedPeriodBox(
              text: displayText,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  final String text;

  const _NoticeBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: disabled
          ? AppColors.border.withOpacity(0.45)
          : AppColors.primary.withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: disabled ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: disabled ? AppColors.textSecondary : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _SelectedPeriodBox extends StatelessWidget {
  final String text;

  const _SelectedPeriodBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;

  const _DateRow({
    required this.label,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}