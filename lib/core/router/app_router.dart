import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/permission_page.dart';
import '../../features/emergency/pages/emergency_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/information/pages/information_page.dart';
import '../../features/mypage/pages/mypage_page.dart';
import '../../features/schedule/pages/itinerary_result_page.dart';
import '../../features/schedule/pages/schedule_page.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/trip/pages/trip_accommodation_page.dart';
import '../../features/trip/pages/trip_companion_page.dart';
import '../../features/trip/pages/trip_entry_exit_page.dart';
import '../../features/trip/pages/trip_fixed_schedule_page.dart';
import '../../features/trip/pages/trip_loading_page.dart';
import '../../features/trip/pages/trip_period_page.dart';
import '../../features/trip/pages/trip_region_page.dart';
import '../../features/trip/pages/trip_schedule_settings_page.dart';
import '../../features/trip/pages/trip_theme_page.dart';
import '../../features/trip/pages/trip_transport_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: AppRouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: AppRoutes.login,
      name: AppRouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: AppRoutes.permission,
      name: AppRouteNames.permission,
      builder: (context, state) => const PermissionPage(),
    ),

    GoRoute(
      path: AppRoutes.permissionSettings,
      name: AppRouteNames.permissionSettings,
      builder: (context, state) => const PermissionPage(
        isSettingsMode: true,
      ),
    ),

    GoRoute(
      path: AppRoutes.home,
      name: AppRouteNames.home,
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(
      path: AppRoutes.mypage,
      name: AppRouteNames.mypage,
      builder: (context, state) => const MyPage(),
    ),

    GoRoute(
      path: AppRoutes.schedule,
      name: AppRouteNames.schedule,
      builder: (context, state) => const SchedulePage(),
    ),

    GoRoute(
      path: AppRoutes.information,
      name: AppRouteNames.information,
      builder: (context, state) => const InformationPage(),
    ),

    GoRoute(
      path: AppRoutes.emergency,
      name: AppRouteNames.emergency,
      builder: (context, state) => const EmergencyPage(),
    ),

    // =========================================================
    // 여행 일정 생성 1 ~ 9단계
    // =========================================================

    GoRoute(
      path: AppRoutes.tripPeriod,
      name: AppRouteNames.tripPeriod,
      builder: (context, state) => const TripPeriodPage(),
    ),

    GoRoute(
      path: AppRoutes.tripRegion,
      name: AppRouteNames.tripRegion,
      builder: (context, state) => const TripRegionPage(),
    ),

    GoRoute(
      path: AppRoutes.tripEntryExit,
      name: AppRouteNames.tripEntryExit,
      builder: (context, state) => const TripEntryExitPage(),
    ),

    GoRoute(
      path: AppRoutes.tripAccommodation,
      name: AppRouteNames.tripAccommodation,
      builder: (context, state) => const TripAccommodationPage(),
    ),

    GoRoute(
      path: AppRoutes.tripFixedSchedule,
      name: AppRouteNames.tripFixedSchedule,
      builder: (context, state) => const TripFixedSchedulePage(),
    ),

    GoRoute(
      path: AppRoutes.tripCompanion,
      name: AppRouteNames.tripCompanion,
      builder: (context, state) => const TripCompanionPage(),
    ),

    GoRoute(
      path: AppRoutes.tripTheme,
      name: AppRouteNames.tripTheme,
      builder: (context, state) => const TripThemePage(),
    ),

    GoRoute(
      path: AppRoutes.tripTransport,
      name: AppRouteNames.tripTransport,
      builder: (context, state) => const TripTransportPage(),
    ),

    GoRoute(
      path: AppRoutes.tripScheduleSettings,
      name: AppRouteNames.tripScheduleSettings,
      builder: (context, state) =>
      const TripScheduleSettingsPage(),
    ),

    // =========================================================
    // 일정 생성 및 결과
    // =========================================================

    GoRoute(
      path: AppRoutes.loading,
      name: AppRouteNames.loading,
      builder: (context, state) => const TripLoadingPage(),
    ),

    GoRoute(
      path: AppRoutes.result,
      name: AppRouteNames.result,
      builder: (context, state) {
        final extra = state.extra;

        return ItineraryResultPage(
          summary:
          extra == null
              ? null
              : ItinerarySummary.fromExtra(extra),
        );
      },
    ),
  ],
);

class AppRoutes {
  static const splash = '/';

  static const login = '/login';
  static const permission = '/permission';
  static const permissionSettings = '/permission-settings';

  static const home = '/home';
  static const mypage = '/mypage';
  static const schedule = '/schedule';
  static const information = '/information';
  static const emergency = '/emergency';

  // 여행 일정 생성
  static const tripPeriod = '/trip/period';
  static const tripRegion = '/trip/region';
  static const tripEntryExit = '/trip/entry-exit';
  static const tripAccommodation = '/trip/accommodation';
  static const tripFixedSchedule = '/trip/fixed-schedule';
  static const tripCompanion = '/trip/companion';
  static const tripTheme = '/trip/theme';
  static const tripTransport = '/trip/transport';
  static const tripScheduleSettings =
      '/trip/schedule-settings';

  static const loading = '/loading';
  static const result = '/result';
}

class AppRouteNames {
  static const splash = 'splash';

  static const login = 'login';
  static const permission = 'permission';
  static const permissionSettings = 'permissionSettings';

  static const home = 'home';
  static const mypage = 'mypage';
  static const schedule = 'schedule';
  static const information = 'information';
  static const emergency = 'emergency';

  // 여행 일정 생성
  static const tripPeriod = 'tripPeriod';
  static const tripRegion = 'tripRegion';
  static const tripEntryExit = 'tripEntryExit';
  static const tripAccommodation = 'tripAccommodation';
  static const tripFixedSchedule = 'tripFixedSchedule';
  static const tripCompanion = 'tripCompanion';
  static const tripTheme = 'tripTheme';
  static const tripTransport = 'tripTransport';
  static const tripScheduleSettings =
      'tripScheduleSettings';

  static const loading = 'loading';
  static const result = 'result';
}