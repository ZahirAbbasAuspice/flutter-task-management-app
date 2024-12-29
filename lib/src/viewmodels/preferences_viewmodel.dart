import 'package:hive/hive.dart';
import 'package:zybra_task_app/src/enums/sort_order.dart';

import '../models/preferences.dart';

class PreferencesViewModel {
  final _preferencesBox = Hive.box<Preferences>('preferences');

  Preferences? getPreferences() {
    return _preferencesBox.get('user_preferences');
  }

  void toggleTheme(bool isDarkMode) {
    final currentPreferences = getPreferences() ??
        Preferences(isDarkMode: false, sortOrder:  SortOrder.date.name);
    final updatedPreferences = Preferences(
      isDarkMode: isDarkMode,
      sortOrder: currentPreferences.sortOrder,
    );
    _preferencesBox.put('user_preferences', updatedPreferences);
  }

  void updateSortOrder(String sortOrder) {
    final currentPreferences = getPreferences() ??
        Preferences(isDarkMode: false, sortOrder: SortOrder.date.name);
    final updatedPreferences = Preferences(
      isDarkMode: currentPreferences.isDarkMode,
      sortOrder: sortOrder,
    );
    _preferencesBox.put('user_preferences', updatedPreferences);
  }
}
