import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app_router.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://idlnxmfuoecguuhidmdb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlkbG54bWZ1b2VjZ3V1aGlkbWRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4Mzk4NjAsImV4cCI6MjA2NjQxNTg2MH0.YzLPeLY_uYmNv1OKn5Vx57hIPYeCMUGaXQ1bNFTn87A',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => SupabaseService()),
      ],
      child: Builder(
        builder: (context) {
          final authService = Provider.of<AuthService>(context);
          return MaterialApp.router(
            title: 'Mood Journal',
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routerConfig: AppRouter(authService).router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
