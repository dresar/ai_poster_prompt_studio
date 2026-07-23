import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/neo_theme.dart';
import 'core/router/app_router.dart';
import 'core/network/dio_client.dart';

import 'core/services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dio network request headers and token auth interceptors
  setupDioInterceptors();

  // Initialize background image cache directory
  await CacheService.instance.init();

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
