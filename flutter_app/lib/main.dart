import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local word storage
  await Hive.initFlutter();
  await Hive.openBox<String>(AppConstants.wordBoxName);
  await Hive.openBox<String>(AppConstants.sceneBoxName);
  await Hive.openBox<String>(AppConstants.reviewBoxName);
  await Hive.openBox<String>(AppConstants.userBoxName);

  // Initialize SharedPreferences for app settings
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const LinguaFlowApp(),
    ),
  );
}

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});
