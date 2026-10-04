import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:public_file_saver/public_file_saver.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_confirm_dialog.dart';

class ItineraryResultPage extends StatefulWidget {
  final ItinerarySummary? summary;

  const ItineraryResultPage({
    super.key,
    this.summary,
  });

  @override
  State<ItineraryResultPage> createState() =>
      _ItineraryResultPageState();
}

class _ItineraryResultPageState extends State<ItineraryResultPage> {
  late bool isSaved;
  bool _isProcessingPdf = false;

  final PublicFileSaver _fileSaver = PublicFileSaver();

  late final PageController _pageController;

  GoogleMapController? _mapController;

  int selectedDayIndex = 0;

  // TODO: 추후 백엔드에서 전달받은 추천 교통패스 값으로 교체
  final String recommendedPass = 'JR 도쿄 와이드 패스';

  // =========================================================
  // 날짜별 여행 일정
  //
  // 현재는 프론트 테스트를 위해 임시 데이터를 사용합니다.
  // 추후 백엔드 응답으로 교체합니다.
  // =========================================================

  final List<_ItineraryDay> days = [
    _ItineraryDay(
      dayNumber: 1,
      dateLabel: '2026.07.02(목)',
      items: [
        _ItineraryItem(
          time: '09:00',
          title: '도쿄역',
          description: '여행 시작 지점',
          category: '교통',
          latitude: 35.681236,
          longitude: 139.767125,
        ),
        _ItineraryItem(
          time: '10:00',
          title: '아사쿠사 센소지',
          description: '도쿄 대표 전통 사찰 관광',
          category: '관광',
          latitude: 35.714765,
          longitude: 139.796655,
        ),
        _ItineraryItem(
          time: '12:30',
          title: '우에노 맛집 거리',
          description: '현지 음식 중심 점심 식사',
          category: '식사',
          latitude: 35.709700,
          longitude: 139.774700,
        ),
        _ItineraryItem(
          time: '14:00',
          title: '우에노 공원',
          description: '산책과 휴식 중심 일정',
          category: '힐링',
          latitude: 35.714800,
          longitude: 139.773100,
        ),
        _ItineraryItem(
          time: '16:00',
          title: '아키하바라',
          description: '쇼핑 및 서브컬처 거리 탐방',
          category: '쇼핑',
          latitude: 35.698400,
          longitude: 139.773000,
        ),
      ],
    ),
    _ItineraryDay(
      dayNumber: 2,
      dateLabel: '2026.07.03(금)',
      items: [
        _ItineraryItem(
          time: '09:00',
          title: '메이지 신궁',
          description: '도심 속 숲과 신사를 둘러보는 일정',
          category: '문화',
          latitude: 35.676400,
          longitude: 139.699300,
        ),
        _ItineraryItem(
          time: '11:00',
          title: '하라주쿠',
          description: '패션과 개성 있는 상점 거리 탐방',
          category: '쇼핑',
          latitude: 35.670200,
          longitude: 139.702700,
        ),
        _ItineraryItem(
          time: '13:00',
          title: '시부야 스크램블',
          description: '도쿄 대표 도심 명소 방문',
          category: '관광',
          latitude: 35.659500,
          longitude: 139.700500,
        ),
        _ItineraryItem(
          time: '15:30',
          title: '롯폰기 힐즈',
          description: '도심 전망과 쇼핑을 함께 즐기는 일정',
          category: '관광',
          latitude: 35.660500,
          longitude: 139.729200,
        ),
        _ItineraryItem(
          time: '18:30',
          title: '도쿄 타워',
          description: '도쿄 야경 감상',
          category: '야경',
          latitude: 35.658600,
          longitude: 139.745400,
        ),
      ],
    ),
    _ItineraryDay(
      dayNumber: 3,
      dateLabel: '2026.07.04(토)',
      items: [
        _ItineraryItem(
          time: '09:00',
          title: '츠키지 장외시장',
          description: '다양한 일본 음식과 시장 풍경 체험',
          category: '식사',
          latitude: 35.665500,
          longitude: 139.770700,
        ),
        _ItineraryItem(
          time: '11:30',
          title: '긴자 거리',
          description: '백화점과 유명 상점가 쇼핑',
          category: '쇼핑',
          latitude: 35.671700,
          longitude: 139.765000,
        ),
        _ItineraryItem(
          time: '14:00',
          title: '도쿄 황궁',
          description: '도심 속 역사 명소와 정원 산책',
          category: '문화',
          latitude: 35.685200,
          longitude: 139.752800,
        ),
        _ItineraryItem(
          time: '16:30',
          title: '도쿄 돔 시티',
          description: '쇼핑과 엔터테인먼트를 즐기는 일정',
          category: '액티비티',
          latitude: 35.705600,
          longitude: 139.751900,
        ),
        _ItineraryItem(
          time: '19:00',
          title: '신주쿠',
          description: '도심 야경과 저녁 식사',
          category: '야경',
          latitude: 35.693800,
          longitude: 139.703400,
        ),
      ],
    ),
    _ItineraryDay(
      dayNumber: 4,
      dateLabel: '2026.07.05(일)',
      items: [
        _ItineraryItem(
          time: '09:30',
          title: '도요스 시장',
          description: '시장 구경과 아침 식사',
          category: '식사',
          latitude: 35.645400,
          longitude: 139.781900,
        ),
        _ItineraryItem(
          time: '11:30',
          title: '팀랩 플래닛',
          description: '몰입형 디지털 아트 체험',
          category: '액티비티',
          latitude: 35.649100,
          longitude: 139.789800,
        ),
        _ItineraryItem(
          time: '14:30',
          title: '오다이바 해변공원',
          description: '도쿄만 풍경을 감상하며 산책',
          category: '힐링',
          latitude: 35.629700,
          longitude: 139.775600,
        ),
        _ItineraryItem(
          time: '17:00',
          title: '하네다 공항',
          description: '귀국을 위한 공항 이동',
          category: '교통',
          latitude: 35.549400,
          longitude: 139.779800,
        ),
      ],
    ),
  ];

  _ItineraryDay get currentDay => days[selectedDayIndex];

  // PageView는 높이가 필요하므로 가장 일정이 많은 날짜 기준으로 확보
  double get _schedulePageHeight {
    final maxItemCount = days.fold<int>(
      0,
          (maxCount, day) => math.max(
        maxCount,
        day.items.length,
      ),
    );

    return math.max(
      380.0,
      (maxItemCount * 150.0) + 20,
    );
  }

  Set<Marker> get _currentMarkers {
    final day = currentDay;

    return {
      for (int index = 0; index < day.items.length; index++)
        if (day.items[index].hasLocation)
          Marker(
            markerId: MarkerId(
              'day_${day.dayNumber}_$index',
            ),
            position: day.items[index].position!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(
              title: day.items[index].title,
              snippet:
              '${day.items[index].time} · ${day.items[index].category}',
            ),
          ),
    };
  }

  LatLng get _initialMapTarget {
    for (final item in currentDay.items) {
      if (item.hasLocation) {
        return item.position!;
      }
    }

    return const LatLng(
      35.681236,
      139.767125,
    );
  }

  @override
  void initState() {
    super.initState();

    isSaved = widget.summary != null;

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // =========================================================
  // 지도 카메라
  // =========================================================

  Future<void> _updateMapCamera() async {
    final controller = _mapController;

    if (controller == null) return;

    final positions = currentDay.items
        .where(
          (item) => item.hasLocation,
    )
        .map(
          (item) => item.position!,
    )
        .toList();

    if (positions.isEmpty) return;

    // PageView 변경 직후 Google Map 레이아웃이 갱신될 시간을 확보
    await Future<void>.delayed(
      const Duration(
        milliseconds: 180,
      ),
    );

    if (!mounted || _mapController != controller) {
      return;
    }

    try {
      if (positions.length == 1) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            positions.first,
            14.5,
          ),
        );

        return;
      }

      double minLatitude =
          positions.first.latitude;
      double maxLatitude =
          positions.first.latitude;
      double minLongitude =
          positions.first.longitude;
      double maxLongitude =
          positions.first.longitude;

      for (final position in positions.skip(1)) {
        minLatitude = math.min(
          minLatitude,
          position.latitude,
        );
        maxLatitude = math.max(
          maxLatitude,
          position.latitude,
        );
        minLongitude = math.min(
          minLongitude,
          position.longitude,
        );
        maxLongitude = math.max(
          maxLongitude,
          position.longitude,
        );
      }

      // 모든 좌표가 사실상 같은 위치인 경우
      if (minLatitude == maxLatitude &&
          minLongitude == maxLongitude) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            positions.first,
            14.5,
          ),
        );

        return;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(
          minLatitude,
          minLongitude,
        ),
        northeast: LatLng(
          maxLatitude,
          maxLongitude,
        ),
      );

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          54,
        ),
      );
    } catch (_) {
      // 지도 생성 직후 카메라 이동 실패 시 화면 동작에는 영향 없음
    }
  }

  void _handleDayChanged(int index) {
    if (selectedDayIndex == index) return;

    setState(() {
      selectedDayIndex = index;
    });

    _updateMapCamera();
  }

  // =========================================================
  // 뒤로가기 / 저장
  // =========================================================

  Future<bool> _handleBack() async {
    if (isSaved) {
      context.go(AppRoutes.schedule);
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '일정이 저장되었습니다.',
          ),
        ),
      );

      context.go(AppRoutes.schedule);
    } else if (result ==
        AppLeaveDialogResult.discard) {
      await _confirmDiscardAndLeave();
    }

    return false;
  }

  Future<void> _confirmDiscardAndLeave() async {
    final confirmDiscard =
    await showAppConfirmDialog(
      context: context,
      title: '정말 저장하지 않으시겠습니까?',
      message: '지금까지 작성한 내용이 영구히 삭제됩니다.',
      confirmText: '저장하지 않기',
      type: AppConfirmDialogType.danger,
    );

    if (!mounted) return;

    if (confirmDiscard) {
      context.go(AppRoutes.home);
    }
  }

  void _saveSchedule() {
    if (isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '이미 저장된 일정입니다.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '일정이 저장되었습니다.',
        ),
      ),
    );
  }

  // =========================================================
  // 일정 삭제
  //
  // 삭제된 시간대는 그대로 유지하며 지도 마커에서는 제외합니다.
  // =========================================================

  Future<void> _deleteItem(
      _ItineraryDay day,
      _ItineraryItem item,
      ) async {
    final result = await showAppConfirmDialog(
      context: context,
      title: '일정을 삭제하시겠습니까?',
      message:
      '${item.time} ${item.title} 일정이 삭제됩니다.',
      confirmText: '삭제',
      type: AppConfirmDialogType.danger,
    );

    if (!result) return;

    setState(() {
      final index = day.items.indexOf(item);

      if (index != -1) {
        day.items[index] = _ItineraryItem(
          time: item.time,
          title: '비어 있는 시간',
          description:
          '삭제된 일정입니다. 필요하면 새 장소를 추천받아 수정할 수 있습니다.',
          category: '공백',
          isEmpty: true,
        );
      }

      day.items.sort(
            (a, b) => a.time.compareTo(
          b.time,
        ),
      );

      isSaved = false;
    });

    if (day == currentDay) {
      _updateMapCamera();
    }
  }

  // =========================================================
  // AI 대체 장소 추천
  // =========================================================

  void _showEditRecommendations(
      _ItineraryDay day,
      _ItineraryItem item,
      ) {
    final recommendations = [
      _Recommendation(
        title: '긴자 거리',
        description:
        '쇼핑과 카페를 함께 즐길 수 있는 지역',
        category: '쇼핑',
        latitude: 35.671700,
        longitude: 139.765000,
      ),
      _Recommendation(
        title: '스미다 공원',
        description:
        '가볍게 산책하기 좋은 강변 공원',
        category: '힐링',
        latitude: 35.712000,
        longitude: 139.803300,
      ),
      _Recommendation(
        title: '도쿄 국립박물관',
        description:
        '일본 문화와 역사를 볼 수 있는 박물관',
        category: '문화',
        latitude: 35.718800,
        longitude: 139.776500,
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
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.time} 대체 장소 추천',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '같은 시간대에 넣을 수 있는 장소를 선택하세요.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(height: 18),

                ...recommendations.map(
                      (recommendation) {
                    return _RecommendationCard(
                      recommendation:
                      recommendation,
                      onTap: () {
                        setState(() {
                          final index =
                          day.items.indexOf(
                            item,
                          );

                          if (index != -1) {
                            day.items[index] =
                                _ItineraryItem(
                                  time: item.time,
                                  title:
                                  recommendation
                                      .title,
                                  description:
                                  recommendation
                                      .description,
                                  category:
                                  recommendation
                                      .category,
                                  latitude:
                                  recommendation
                                      .latitude,
                                  longitude:
                                  recommendation
                                      .longitude,
                                );
                          }

                          isSaved = false;
                        });

                        Navigator.pop(
                          context,
                        );

                        if (day ==
                            currentDay) {
                          _updateMapCamera();
                        }
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

  void _showItemMenu(
      _ItineraryDay day,
      _ItineraryItem item,
      ) {
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
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              18,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                _BottomSheetAction(
                  icon:
                  Icons.auto_awesome_rounded,
                  label:
                  'AI 대체 장소 추천',
                  onTap: () {
                    Navigator.pop(context);

                    _showEditRecommendations(
                      day,
                      item,
                    );
                  },
                ),

                _BottomSheetAction(
                  icon: Icons.delete_rounded,
                  label: '삭제',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);

                    _deleteItem(
                      day,
                      item,
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

  Future<void> _regenerateSchedule() async {
    setState(() {
      isSaved = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'AI가 새로운 일정을 추천했습니다.',
        ),
      ),
    );
  }

  // =========================================================
  // 추천 교통패스
  // =========================================================

  void _showRecommendedPass() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withOpacity(
                          0.1,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .confirmation_number_rounded,
                        color:
                        AppColors.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        '추천 교통패스',
                        style: Theme.of(
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
                  ],
                ),

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withOpacity(
                      0.08,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Text(
                    recommendedPass,
                    textAlign:
                    TextAlign.center,
                    style: const TextStyle(
                      color:
                      AppColors.primary,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // PDF
  // =========================================================

  String _buildPdfFileName(
      String title,
      ) {
    final safeTitle = title
        .replaceAll(
      RegExp(
        r'[\\/:*?"<>|]',
      ),
      '_',
    )
        .trim();

    final fileTitle = safeTitle.isEmpty
        ? 'AI_여행_일정'
        : safeTitle;

    return '${fileTitle}_일정.pdf';
  }

  pw.Widget _buildPdfItem(
      _ItineraryItem item,
      ) {
    final isEmpty = item.isEmpty;

    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(
        bottom: 10,
      ),
      padding: const pw.EdgeInsets.all(
        14,
      ),
      decoration: pw.BoxDecoration(
        color: isEmpty
            ? PdfColors.grey100
            : PdfColors.white,
        borderRadius:
        pw.BorderRadius.circular(
          9,
        ),
        border: pw.Border.all(
          color: isEmpty
              ? PdfColors.grey300
              : PdfColors.grey200,
        ),
      ),
      child: pw.Row(
        crossAxisAlignment:
        pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 58,
            child: pw.Text(
              item.time,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight:
                pw.FontWeight.bold,
                color: isEmpty
                    ? PdfColors.grey600
                    : PdfColors.blue700,
              ),
            ),
          ),

          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment:
              pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding:
                  const pw.EdgeInsets
                      .symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration:
                  pw.BoxDecoration(
                    color: isEmpty
                        ? PdfColors.grey200
                        : PdfColors.blue50,
                    borderRadius:
                    pw.BorderRadius
                        .circular(
                      20,
                    ),
                  ),
                  child: pw.Text(
                    item.category,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight:
                      pw.FontWeight.bold,
                      color: isEmpty
                          ? PdfColors.grey600
                          : PdfColors.blue700,
                    ),
                  ),
                ),

                pw.SizedBox(height: 7),

                pw.Text(
                  item.title,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight:
                    pw.FontWeight.bold,
                    color: isEmpty
                        ? PdfColors.grey600
                        : PdfColors.grey900,
                  ),
                ),

                pw.SizedBox(height: 4),

                pw.Text(
                  item.description,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color:
                    PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildPdfDay(
      _ItineraryDay day,
      ) {
    return [
      pw.SizedBox(height: 26),

      pw.Text(
        '${day.dayNumber}일차 일정 · ${day.dateLabel}',
        style: pw.TextStyle(
          fontSize: 19,
          fontWeight:
          pw.FontWeight.bold,
        ),
      ),

      pw.SizedBox(height: 14),

      ...day.items.map(
        _buildPdfItem,
      ),
    ];
  }

  Future<Uint8List>
  _generateSchedulePdf() async {
    final displaySummary =
        widget.summary ??
            ItinerarySummary
                .defaultGenerated();

    final regularFont =
    await PdfGoogleFonts
        .notoSansKRRegular();

    final boldFont =
    await PdfGoogleFonts
        .notoSansKRBold();

    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin:
        const pw.EdgeInsets.fromLTRB(
          36,
          40,
          36,
          40,
        ),
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        build: (pdfContext) {
          return [
            pw.Text(
              'AI 여행 플래너',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight:
                pw.FontWeight.bold,
                color:
                PdfColors.blue700,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Text(
              displaySummary.title,
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight:
                pw.FontWeight.bold,
                color:
                PdfColors.grey900,
              ),
            ),

            pw.SizedBox(height: 22),

            // 화면에서는 여행 정보 파란 박스를 제거하지만
            // PDF에는 기존 여행 정보 내용을 유지합니다.
            pw.Container(
              width: double.infinity,
              padding:
              const pw.EdgeInsets.all(
                16,
              ),
              decoration:
              pw.BoxDecoration(
                color:
                PdfColors.blue50,
                borderRadius:
                pw.BorderRadius
                    .circular(
                  10,
                ),
                border: pw.Border.all(
                  color:
                  PdfColors.blue100,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw.CrossAxisAlignment
                    .start,
                children: [
                  pw.Text(
                    '여행 정보',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight:
                      pw.FontWeight
                          .bold,
                      color: PdfColors
                          .blue800,
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  pw.Text(
                    '지역  ${displaySummary.region}',
                    style:
                    const pw.TextStyle(
                      fontSize: 11,
                    ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    '기간  ${displaySummary.period}',
                    style:
                    const pw.TextStyle(
                      fontSize: 11,
                    ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    '일정  ${displaySummary.duration}',
                    style:
                    const pw.TextStyle(
                      fontSize: 11,
                    ),
                  ),

                  pw.SizedBox(height: 6),

                  pw.Text(
                    '테마  ${displaySummary.theme}',
                    style:
                    const pw.TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 18),

            pw.Container(
              width: double.infinity,
              padding:
              const pw.EdgeInsets.all(
                16,
              ),
              decoration:
              pw.BoxDecoration(
                color:
                PdfColors.grey100,
                borderRadius:
                pw.BorderRadius
                    .circular(
                  10,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw.CrossAxisAlignment
                    .start,
                children: [
                  pw.Text(
                    '추천 교통패스',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight:
                      pw.FontWeight
                          .bold,
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  pw.Text(
                    recommendedPass,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight:
                      pw.FontWeight
                          .bold,
                      color:
                      PdfColors.blue700,
                    ),
                  ),
                ],
              ),
            ),

            // 모든 날짜 일정 출력
            ...days.expand(
              _buildPdfDay,
            ),

            pw.SizedBox(height: 18),

            pw.Divider(
              color:
              PdfColors.grey300,
            ),

            pw.SizedBox(height: 8),

            pw.Align(
              alignment:
              pw.Alignment.centerRight,
              child: pw.Text(
                'AI Travel Planner',
                style:
                const pw.TextStyle(
                  fontSize: 9,
                  color:
                  PdfColors.grey500,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return document.save();
  }

  void _showPdfActions() {
    if (!isSaved ||
        _isProcessingPdf) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              6,
              20,
              24,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '일정 PDF',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '완성된 일정을 기기에 저장하거나 다른 앱으로 공유할 수 있습니다.',
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: AppColors
                        .textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                _PdfActionTile(
                  icon:
                  Icons.download_rounded,
                  title: '기기에 저장',
                  description:
                  'PDF 파일을 Download/AI Travel Planner 폴더에 저장합니다.',
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _saveSchedulePdf();
                  },
                ),

                const SizedBox(height: 8),

                _PdfActionTile(
                  icon: Icons.share_rounded,
                  title: '공유',
                  description:
                  '메신저, 메일 등 다른 앱으로 PDF 파일을 공유합니다.',
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                    );

                    _shareSchedulePdf();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveSchedulePdf() async {
    if (!isSaved ||
        _isProcessingPdf) {
      return;
    }

    setState(() {
      _isProcessingPdf = true;
    });

    try {
      final displaySummary =
          widget.summary ??
              ItinerarySummary
                  .defaultGenerated();

      final pdfBytes =
      await _generateSchedulePdf();

      final fileName =
      _buildPdfFileName(
        displaySummary.title,
      );

      final result =
      await _fileSaver.saveBytes(
        bytes: pdfBytes,
        fileName: fileName,
        mimeType:
        'application/pdf',
        subDir:
        'AI Travel Planner',
      );

      if (!mounted) return;

      if (result != null &&
          result.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'PDF가 Download/AI Travel Planner 폴더에 저장되었습니다.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'PDF를 저장하지 못했습니다. 다시 시도해 주세요.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'PDF를 저장하지 못했습니다. 다시 시도해 주세요.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPdf = false;
        });
      }
    }
  }

  Future<void> _shareSchedulePdf() async {
    if (!isSaved ||
        _isProcessingPdf) {
      return;
    }

    setState(() {
      _isProcessingPdf = true;
    });

    try {
      final displaySummary =
          widget.summary ??
              ItinerarySummary
                  .defaultGenerated();

      final pdfBytes =
      await _generateSchedulePdf();

      final fileName =
      _buildPdfFileName(
        displaySummary.title,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
        subject:
        '${displaySummary.title} 여행 일정',
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'PDF를 생성하거나 공유하지 못했습니다. 다시 시도해 주세요.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPdf = false;
        });
      }
    }
  }

  // =========================================================
  // 화면
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor:
        AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // =================================================
              // 상단
              //
              // 기존 PDF / 저장 여부 UI 유지
              // =================================================

              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  12,
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                      child: InkWell(
                        onTap: _handleBack,
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment:
                          Alignment.center,
                          child: const Icon(
                            Icons
                                .arrow_back_ios_new_rounded,
                            size: 20,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'AI 일정 결과',
                        style: Theme.of(
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

                    Tooltip(
                      message: isSaved
                          ? 'PDF 저장 및 공유'
                          : '일정을 저장하면 사용할 수 있습니다.',
                      child: Material(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                        child: InkWell(
                          onTap: isSaved &&
                              !_isProcessingPdf
                              ? _showPdfActions
                              : null,
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                          child: SizedBox(
                            width: 42,
                            height: 42,
                            child: Center(
                              child:
                              _isProcessingPdf
                                  ? const SizedBox(
                                width:
                                18,
                                height:
                                18,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth:
                                  2.2,
                                  color:
                                  AppColors.primary,
                                ),
                              )
                                  : Icon(
                                Icons
                                    .download_rounded,
                                size:
                                22,
                                color: isSaved
                                    ? AppColors
                                    .primary
                                    : AppColors
                                    .textSecondary
                                    .withOpacity(
                                  0.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration:
                      BoxDecoration(
                        color: isSaved
                            ? AppColors.success
                            .withOpacity(
                          0.1,
                        )
                            : AppColors.warning
                            .withOpacity(
                          0.18,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          999,
                        ),
                      ),
                      child: Text(
                        isSaved
                            ? '저장됨'
                            : '저장 전',
                        style: TextStyle(
                          color: isSaved
                              ? AppColors.success
                              : const Color(
                            0xFF9A6B00,
                          ),
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child:
                SingleChildScrollView(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    22,
                    8,
                    22,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      // =================================================
                      // 기존 파란 여행 정보 박스 대신 지도
                      // =================================================

                      _ItineraryMapCard(
                        initialTarget:
                        _initialMapTarget,
                        markers:
                        _currentMarkers,
                        onMapCreated:
                            (controller) {
                          _mapController =
                              controller;

                          _updateMapCamera();
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // =================================================
                      // 현재 날짜 + 추천 패스
                      // =================================================

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  '${currentDay.dayNumber}일차 일정',
                                  style: Theme.of(
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

                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  currentDay
                                      .dateLabel,
                                  style: Theme.of(
                                    context,
                                  )
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                    color: AppColors
                                        .textSecondary,
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          OutlinedButton
                              .icon(
                            onPressed:
                            _showRecommendedPass,
                            icon: const Icon(
                              Icons
                                  .confirmation_number_outlined,
                              size: 18,
                            ),
                            label: const Text(
                              '추천 패스',
                              style: TextStyle(
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),
                            style:
                            OutlinedButton
                                .styleFrom(
                              foregroundColor:
                              AppColors
                                  .primary,
                              side:
                              const BorderSide(
                                color:
                                AppColors
                                    .primary,
                              ),
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal:
                                12,
                                vertical: 9,
                              ),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // =================================================
                      // 날짜 페이지 위치 표시
                      // =================================================

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          for (int index = 0;
                          index <
                              days.length;
                          index++)
                            AnimatedContainer(
                              duration:
                              const Duration(
                                milliseconds:
                                180,
                              ),
                              margin:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 4,
                              ),
                              width: index ==
                                  selectedDayIndex
                                  ? 20
                                  : 7,
                              height: 7,
                              decoration:
                              BoxDecoration(
                                color: index ==
                                    selectedDayIndex
                                    ? AppColors
                                    .primary
                                    : AppColors
                                    .border,
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  999,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Center(
                        child: Text(
                          '좌우로 넘겨 날짜별 일정을 확인하세요.',
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: AppColors
                                .textSecondary,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =================================================
                      // 날짜별 일정 PageView
                      //
                      // 오른쪽 / 왼쪽 스와이프로 날짜 변경
                      // =================================================

                      SizedBox(
                        height:
                        _schedulePageHeight,
                        child:
                        PageView.builder(
                          controller:
                          _pageController,
                          itemCount:
                          days.length,
                          physics:
                          const PageScrollPhysics(),
                          onPageChanged:
                          _handleDayChanged,
                          itemBuilder:
                              (context, index) {
                            final day =
                            days[index];

                            return Column(
                              children: [
                                ...day.items.map(
                                      (item) =>
                                      _TimelineItem(
                                        item: item,
                                        onMoreTap:
                                            () {
                                          _showItemMenu(
                                            day,
                                            item,
                                          );
                                        },
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =================================================
              // 하단 저장 / 재추천 영역 유지
              // =================================================

              Container(
                padding:
                const EdgeInsets.fromLTRB(
                  22,
                  14,
                  22,
                  22,
                ),
                decoration:
                const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color:
                      AppColors.border,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed:
                      _saveSchedule,
                      child: Text(
                        isSaved
                            ? '저장됨'
                            : '일정 저장',
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child:
                      OutlinedButton
                          .icon(
                        onPressed:
                        _regenerateSchedule,
                        icon: const Icon(
                          Icons
                              .refresh_rounded,
                        ),
                        label: const Text(
                          '다시 AI 추천받기',
                          style: TextStyle(
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                        style:
                        OutlinedButton
                            .styleFrom(
                          foregroundColor:
                          AppColors
                              .primary,
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
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// 지도 카드
// ===========================================================

class _ItineraryMapCard extends StatelessWidget {
  final LatLng initialTarget;
  final Set<Marker> markers;
  final ValueChanged<GoogleMapController> onMapCreated;

  const _ItineraryMapCard({
    required this.initialTarget,
    required this.markers,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.05,
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
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(24),
        child: GoogleMap(
          initialCameraPosition:
          CameraPosition(
            target: initialTarget,
            zoom: 12.5,
          ),
          markers: markers,
          onMapCreated:
          onMapCreated,
          myLocationButtonEnabled:
          false,
          zoomControlsEnabled:
          false,
          mapToolbarEnabled:
          false,
          compassEnabled: true,
        ),
      ),
    );
  }
}

// ===========================================================
// 일정 타임라인
// ===========================================================

class _TimelineItem extends StatelessWidget {
  final _ItineraryItem item;
  final VoidCallback onMoreTap;

  const _TimelineItem({
    required this.item,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.isEmpty
        ? AppColors.textSecondary
        : AppColors.primary;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          child: Text(
            item.time,
            style: TextStyle(
              color: color,
              fontWeight:
              FontWeight.w900,
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
            margin:
            const EdgeInsets.only(
              bottom: 16,
            ),
            padding:
            const EdgeInsets.all(
              16,
            ),
            decoration:
            BoxDecoration(
              color: item.isEmpty
                  ? AppColors.background
                  : Colors.white,
              borderRadius:
              BorderRadius.circular(
                20,
              ),
              border: item.isEmpty
                  ? Border.all(
                color:
                AppColors.border,
              )
                  : null,
              boxShadow: item.isEmpty
                  ? null
                  : [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(
                    0.04,
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration:
                            BoxDecoration(
                              color: color
                                  .withOpacity(
                                0.1,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                999,
                              ),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                color:
                                color,
                                fontSize:
                                11,
                                fontWeight:
                                FontWeight
                                    .w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        item.title,
                        style: Theme.of(
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

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        item.description,
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          height:
                          1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: onMoreTap,
                  icon: const Icon(
                    Icons
                        .more_vert_rounded,
                  ),
                  color: AppColors
                      .textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================
// 대체 장소 추천 카드
// ===========================================================

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
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Material(
        color: AppColors.background,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(
              16,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration:
                  BoxDecoration(
                    color: AppColors
                        .primary
                        .withOpacity(
                      0.1,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      16,
                    ),
                  ),
                  child: const Icon(
                    Icons.place_rounded,
                    color:
                    AppColors.primary,
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        recommendation
                            .title,
                        style: Theme.of(
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

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        '${recommendation.category} · '
                            '${recommendation.description}',
                        style: Theme.of(
                          context,
                        )
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          height:
                          1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons
                      .chevron_right_rounded,
                  color: AppColors
                      .textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// PDF 액션
// ===========================================================

class _PdfActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _PdfActionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius:
      BorderRadius.circular(
        18,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        child: Padding(
          padding:
          const EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                BoxDecoration(
                  color: AppColors.primary
                      .withOpacity(
                    0.1,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    15,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                  AppColors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
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

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      description,
                      style: Theme.of(
                        context,
                      )
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: AppColors
                            .textSecondary,
                        height:
                        1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color: AppColors
                    .textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// 하단 메뉴 액션
// ===========================================================

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
    final itemColor =
        color ??
            AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      borderRadius:
      BorderRadius.circular(
        16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: itemColor,
              ),

              const SizedBox(
                width: 14,
              ),

              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// 일정 요약 데이터
// ===========================================================

class ItinerarySummary {
  final String title;
  final String region;
  final String period;
  final String duration;
  final String theme;
  final String status;
  final bool isCompleted;

  const ItinerarySummary({
    required this.title,
    required this.region,
    required this.period,
    required this.duration,
    required this.theme,
    required this.status,
    required this.isCompleted,
  });

  factory ItinerarySummary.defaultGenerated() {
    return const ItinerarySummary(
      title: '도쿄 여행',
      region: '도쿄',
      period: '2026-07-02(목)',
      duration: '3박 4일',
      theme:
      '식도락 / 쇼핑 / 힐링',
      status: '저장 전',
      isCompleted: false,
    );
  }

  factory ItinerarySummary.fromExtra(
      Object? extra,
      ) {
    if (extra is! Map) {
      return ItinerarySummary
          .defaultGenerated();
    }

    return ItinerarySummary(
      title:
      extra['title']?.toString() ??
          '도쿄 여행',
      region:
      extra['region']?.toString() ??
          '도쿄',
      period:
      extra['period']?.toString() ??
          '2026-07-02(목)',
      duration:
      extra['duration']
          ?.toString() ??
          '3박 4일',
      theme:
      extra['theme']?.toString() ??
          '식도락 / 쇼핑 / 힐링',
      status:
      extra['status']?.toString() ??
          '저장 전',
      isCompleted:
      extra['isCompleted'] == true,
    );
  }
}

// ===========================================================
// 날짜별 일정
// ===========================================================

class _ItineraryDay {
  final int dayNumber;
  final String dateLabel;
  final List<_ItineraryItem> items;

  _ItineraryDay({
    required this.dayNumber,
    required this.dateLabel,
    required this.items,
  });
}

// ===========================================================
// 개별 일정
//
// 지도 표시가 필요한 장소는 latitude / longitude를 가집니다.
// 삭제된 공백 일정은 좌표가 없으므로 지도에 표시되지 않습니다.
// ===========================================================

class _ItineraryItem {
  final String time;
  final String title;
  final String description;
  final String category;
  final bool isEmpty;

  final double? latitude;
  final double? longitude;

  _ItineraryItem({
    required this.time,
    required this.title,
    required this.description,
    required this.category,
    this.isEmpty = false,
    this.latitude,
    this.longitude,
  });

  bool get hasLocation {
    return !isEmpty &&
        latitude != null &&
        longitude != null;
  }

  LatLng? get position {
    if (!hasLocation) {
      return null;
    }

    return LatLng(
      latitude!,
      longitude!,
    );
  }
}

// ===========================================================
// 대체 추천 장소
// ===========================================================

class _Recommendation {
  final String title;
  final String description;
  final String category;

  final double latitude;
  final double longitude;

  _Recommendation({
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
  });
}