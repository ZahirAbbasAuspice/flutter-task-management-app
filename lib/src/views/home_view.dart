import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../models/task.dart';
import '../providers/preferences_provider.dart';
import '../providers/selected_task_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'add_edit_task_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String _searchQuery = '';
  String _filterStatus = 'All'; // Options: 'All', 'Completed', 'Pending'

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: AppTheme.scaffoldColor(context),
    ));

    final tasks = ref.watch(taskProvider);
    final preferences = ref.watch(preferencesProvider);
    final selectedTask = ref.watch(selectedTaskProvider);

    if (preferences == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Sorting Logic
    final sortedTasks = List.from(tasks);
    if (preferences.sortOrder == 'date') {
      sortedTasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } else if (preferences.sortOrder == 'priority') {
      sortedTasks.sort((a, b) => b.isPriority ? 1 : -1);
    }

    // Search and Filter Logic
    final filteredTasks = sortedTasks.where((task) {
      final matchesSearch = task.title.toString().contains(_searchQuery) ||
          task.description.contains(_searchQuery);
      final matchesFilter = _filterStatus == 'All' ||
          (_filterStatus == 'Completed' &&
              task.isCompleted == true) || // Ensure boolean check
          (_filterStatus == 'Pending' &&
              task.isCompleted == false); // Ensure boolean check
      return matchesSearch && matchesFilter;
    }).toList();

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldColor(context),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppTheme.scaffoldColor(context),
          actions: [
            DropdownButton<String>(
              value: preferences.sortOrder,
              items: const [
                DropdownMenuItem(
                  value: "date",
                  child: Text('Sort by Date'),
                ),
                DropdownMenuItem(
                  value: "priority",
                  child: Text('Sort by Priority'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(preferencesProvider.notifier).updateSortOrder(value);
                }
              },
              underline: const SizedBox.shrink(),
              dropdownColor: AppTheme.cardColor(context),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Switch(
                value: preferences.isDarkMode,
                onChanged: (value) {
                  ref.read(preferencesProvider.notifier).toggleTheme();
                },
              ),
            ),
          ],
          title: const Text("Task"),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          bool isWideScreen =
              constraints.maxWidth > 600; // Adjust width for tablets

          print("isWideScreen=$isWideScreen");
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Search Bar
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search tasks...",
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: AppTheme.cardColor(context),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                        ),
                        // Filter Dropdown
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: DropdownButton<String>(
                        //     value: _filterStatus,
                        //     items: const [
                        //       DropdownMenuItem(value: 'All', child: Text('All')),
                        //       DropdownMenuItem(
                        //           value: 'Completed', child: Text('Completed')),
                        //       DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        //     ],
                        //     onChanged: (value) {
                        //       if (value != null) {
                        //         setState(() {
                        //           _filterStatus = value;
                        //         });
                        //       }
                        //     },
                        //     underline: const SizedBox.shrink(),
                        //     dropdownColor: AppTheme.cardColor(context),
                        //     icon: Icon(Icons.filter_list,
                        //         color: AppTheme.titleColor(context)),
                        //   ),
                        // ),
                      ],
                    ),
                    // Task List
                    filteredTasks.isEmpty
                        ? const Expanded(
                            child: Center(child: Text("No Task")),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    tileColor: task.isCompleted
                                        ? AppTheme.completedCardColor
                                        : task.isPriority
                                            ? AppTheme.priorityCardColor(
                                                context)
                                            : AppTheme.pendingCardColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9)),
                                    title: Row(
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppTheme.titleColor(context),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            task.isCompleted
                                                ? Icons.check_circle
                                                : null,
                                            size: 20,
                                            color: task.isCompleted
                                                ? AppTheme.iconColor(context)
                                                : AppTheme.descriptionColor(
                                                    context),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            overflow: TextOverflow.ellipsis,
                                            color: AppTheme.descriptionColor(
                                                context),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Updated: ${DateFormat('h:mm a, d MMM, yyyy').format(task.updatedAt)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.descriptionColor(
                                                    context)
                                                .withOpacity(0.92),
                                          ),
                                        ),
                                      ],
                                    )
                                        .animate()
                                        .fadeIn(
                                            duration: (600 * (index + 1)).ms)
                                        .then(delay: 100.ms),
                                    isThreeLine: true,
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        task.isPriority || !task.isCompleted
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9),
                                                    color: Colors.black12),
                                                child: Text(
                                                  task.isPriority
                                                      ? "Priority"
                                                      : task.isCompleted
                                                          ? ""
                                                          : "Pending",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 9,
                                                      color: Colors.black),
                                                ),
                                              )
                                                .animate()
                                                .fadeIn(
                                                    duration:
                                                        (600 * (index + 1)).ms)
                                                .then(delay: 100.ms)
                                            : const SizedBox(),
                                      ],
                                    ),
                                    onTap: () async {
                                      if (isWideScreen) {
                                        // Update selected task
                                        ref
                                            .read(selectedTaskProvider.notifier)
                                            .state = null;
                                        await Future.delayed(const Duration(
                                                milliseconds: 45))
                                            .then(
                                          (value) {
                                            ref
                                                .read(selectedTaskProvider
                                                    .notifier)
                                                .updateSelectedTask(task);
                                          },
                                        );
                                      } else {
                                        // Navigate to AddEditTaskView
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddEditTaskView(task: task),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
              if (isWideScreen) const VerticalDivider(width: 1),
              if (isWideScreen)
                Expanded(
                  flex: 3,
                  child: selectedTask == null
                      ? const Center(child: Text("Select a task"))
                      : AddEditTaskView(task: selectedTask)
                          .animate()
                          .fadeIn(duration: const Duration(milliseconds: 333)),
                ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditTaskView(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      );
    });
  }
}
