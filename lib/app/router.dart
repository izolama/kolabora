import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nivora/features/feed/domain/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_role_screen.dart';
import '../features/auth/presentation/profile_setup_screen.dart';
import '../features/feed/presentation/create_post_screen.dart';
import '../features/feed/presentation/feed_screen.dart';
import '../features/feed/presentation/post_detail_screen.dart';
import '../features/network/presentation/directory_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/workspaces/presentation/workspaces_screen.dart';
import '../features/workspaces/presentation/workspace_screen.dart';

class AppRouterNotifier extends ChangeNotifier {
  AppRouterNotifier(this.ref) {
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref ref;
}

final _routerNotifierProvider = Provider<AppRouterNotifier>((ref) {
  return AppRouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);
  CustomTransitionPage<void> _page(Widget child, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondary, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  return GoRouter(
    initialLocation: '/feed',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final user = auth.valueOrNull;
      final loggingIn = state.fullPath == '/login';

      if (user == null && !loggingIn) return '/login';
      if (user != null && loggingIn) return '/feed';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _page(const LoginScreen(), state),
      ),
      GoRoute(
        path: '/onboarding/role',
        pageBuilder: (context, state) =>
            _page(const OnboardingRoleScreen(), state),
      ),
      GoRoute(
        path: '/profile/setup',
        pageBuilder: (context, state) =>
            _page(const ProfileSetupScreen(), state),
      ),
      GoRoute(
        path: '/feed',
        pageBuilder: (context, state) => _page(const FeedScreen(), state),
      ),
      GoRoute(
        path: '/network',
        pageBuilder: (context, state) =>
            _page(const NetworkDirectoryScreen(), state),
      ),
      GoRoute(
        path: '/workspaces',
        pageBuilder: (context, state) =>
            _page(const WorkspacesScreen(), state),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            _page(const ProfileScreen(), state),
      ),
      GoRoute(
        path: '/profile/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _page(ProfileScreen(userIdOverride: id), state);
        },
      ),
      GoRoute(
        path: '/create',
        pageBuilder: (context, state) =>
            _page(const CreatePostScreen(), state),
      ),
      GoRoute(
        path: '/post/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          return _page(
            PostDetailScreen(
              postId: id,
              initialPost: extra is Post ? extra : null,
            ),
            state,
          );
        },
      ),
      GoRoute(
        path: '/workspace/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _page(WorkspaceScreen(workspaceId: id), state);
        },
      ),
    ],
  );
});
