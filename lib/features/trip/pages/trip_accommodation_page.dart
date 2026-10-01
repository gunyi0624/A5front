import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/trip_bottom_navigation.dart';
import '../widgets/trip_step_header.dart';
import '../widgets/trip_step_indicator.dart';

class TripAccommodationPage extends StatefulWidget {
  /// 추후 여행 기간 화면에서 전달할 날짜 범위입니다.
  final DateTimeRange? travelPeriod;

  const TripAccommodationPage({
    super.key,
    this.travelPeriod,
  });

  @override
  State<TripAccommodationPage> createState() =>
      _TripAccommodationPageState();
}

class _TripAccommodationPageState
    extends State<TripAccommodationPage> {
  final List<_AccommodationEntry> _accommodations = [];

  late final DateTime _defaultFirstDate;
  late final DateTime _defaultLastDate;

  @override
  void initState() {
    super.initState();

    _defaultFirstDate =
        DateUtils.dateOnly(
          DateTime.now(),
        );

    _defaultLastDate =
        DateTime(
          _defaultFirstDate.year + 2,
        );
  }

  Future<void> _pickDate(
      _AccommodationEntry entry, {
        required bool isStart,
      }) async {
    final firstDate =
    DateUtils.dateOnly(
      widget.travelPeriod?.start ??
          _defaultFirstDate,
    );

    final lastDate =
    DateUtils.dateOnly(
      widget.travelPeriod?.end ??
          _defaultLastDate,
    );

    final lowerBound =
    isStart
        ? firstDate
        : entry.startDate ??
        firstDate;

    final upperBound =
    isStart
        ? entry.endDate ??
        lastDate
        : lastDate;

    final initialDate =
        (isStart
            ? entry.startDate
            : entry.endDate) ??
            lowerBound;

    final picked =
    await showDatePicker(
      context: context,
      firstDate: lowerBound,
      lastDate: upperBound,
      initialDate: initialDate,
      helpText:
      isStart
          ? '숙소 시작일 선택'
          : '숙소 종료일 선택',
      cancelText: '취소',
      confirmText: '선택',
      builder: (
          context,
          child,
          ) {
        return Theme(
          data:
          Theme.of(context).copyWith(
            colorScheme:
            Theme.of(context)
                .colorScheme
                .copyWith(
              primary:
              AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted ||
        picked == null ||
        !_accommodations.contains(
          entry,
        )) {
      return;
    }

    setState(() {
      if (isStart) {
        entry.startDate = picked;
      } else {
        entry.endDate = picked;
      }
    });
  }

  void _addAccommodation() {
    setState(() {
      _accommodations.add(
        _AccommodationEntry(),
      );
    });
  }

  void _removeAccommodation(
      int index,
      ) {
    setState(() {
      _accommodations.removeAt(
        index,
      );
    });
  }

  void _goPrevious() {
    context.go(
      AppRoutes.tripRegion,
    );
  }

  void _goNext() {
    FocusScope.of(context).unfocus();

    context.go(
      AppRoutes.tripFixedSchedule,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const TripStepHeader(
              currentStep: 4,
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
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const TripStepIndicator(
                      currentStep: 4,
                    ),

                    const SizedBox(
                      height: 34,
                    ),

                    Text(
                      '어디에서\n머무르시나요?',
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
                        height:
                        1.25,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      '숙소는 선택 사항입니다. 정해진 숙소가 없다면 다음 단계로 이동해주세요.',
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
                        height:
                        1.45,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    if (_accommodations
                        .isEmpty)
                      const Padding(
                        padding:
                        EdgeInsets.only(
                          bottom: 20,
                        ),
                        child: Text(
                          '아직 등록한 숙소가 없습니다.',
                          style:
                          TextStyle(
                            color:
                            AppColors
                                .textSecondary,
                          ),
                        ),
                      ),

                    for (
                    var index = 0;
                    index <
                        _accommodations
                            .length;
                    index++
                    )
                      _AccommodationCard(
                        key: ObjectKey(
                          _accommodations[
                          index],
                        ),
                        number:
                        index + 1,
                        entry:
                        _accommodations[
                        index],
                        onStartDate: () =>
                            _pickDate(
                              _accommodations[
                              index],
                              isStart: true,
                            ),
                        onEndDate: () =>
                            _pickDate(
                              _accommodations[
                              index],
                              isStart: false,
                            ),
                        onPlaceChanged:
                            (value) {
                          _accommodations[
                          index]
                              .place =
                              value;
                        },
                        onDelete: () =>
                            _removeAccommodation(
                              index,
                            ),
                      ),

                    SizedBox(
                      width:
                      double.infinity,
                      child:
                      OutlinedButton
                          .icon(
                        onPressed:
                        _addAccommodation,
                        icon:
                        const Icon(
                          Icons
                              .add_rounded,
                        ),
                        label:
                        const Text(
                          '숙소 추가',
                        ),
                        style:
                        OutlinedButton
                            .styleFrom(
                          foregroundColor:
                          AppColors
                              .primary,
                          padding:
                          const EdgeInsets
                              .all(
                            18,
                          ),
                          side:
                          const BorderSide(
                            color:
                            AppColors
                                .primary,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

class _AccommodationEntry {
  DateTime? startDate;
  DateTime? endDate;

  String place = '';
}

class _AccommodationCard
    extends StatelessWidget {
  final int number;
  final _AccommodationEntry entry;

  final VoidCallback onStartDate;
  final VoidCallback onEndDate;

  final ValueChanged<String>
  onPlaceChanged;

  final VoidCallback onDelete;

  const _AccommodationCard({
    super.key,
    required this.number,
    required this.entry,
    required this.onStartDate,
    required this.onEndDate,
    required this.onPlaceChanged,
    required this.onDelete,
  });

  String _dateText(
      DateTime? date,
      ) {
    if (date == null) {
      return '날짜 선택';
    }

    return DateFormat(
      'yyyy-MM-dd',
    ).format(
      date,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 16,
      ),
      padding:
      const EdgeInsets.all(
        20,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color:
          AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withValues(
              alpha: 0.04,
            ),
            blurRadius:
            18,
            offset:
            const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '숙소 $number',
                  style:
                  Theme.of(
                    context,
                  )
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight
                        .w900,
                  ),
                ),
              ),

              TextButton.icon(
                onPressed:
                onDelete,
                icon:
                const Icon(
                  Icons
                      .delete_outline_rounded,
                ),
                label:
                const Text(
                  '삭제',
                ),
                style:
                TextButton
                    .styleFrom(
                  foregroundColor:
                  AppColors.error,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            '숙박 기간',
            style: TextStyle(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          _inputTile(
            '시작일',
            _dateText(
              entry.startDate,
            ),
            Icons
                .calendar_today_rounded,
            onStartDate,
          ),

          const SizedBox(
            height: 10,
          ),

          _inputTile(
            '종료일',
            _dateText(
              entry.endDate,
            ),
            Icons
                .calendar_today_rounded,
            onEndDate,
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            '숙소 장소',
            style: TextStyle(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          _placeTextField(),
        ],
      ),
    );
  }

  Widget _placeTextField() {
    return Container(
      decoration:
      BoxDecoration(
        color:
        AppColors.background,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
          AppColors.border,
        ),
      ),
      child: TextFormField(
        initialValue:
        entry.place,
        onChanged:
        onPlaceChanged,
        textInputAction:
        TextInputAction.done,
        maxLength: 100,
        decoration:
        const InputDecoration(
          counterText: '',
          hintText:
          '숙소명 또는 주소 입력',
          hintStyle:
          TextStyle(
            color:
            AppColors
                .textSecondary,
            fontWeight:
            FontWeight.w600,
          ),
          prefixIcon:
          Icon(
            Icons
                .location_on_outlined,
            color:
            AppColors.primary,
          ),
          border:
          InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
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
      color:
      AppColors.background,
      borderRadius:
      BorderRadius.circular(
        16,
      ),
      child: ListTile(
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
        ),
        leading: Icon(
          icon,
          color:
          AppColors.primary,
        ),
        title: Text(
          title,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
        subtitle:
        Text(
          subtitle,
        ),
        trailing:
        const Icon(
          Icons
              .chevron_right_rounded,
        ),
        onTap:
        onTap,
      ),
    );
  }
}