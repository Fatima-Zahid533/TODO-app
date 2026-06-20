import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'auth_provider.dart';
import 'task_provider.dart';
import 'task_card.dart';
import 'add_task_sheet.dart';
import 'empty_state.dart';
import 'filter_chips.dart';
import 'profile_screen.dart';
import 'task_model.dart';
import 'api_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedPriority;
  String? _selectedCategory;
  String _sortBy = 'dueDate';

  // Added: API stuff
  final api = ApiService();
  List<TaskModel> allTasks = [];
  List<TaskModel> todayTasks = [];
  List<TaskModel> completedTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchTasks(); // Added: load API data
  }

  // Added: Fetch from API
  Future<void> fetchTasks() async {
    try {
      final data = await api.getData('todos');
      setState(() {

        allTasks = data.map<TaskModel>((e) => TaskModel(
          id: e['id'].toString(),
          title: e['title']?? '',
          description: '',
          isCompleted: e['completed']?? false,
          priority: TaskPriority.medium,
          category: 'General',
          dueDate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )).toList();

        completedTasks = allTasks.where((t) => t.isCompleted).toList();
        todayTasks = allTasks; //
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('API Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load tasks: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Removed: final allTasks = ref.watch(tasksProvider);
    // Removed: final todayTasks = ref.watch(todayTasksProvider);
    // Removed: final completedTasks = ref.watch(completedTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All (${allTasks.length})'), // Changed: use local list
            Tab(text: 'Today (${todayTasks.length})'), // Changed: use local list
            Tab(text: 'Done (${completedTasks.length})'), // Changed: use local list
          ],
        ),
      ),
      body: isLoading // Added: loading check
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          // Filter + Sort row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: FilterChips(
                    selectedPriority: _selectedPriority,
                    selectedCategory: _selectedCategory,
                    onPriorityChanged: (val) =>
                        setState(() => _selectedPriority = val),
                    onCategoryChanged: (val) =>
                        setState(() => _selectedCategory = val),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (val) => setState(() => _sortBy = val),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'dueDate', child: Text('Due Date')),
                    const PopupMenuItem(
                        value: 'priority', child: Text('Priority')),
                    const PopupMenuItem(
                        value: 'createdAt', child: Text('Created Date')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Task lists
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(allTasks, ref), // Changed: pass local list
                _buildTaskList(todayTasks, ref), // Changed: pass local list
                _buildTaskList(completedTasks, ref), // Changed: pass local list
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddTaskSheet(),
          );
          fetchTasks(); // Added: refresh after adding
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks, WidgetRef ref) {
    // Apply search + filters
    var filtered = tasks.where((task) {
      final matchesSearch =
      task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPriority =
          _selectedPriority == null || task.priority.name == _selectedPriority;
      final matchesCategory =
          _selectedCategory == null || task.category == _selectedCategory;
      return matchesSearch && matchesPriority && matchesCategory;
    }).toList();

    // Apply sort
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'priority':
          return b.priority.index.compareTo(a.priority.index);
        case 'createdAt':
          return b.createdAt.compareTo(a.createdAt);
        default: // dueDate - Changed: added null handling
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
      }
    });

    if (filtered.isEmpty) return const EmptyState();

    return RefreshIndicator(
      onRefresh: () async => await fetchTasks(), // Changed: call fetchTasks
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) => TaskCard(task: filtered[index]),
      ),
    );
  }
}