import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/database/migration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  // Initialize database and run migration
  try {
    final migrationService = di.sl<MigrationService>();
    final migrationNeeded = await migrationService.isMigrationNeeded();
    
    if (migrationNeeded) {
      print('Starting data migration...');
      await migrationService.migrateExistingData();
    }
    
    final status = await migrationService.getMigrationStatus();
    print('Database status: $status');
  } catch (e) {
    print('Database initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
      ],
      child: const App(),
    );
  }
} 