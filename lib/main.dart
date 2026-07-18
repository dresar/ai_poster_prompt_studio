import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/neo_theme.dart';
import 'core/router/app_router.dart';
import 'core/network/dio_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dio network request headers and token auth interceptors
  setupDioInterceptors();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Studio Prompt',
      theme: NeoTheme.themeData,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
