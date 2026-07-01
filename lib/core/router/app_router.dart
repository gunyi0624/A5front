import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const PlaceholderScreen(title: '스플래시'),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const PlaceholderScreen(title: '로그인'),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const PlaceholderScreen(title: '홈'),
    ),
  ],
);

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}