import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zybra_task_app/src/models/preferences.dart';
import 'package:zybra_task_app/src/providers/preferences_provider.dart';
import 'package:zybra_task_app/src/services/notifcation_service.dart';
import 'package:zybra_task_app/src/theme/app_theme.dart';
import 'package:zybra_task_app/src/views/home_view.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapter for Preferences
  Hive.registerAdapter(PreferencesAdapter());
  await Hive.openBox<Preferences>('preferences');
  await NotificationService.initialize();
  tz.initializeTimeZones();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final isDarkMode = preferences?.isDarkMode ?? true;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Management App',
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const HomeView(),
    );
  }
}
