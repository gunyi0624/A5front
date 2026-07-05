import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class TripLoadingPage extends StatefulWidget {
  const TripLoadingPage({super.key});

  @override
  State<TripLoadingPage> createState() => _TripLoadingPageState();
}

class _TripLoadingPageState extends State<TripLoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  int currentMessageIndex = 0;

  final List<String> messages = [
    '여행 조건을 분석하고 있어요.',
    '일본 여행지 데이터를 확인하고 있어요.',
    '이동 동선을 계산하고 있어요.',
    '고정 일정을 반영하고 있어요.',
    'AI가 최적의 일정을 완성하고 있어요.',
  ];

  Timer? _messageTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.06,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _messageTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;

      setState(() {
        currentMessageIndex = (currentMessageIndex + 1) % messages.length;
      });
    });

    _navigationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/result');
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _cancelGeneration() {
    context.go('/trip/fixed-schedule');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _cancelGeneration,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.28),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 62,
                  ),
                ),
              ),

              const SizedBox(height: 34),

              const Text(
                'AI가 여행 일정을\n생성하고 있어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.28,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 16),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  messages[currentMessageIndex],
                  key: ValueKey(currentMessageIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 38),

              SizedBox(
                width: 210,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.22),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Text(
                '고정 일정과 선택한 조건을 반영해\n무리 없는 동선을 계산합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}