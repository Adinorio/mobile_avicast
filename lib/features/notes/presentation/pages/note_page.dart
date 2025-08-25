import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/avicast_header.dart';
import '../bloc/notes_bloc.dart';
import '../widgets/note_card.dart';
import '../widgets/add_edit_note_dialog.dart';
import '../widgets/add_task_dialog.dart';
import '../pages/camera_page.dart';
import '../pages/drawing_page.dart';
import '../pages/file_attachment_page.dart';
import '../../data/services/notes_local_storage_service.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late NotesBloc _notesBloc;
  late TabController _tabController;
  int _currentTabIndex = 0;
  List<TaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _notesBloc = NotesBloc(NotesLocalStorageService.instance);
    _notesBloc.add(LoadNotes());
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _loadSampleTasks();
  }

  void _loadSampleTasks() {
    _tasks = [
      TaskItem(
        id: '1',
        title: 'Set up bird counting equipment',
        description: 'Prepare binoculars, counting sheets, and GPS device',
        isCompleted: false,
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(hours: 2)),
      ),
      TaskItem(
        id: '2',
        title: 'Check weather conditions',
        description: 'Verify wind speed and visibility for optimal counting',
        isCompleted: true,
        priority: TaskPriority.medium,
        dueDate: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      TaskItem(
        id: '3',
        title: 'Record site coordinates',
        description: 'Document exact GPS location of counting site',
        isCompleted: false,
        priority: TaskPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 1)),
      ),
      TaskItem(
        id: '4',
        title: 'Complete post-count documentation',
        description: 'Fill out summary forms and upload data',
        isCompleted: false,
        priority: TaskPriority.low,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
    ];
  }

  @override
  void dispose() {
    _notesBloc.close();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditNoteDialog(),
    ).then((note) {
      if (note != null) {
        _notesBloc.add(CreateNote(
          title: note.title,
          content: note.content,
          tags: note.tags,
          siteId: note.siteId,
        ));
      }
    });
  }

  void _showEditNoteDialog(Note note) {
    showDialog(
      context: context,
      builder: (context) => AddEditNoteDialog(note: note),
    ).then((editedNote) {
      if (editedNote != null) {
        _notesBloc.add(UpdateNote(editedNote));
      }
    });
  }

  void _deleteNote(String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _notesBloc.add(DeleteNote(noteId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    ).then((task) {
      if (task != null) {
        setState(() {
          _tasks.add(task);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
      }
    });
  }

  void _toggleTaskCompletion(String taskId) {
    setState(() {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex >= 0) {
        _tasks[taskIndex] = _tasks[taskIndex].copyWith(
          isCompleted: !_tasks[taskIndex].isCompleted,
        );
      }
    });
  }

  void _deleteTask(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _tasks.removeWhere((task) => task.id == taskId);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFeatureOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Choose Feature',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Feature options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFeatureOption(
                    icon: Icons.note_add,
                    title: 'Notes',
                    subtitle: 'Create a new field note',
                    onTap: () {
                      Navigator.pop(context);
                      _showAddNoteDialog();
                    },
                  ),
                  _buildFeatureOption(
                    icon: Icons.checklist,
                    title: 'Task',
                    subtitle: 'Add a new task to checklist',
                    onTap: () {
                      Navigator.pop(context);
                      _showAddTaskDialog();
                    },
                  ),
                  _buildFeatureOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    subtitle: 'Take a photo',
                    onTap: () {
                      Navigator.pop(context);
                      _handleCameraFeature();
                    },
                  ),
                  _buildFeatureOption(
                    icon: Icons.brush,
                    title: 'Drawing Sketch',
                    subtitle: 'Create hand-drawn notes',
                    onTap: () {
                      Navigator.pop(context);
                      _handleDrawingFeature();
                    },
                  ),
                  _buildFeatureOption(
                    icon: Icons.attach_file,
                    title: 'Attach File',
                    subtitle: 'Add document or image',
                    onTap: () {
                      Navigator.pop(context);
                      _handleFileAttachment();
                    },
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF87CEEB).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2C3E50),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF2C3E50),
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleCameraFeature() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraPage(),
      ),
    );
  }

  void _handleDrawingFeature() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DrawingPage(),
      ),
    );
  }

  void _handleFileAttachment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FileAttachmentPage(),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _notesBloc,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF87CEEB), // Light blue
                Color(0xFFB0E0E6), // Powder blue
                Colors.white,
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
          child: Column(
            children: [
              // AVICAST Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: AvicastHeader(
                  pageTitle: 'Field Notes',
                  showPageTitle: true,
                  onBackPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/main', 
                      (route) => false,
                    );
                  },
                ),
              ),
              
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      if (query.isEmpty) {
                        _notesBloc.add(LoadNotes());
                      } else {
                        _notesBloc.add(SearchNotes(query));
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search Here',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              

              
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: _currentTabIndex == 0 ? Colors.green : Colors.purple,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description, size: 20),
                          SizedBox(width: 8),
                          Text('Notes'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist, size: 20),
                          SizedBox(width: 8),
                          Text('Task'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Notes Tab
                    _buildNotesTab(),
                    // Tasks Tab
                    _buildTasksTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showFeatureOptions,
          backgroundColor: const Color(0xFF87CEEB),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNotesTab() {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        if (state is NotesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is NotesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (state is NotesLoaded) {
          if (state.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first field note to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.notes.length,
            itemBuilder: (context, index) {
              final note = state.notes[index];
              return NoteCard(
                note: note,
                onTap: () => _showEditNoteDialog(note),
                onEdit: () => _showEditNoteDialog(note),
                onDelete: () => _deleteNote(note.id),
              );
            },
          );
        }
        
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildTasksTab() {
    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist,
              size: 64,
              color: Colors.purple[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first task to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.isCompleted ? Colors.green : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) => _toggleTaskCompletion(task.id),
              activeColor: Colors.green,
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: task.isCompleted ? Colors.grey[600] : const Color(0xFF2C3E50),
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.priority.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getPriorityColor(task.priority),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due: ${_formatDueDate(task.dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 20,
              ),
              onPressed: () => _deleteTask(task.id),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Now';
      }
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else {
      return 'Overdue';
    }
  }
}

// Task models
enum TaskPriority { high, medium, low }

class TaskItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime dueDate;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    required this.dueDate,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? dueDate,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }
} 