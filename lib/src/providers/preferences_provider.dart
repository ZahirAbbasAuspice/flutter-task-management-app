import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../enums/sort_order.dart';
import '../models/preferences.dart';
import '../viewmodels/preferences_viewmodel.dart';

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, Preferences?>((ref) {
  return PreferencesNotifier();
});

class PreferencesNotifier extends StateNotifier<Preferences?> {
  final PreferencesViewModel _viewModel = PreferencesViewModel();

  PreferencesNotifier() : super(null) {
    loadPreferences();
  }

  void loadPreferences() {
    state = _viewModel.getPreferences() ??
        Preferences(isDarkMode: true, sortOrder: SortOrder.date.name);
  }

  void toggleTheme() {
    final isDarkMode = !(state?.isDarkMode ?? true);
    _viewModel.toggleTheme(isDarkMode);
    loadPreferences();
  }

  void updateSortOrder(String sortOrder) {
    _viewModel.updateSortOrder(sortOrder);
    loadPreferences();
    state = state?.copyWith(sortOrder: sortOrder); // Notify changes
  }
}
