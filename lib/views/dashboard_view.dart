import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reel_idea.dart';
import '../viewmodels/reel_provider.dart';
import 'editor_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider for changes to the reels list
    final reels = context.watch<ReelProvider>().reels;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Content Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: reels.isEmpty
          ? const Center(child: Text('No reel ideas yet. Tap + to start!'))
          : ListView.builder(
              itemCount: reels.length,
              itemBuilder: (context, index) {
                final reel = reels[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      reel.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(reel.status),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditorView(reel: reel),
                        ),
                      );
                    },
                    onLongPress: () {
                      // Delete on long press for quick management
                      context.read<ReelProvider>().deleteReel(reel);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Reel Idea'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Top 3 Cybersecurity Tips',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ReelProvider>().addReelIdea(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
