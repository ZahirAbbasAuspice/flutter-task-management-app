import 'package:hive/hive.dart';

part 'preferences.g.dart';

@HiveType(typeId: 0)
class Preferences {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String sortOrder;

  Preferences({
    required this.isDarkMode,
    required this.sortOrder,
  });

  Preferences copyWith({bool? isDarkTheme, String? sortOrder}) {
    return Preferences(
      isDarkMode: isDarkTheme ?? this.isDarkMode,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
