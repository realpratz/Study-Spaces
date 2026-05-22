import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zcvefqamazogbfvgoezf.supabase.co',
    anonKey: 'sb_publishable_dNDhwxJbNq1vbNNn0Zdn-w_FzaZDG5F',
  );

  runApp(const ProviderScope(child:MainApp()));
}

final _router = GoRouter(
                  initialLocation: "/login",
                  routes: [
                    GoRoute(
                      path: '/login',
                      builder: (context,state) => const LoginPage(),
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
