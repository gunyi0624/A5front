import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class _ItineraryResultPageState
    extends State<ItineraryResultPage> {
  late bool isSaved;

  bool _isProcessingPdf = false;

  final PublicFileSaver _fileSaver =
  PublicFileSaver();

  @override
  void initState() {
    super.initState();

    isSaved = widget.summary != null;
  }

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

  // TODO: 추후 백엔드에서 전달받은 추천 교통패스 값으로 교체
  final String recommendedPass =
      'JR 도쿄 와이드 패스';

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

  Future<void> _deleteItem(
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
      items.remove(item);

      items.add(
        _ItineraryItem(
          time: item.time,
          title: '비어 있는 시간',
          description:
          '삭제된 일정입니다. 필요하면 새 장소를 추천받아 수정할 수 있습니다.',
          category: '공백',
          isEmpty: true,
        ),
      );

      items.sort(
            (a, b) =>
            a.time.compareTo(b.time),
      );

      isSaved = false;
    });
  }

  void _showEditRecommendations(
      _ItineraryItem item,
      ) {
    final recommendations = [
      _Recommendation(
        title: '긴자 거리',
        description:
        '쇼핑과 카페를 함께 즐길 수 있는 지역',
        category: '쇼핑',
      ),
      _Recommendation(
        title: '스미다 공원',
        description:
        '가볍게 산책하기 좋은 강변 공원',
        category: '힐링',
      ),
      _Recommendation(
        title: '도쿄 국립박물관',
        description:
        '일본 문화와 역사를 볼 수 있는 박물관',
        category: '문화',
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
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
                          items.indexOf(
                            item,
                          );

                          if (index != -1) {
                            items[index] =
                                _ItineraryItem(
                                  time:
                                  item.time,
                                  title:
                                  recommendation
                                      .title,
                                  description:
                                  recommendation
                                      .description,
                                  category:
                                  recommendation
                                      .category,
                                );
                          }

                          isSaved = false;
                        });

                        Navigator.pop(
                          context,
                        );
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
      _ItineraryItem item,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
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
                      item,
                    );
                  },
                ),

                _BottomSheetAction(
                  icon:
                  Icons.delete_rounded,
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

  Future<void>
  _regenerateSchedule() async {
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
            padding:
            const EdgeInsets.all(22),
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

                    const SizedBox(
                      width: 12,
                    ),

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

                const SizedBox(
                  height: 22,
                ),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration:
                  BoxDecoration(
                    color: AppColors
                        .primary
                        .withOpacity(
                      0.08,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      16,
                    ),
                  ),
                  child: Text(
                    recommendedPass,
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      color:
                      AppColors.primary,
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

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
                        FontWeight
                            .w800,
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

    final fileTitle =
    safeTitle.isEmpty
        ? 'AI_여행_일정'
        : safeTitle;

    return '${fileTitle}_일정.pdf';
  }

  Future<Uint8List>
  _generateSchedulePdf() async {
    final displaySummary =
        widget.summary ??
            ItinerarySummary
                .defaultGenerated();

    // PDF에서 한글을 표시하기 위한 Noto Sans KR
    final regularFont =
    await PdfGoogleFonts
        .notoSansKRRegular();

    final boldFont =
    await PdfGoogleFonts
        .notoSansKRBold();

    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat:
        PdfPageFormat.a4,
        margin:
        const pw.EdgeInsets
            .fromLTRB(
          36,
          40,
          36,
          40,
        ),
        theme:
        pw.ThemeData.withFont(
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

            pw.Container(
              width: double.infinity,
              padding:
              const pw.EdgeInsets
                  .all(16),
              decoration:
              pw.BoxDecoration(
                color:
                PdfColors.blue50,
                borderRadius:
                pw.BorderRadius
                    .circular(10),
                border:
                pw.Border.all(
                  color:
                  PdfColors.blue100,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw
                    .CrossAxisAlignment
                    .start,
                children: [
                  pw.Text(
                    '여행 정보',
                    style:
                    pw.TextStyle(
                      fontSize: 16,
                      fontWeight:
                      pw.FontWeight
                          .bold,
                      color: PdfColors
                          .blue800,
                    ),
                  ),

                  pw.SizedBox(
                    height: 12,
                  ),

                  pw.Text(
                    '지역  ${displaySummary.region}',
                    style: const pw
                        .TextStyle(
                      fontSize: 11,
                    ),
                  ),

                  pw.SizedBox(
                    height: 6,
                  ),

                  pw.Text(
                    '기간  ${displaySummary.period}',
                    style: const pw
                        .TextStyle(
                      fontSize: 11,
                    ),
                  ),

                  pw.SizedBox(
                    height: 6,
                  ),

                  pw.Text(
                    '일정  ${displaySummary.duration}',
                    style: const pw
                        .TextStyle(
                      fontSize: 11,
                    ),
                  ),

                  pw.SizedBox(
                    height: 6,
                  ),

                  pw.Text(
                    '테마  ${displaySummary.theme}',
                    style: const pw
                        .TextStyle(
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
              const pw.EdgeInsets
                  .all(16),
              decoration:
              pw.BoxDecoration(
                color:
                PdfColors.grey100,
                borderRadius:
                pw.BorderRadius
                    .circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw
                    .CrossAxisAlignment
                    .start,
                children: [
                  pw.Text(
                    '추천 교통패스',
                    style:
                    pw.TextStyle(
                      fontSize: 14,
                      fontWeight:
                      pw.FontWeight
                          .bold,
                    ),
                  ),

                  pw.SizedBox(
                    height: 8,
                  ),

                  pw.Text(
                    recommendedPass,
                    style:
                    pw.TextStyle(
                      fontSize: 13,
                      fontWeight:
                      pw.FontWeight
                          .bold,
                      color:
                      PdfColors
                          .blue700,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 26),

            pw.Text(
              '1일차 일정',
              style: pw.TextStyle(
                fontSize: 19,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 14),

            ...items.map(
                  (item) {
                final isEmpty =
                    item.isEmpty;

                return pw.Container(
                  width:
                  double.infinity,
                  margin:
                  const pw
                      .EdgeInsets
                      .only(
                    bottom: 10,
                  ),
                  padding:
                  const pw
                      .EdgeInsets
                      .all(14),
                  decoration:
                  pw.BoxDecoration(
                    color: isEmpty
                        ? PdfColors
                        .grey100
                        : PdfColors
                        .white,
                    borderRadius:
                    pw.BorderRadius
                        .circular(
                      9,
                    ),
                    border:
                    pw.Border.all(
                      color: isEmpty
                          ? PdfColors
                          .grey300
                          : PdfColors
                          .grey200,
                    ),
                  ),
                  child: pw.Row(
                    crossAxisAlignment:
                    pw
                        .CrossAxisAlignment
                        .start,
                    children: [
                      pw.SizedBox(
                        width: 58,
                        child: pw.Text(
                          item.time,
                          style:
                          pw.TextStyle(
                            fontSize:
                            12,
                            fontWeight:
                            pw
                                .FontWeight
                                .bold,
                            color: isEmpty
                                ? PdfColors
                                .grey600
                                : PdfColors
                                .blue700,
                          ),
                        ),
                      ),

                      pw.Expanded(
                        child:
                        pw.Column(
                          crossAxisAlignment:
                          pw
                              .CrossAxisAlignment
                              .start,
                          children: [
                            pw.Container(
                              padding:
                              const pw
                                  .EdgeInsets
                                  .symmetric(
                                horizontal:
                                7,
                                vertical:
                                3,
                              ),
                              decoration:
                              pw.BoxDecoration(
                                color: isEmpty
                                    ? PdfColors
                                    .grey200
                                    : PdfColors
                                    .blue50,
                                borderRadius:
                                pw.BorderRadius
                                    .circular(
                                  20,
                                ),
                              ),
                              child:
                              pw.Text(
                                item.category,
                                style:
                                pw.TextStyle(
                                  fontSize:
                                  9,
                                  fontWeight:
                                  pw.FontWeight
                                      .bold,
                                  color: isEmpty
                                      ? PdfColors
                                      .grey600
                                      : PdfColors
                                      .blue700,
                                ),
                              ),
                            ),

                            pw.SizedBox(
                              height: 7,
                            ),

                            pw.Text(
                              item.title,
                              style:
                              pw.TextStyle(
                                fontSize:
                                13,
                                fontWeight:
                                pw.FontWeight
                                    .bold,
                                color: isEmpty
                                    ? PdfColors
                                    .grey600
                                    : PdfColors
                                    .grey900,
                              ),
                            ),

                            pw.SizedBox(
                              height: 4,
                            ),

                            pw.Text(
                              item
                                  .description,
                              style:
                              pw.TextStyle(
                                fontSize:
                                10,
                                color:
                                PdfColors
                                    .grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            pw.SizedBox(height: 18),

            pw.Divider(
              color:
              PdfColors.grey300,
            ),

            pw.SizedBox(height: 8),

            pw.Align(
              alignment:
              pw.Alignment
                  .centerRight,
              child: pw.Text(
                'AI Travel Planner',
                style: const pw
                    .TextStyle(
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
      backgroundColor:
      Colors.white,
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
            const EdgeInsets
                .fromLTRB(
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
                    FontWeight
                        .w900,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

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

                const SizedBox(
                  height: 16,
                ),

                _PdfActionTile(
                  icon: Icons
                      .download_rounded,
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

                const SizedBox(
                  height: 8,
                ),

                _PdfActionTile(
                  icon:
                  Icons.share_rounded,
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

  Future<void>
  _saveSchedulePdf() async {
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
    } catch (e) {
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

  Future<void>
  _shareSchedulePdf() async {
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
    } catch (e) {
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

  @override
  Widget build(
      BuildContext context,
      ) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor:
        AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets
                    .fromLTRB(
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
                      BorderRadius
                          .circular(
                        14,
                      ),
                      child: InkWell(
                        onTap:
                        _handleBack,
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment:
                          Alignment
                              .center,
                          child:
                          const Icon(
                            Icons
                                .arrow_back_ios_new_rounded,
                            size: 20,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

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

                    // PDF 저장 / 공유 버튼
                    // 저장 전에도 표시하지만 비활성화 상태
                    Tooltip(
                      message: isSaved
                          ? 'PDF 저장 및 공유'
                          : '일정을 저장하면 사용할 수 있습니다.',
                      child: Material(
                        color:
                        Colors.white,
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                        child: InkWell(
                          onTap: isSaved &&
                              !_isProcessingPdf
                              ? _showPdfActions
                              : null,
                          borderRadius:
                          BorderRadius
                              .circular(
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
                                Icons.download_rounded,
                                size:
                                22,
                                color: isSaved
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withOpacity(
                                  0.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

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
                            ? AppColors
                            .success
                            .withOpacity(
                          0.1,
                        )
                            : AppColors
                            .warning
                            .withOpacity(
                          0.18,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          999,
                        ),
                      ),
                      child: Text(
                        isSaved
                            ? '저장됨'
                            : '저장 전',
                        style: TextStyle(
                          color: isSaved
                              ? AppColors
                              .success
                              : const Color(
                            0xFF9A6B00,
                          ),
                          fontSize: 12,
                          fontWeight:
                          FontWeight
                              .w900,
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
                      _TripSummaryCard(
                        summary:
                        widget.summary,
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '1일차 일정',
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

                          OutlinedButton
                              .icon(
                            onPressed:
                            _showRecommendedPass,
                            icon:
                            const Icon(
                              Icons
                                  .confirmation_number_outlined,
                              size: 18,
                            ),
                            label:
                            const Text(
                              '추천 패스',
                              style:
                              TextStyle(
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

                      ...items.map(
                            (item) =>
                            _TimelineItem(
                              item: item,
                              onMoreTap: () {
                                _showItemMenu(
                                  item,
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding:
                const EdgeInsets
                    .fromLTRB(
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
                      width:
                      double.infinity,
                      height: 52,
                      child:
                      OutlinedButton
                          .icon(
                        onPressed:
                        _regenerateSchedule,
                        icon:
                        const Icon(
                          Icons
                              .refresh_rounded,
                        ),
                        label:
                        const Text(
                          '다시 AI 추천받기',
                          style:
                          TextStyle(
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

class _TripSummaryCard
    extends StatelessWidget {
  final ItinerarySummary? summary;

  const _TripSummaryCard({
    required this.summary,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final displaySummary =
        summary ??
            ItinerarySummary
                .defaultGenerated();

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
        const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
        ),
        borderRadius:
        BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            displaySummary.title,
            style:
            const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            '${displaySummary.period} · '
                '${displaySummary.duration} · '
                '${displaySummary.theme}',
            style:
            const TextStyle(
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

class _TimelineItem
    extends StatelessWidget {
  final _ItineraryItem item;
  final VoidCallback onMoreTap;

  const _TimelineItem({
    required this.item,
    required this.onMoreTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
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
              decoration:
              BoxDecoration(
                color: color,
                shape:
                BoxShape.circle,
              ),
            ),

            Container(
              width: 2,
              height: 94,
              color:
              AppColors.border,
            ),
          ],
        ),

        const SizedBox(
          width: 14,
        ),

        Expanded(
          child: Container(
            margin:
            const EdgeInsets
                .only(
              bottom: 16,
            ),
            padding:
            const EdgeInsets
                .all(16),
            decoration:
            BoxDecoration(
              color: item.isEmpty
                  ? AppColors
                  .background
                  : Colors.white,
              borderRadius:
              BorderRadius
                  .circular(20),
              border: item.isEmpty
                  ? Border.all(
                color:
                AppColors
                    .border,
              )
                  : null,
              boxShadow:
              item.isEmpty
                  ? null
                  : [
                BoxShadow(
                  color: Colors
                      .black
                      .withOpacity(
                    0.04,
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
                              horizontal:
                              8,
                              vertical:
                              5,
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
                              style:
                              TextStyle(
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

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        item.description,
                        style:
                        Theme.of(
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
                  onPressed:
                  onMoreTap,
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

class _RecommendationCard
    extends StatelessWidget {
  final _Recommendation
  recommendation;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Material(
        color:
        AppColors.background,
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
            const EdgeInsets
                .all(16),
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
                  child:
                  const Icon(
                    Icons
                        .place_rounded,
                    color:
                    AppColors
                        .primary,
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

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        '${recommendation.category} · '
                            '${recommendation.description}',
                        style:
                        Theme.of(
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

class _PdfActionTile
    extends StatelessWidget {
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
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color:
      AppColors.background,
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

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      description,
                      style:
                      Theme.of(
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

class _BottomSheetAction
    extends StatelessWidget {
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
  Widget build(
      BuildContext context,
      ) {
    final itemColor =
        color ??
            AppColors
                .textPrimary;

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
          const EdgeInsets
              .symmetric(
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
                  FontWeight
                      .w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  factory ItinerarySummary
      .defaultGenerated() {
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
      extra['title']
          ?.toString() ??
          '도쿄 여행',
      region:
      extra['region']
          ?.toString() ??
          '도쿄',
      period:
      extra['period']
          ?.toString() ??
          '2026-07-02(목)',
      duration:
      extra['duration']
          ?.toString() ??
          '3박 4일',
      theme:
      extra['theme']
          ?.toString() ??
          '식도락 / 쇼핑 / 힐링',
      status:
      extra['status']
          ?.toString() ??
          '저장 전',
      isCompleted:
      extra['isCompleted'] ==
          true,
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