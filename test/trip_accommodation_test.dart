import 'package:ai_travel_planner/core/router/app_router.dart';
import 'package:ai_travel_planner/features/trip/pages/trip_accommodation_page.dart';
import 'package:ai_travel_planner/features/trip/widgets/trip_step_header.dart';
import 'package:ai_travel_planner/features/trip/widgets/trip_step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  final target = find.text(text).first;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  Future<void> showAccommodation(WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: TripAccommodationPage(
          travelPeriod: DateTimeRange(
            start: DateTime(2026, 7, 2),
            end: DateTime(2026, 7, 10),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('add, delete and renumber independent accommodation cards', (
    tester,
  ) async {
    await showAccommodation(tester);
    expect(find.text('아직 등록한 숙소가 없습니다.'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tapText(tester, '숙소 추가');
    }
    expect(find.text('숙소 3'), findsOneWidget);
    final secondDelete = find.text('삭제').at(1);
    await tester.ensureVisible(secondDelete);
    await tester.tap(secondDelete);
    await tester.pumpAndSettle();
    expect(find.text('숙소 1'), findsOneWidget);
    expect(find.text('숙소 2'), findsOneWidget);
    expect(find.text('숙소 3'), findsNothing);
    expect(find.text('삭제'), findsNWidgets(2));
  });

  testWidgets('date selections obey range and survive deleting another card', (
    tester,
  ) async {
    await showAccommodation(tester);
    await tapText(tester, '숙소 추가');
    await tapText(tester, '시작일');
    var picker = tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(picker.firstDate, DateTime(2026, 7, 2));
    expect(picker.lastDate, DateTime(2026, 7, 10));
    await tapText(tester, '4');
    await tapText(tester, '선택');
    expect(find.text('2026-07-04'), findsOneWidget);
    await tapText(tester, '종료일');
    picker = tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(picker.firstDate, DateTime(2026, 7, 4));
    await tapText(tester, '6');
    await tapText(tester, '선택');
    await tapText(tester, '시작일');
    picker = tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(picker.lastDate, DateTime(2026, 7, 6));
    await tapText(tester, '취소');
    await tapText(tester, '숙소 추가');
    final lastDelete = find.text('삭제').last;
    await tester.ensureVisible(lastDelete);
    await tester.tap(lastDelete);
    await tester.pumpAndSettle();
    expect(find.text('2026-07-04'), findsOneWidget);
    expect(find.text('2026-07-06'), findsOneWidget);
    expect(find.text('숙소 2'), findsNothing);
  });

  testWidgets('place selector explains API availability', (tester) async {
    await showAccommodation(tester);
    await tapText(tester, '숙소 추가');
    await tapText(tester, '장소 선택');
    expect(find.text('Google 지도 장소 검색은 API 연결 단계에서 활성화됩니다.'), findsOneWidget);
  });

  testWidgets(
    'all eight steps, previous routes, optional accommodation and forward flow',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      // Reuse the production route table, avoiding the splash startup timer.
      final router = GoRouter(
        initialLocation: AppRoutes.tripPeriod,
        routes: appRouter.configuration.routes,
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      final routes = [
        AppRoutes.tripPeriod,
        AppRoutes.tripEntryExit,
        AppRoutes.tripRegion,
        AppRoutes.tripAccommodation,
        AppRoutes.tripFixedSchedule,
        AppRoutes.tripCompanion,
        AppRoutes.tripTheme,
        AppRoutes.tripTransport,
      ];
      for (var i = 0; i < routes.length; i++) {
        router.go(routes[i]);
        await tester.pumpAndSettle();
        final header = tester.widget<TripStepHeader>(
          find.byType(TripStepHeader),
        );
        final indicator = tester.widget<TripStepIndicator>(
          find.byType(TripStepIndicator),
        );
        expect(header.currentStep, i + 1);
        expect(header.totalStep, 8);
        expect(indicator.currentStep, i + 1);
        expect(indicator.totalStep, 8);
        if (i > 0) {
          await tapText(tester, '이전');
          expect(router.routeInformationProvider.value.uri.path, routes[i - 1]);
        }
      }
      router.go(AppRoutes.tripPeriod);
      await tester.pumpAndSettle();
      await tapText(tester, '숙박 일정만');
      await tapText(tester, '다음');
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.tripEntryExit,
      );
      await tapText(tester, '다음');
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.tripRegion,
      );
      await tapText(tester, '홋카이도');
      await tapText(tester, '삿포로');
      await tapText(tester, '다음');
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.tripAccommodation,
      );
      // No accommodation cards are required to continue.
      await tapText(tester, '다음');
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.tripFixedSchedule,
      );
      await tapText(tester, '다음');
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.tripCompanion,
      );
      await tapText(tester, '혼자');
      await tapText(tester, '다음');
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.tripTheme,
      );
      await tapText(tester, '맛집');
      await tapText(tester, '다음');
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.tripTransport,
      );
      await tapText(tester, '도보 및 대중교통');
      // Loading contains repeating animation, so do not pumpAndSettle here.
      await tester.tap(find.text('AI 일정 생성하기'));
      await tester.pump();
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.loading);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.result);
      expect(tester.takeException(), isNull);
    },
  );
}
