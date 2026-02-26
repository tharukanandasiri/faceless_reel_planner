import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/reel_idea.dart';
import 'viewmodels/reel_provider.dart';
// import 'views/dashboard_view.dart'; // We will build this next

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local storage
  await Hive.initFlutter();
  Hive.registerAdapter(ReelIdeaAdapter());
  await Hive.openBox<ReelIdea>('reels');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ReelProvider())],
      child: const FacelessReelApp(),
    ),
  );
}

class FacelessReelApp extends StatelessWidget {
  const FacelessReelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Faceless Reel Planner',
      theme: ThemeData.dark(useMaterial3: true), // Dark mode fits the aesthetic
      home: Scaffold(
        appBar: AppBar(title: const Text('Reel Planner Setup Complete')),
        body: const Center(child: Text('Ready for Phase 2: The UI!')),
      ),
    );
  }
}
