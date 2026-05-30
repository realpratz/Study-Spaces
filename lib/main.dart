import 'dart:async';

import 'package:flutter/material.dart';
import 'package:study_spaces/screens/deck_detail_screen.dart';
import 'package:study_spaces/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'screens/space_detail_screen.dart';

final supabase = Supabase.instance.client;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zcvefqamazogbfvgoezf.supabase.co',
    anonKey: 'sb_publishable_dNDhwxJbNq1vbNNn0Zdn-w_FzaZDG5F',
  );

  runApp(const ProviderScope(child:MainApp()));
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _router = GoRouter(
                  initialLocation: "/login",
                  refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
                  redirect: (context, state) {
                    final session = supabase.auth.currentSession;
                    final isLoggedIn= (session!=null);

                    final isGoingToAuth = (state.uri.path == '/login' || state.uri.path == '/signup');

                    if(!isLoggedIn && !isGoingToAuth){
                      return '/login';
                    }

                    if(isLoggedIn && isGoingToAuth){
                      return '/home';
                    }

                    return null;
                  },
                  routes: [
                    GoRoute(
                      path: '/login',
                      builder: (context,state) => const LoginPage(),
                    ),
                    GoRoute(
                      path: '/signup',
                      builder: (context,state) => const SignUpPage(),
                    ),
                    GoRoute(
                      path: '/home',
                      builder: (context,state) => const HomePage(),
                    ),
                    GoRoute(
                      path: '/profile',
                      builder: (context,state) => const ProfileScreen(),
                    ),
                    GoRoute(
                      path: '/space',
                      builder: (context, state) {
                        final extras = state.extra as Map<String, dynamic>;
                        
                        return SpaceDetailScreen(
                          spaceID: extras['id'] as String,
                          spaceName: extras['name'] as String,
                          inviteCode: extras['inviteCode'] as String,
                          isPublic: extras['isPublic'] as bool,
                        );
                      },
                    ),
                    GoRoute(
                      path: '/deck',
                      builder: (context, state) {
                        final extras = state.extra as Map<String, dynamic>;
                                                
                        return DeckDetailScreen(
                          deckId: extras['deckId'] as String,
                          deckTitle: extras['deckTitle'] as String,
                        );
                      },
                    ),
                  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
