import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/reel_idea.dart';
import '../viewmodels/reel_provider.dart';

class EditorView extends StatefulWidget {
  final ReelIdea reel;

  const EditorView({super.key, required this.reel});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late TextEditingController _scriptController;

  @override
  void initState() {
    super.initState();
    _scriptController = TextEditingController(text: widget.reel.scriptText);
  }

  @override
  void dispose() {
    _scriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use context.watch to update the UI when a new background is fetched
    context.watch<ReelProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reel.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              context.read<ReelProvider>().updateScript(
                widget.reel,
                _scriptController.text,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Script saved!')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- THE STACK WIDGET (Reel Preview) ---
            Container(
              width: double.infinity,
              height: 600, // Approximate reel aspect ratio
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 10),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  // 1. Bottom Layer: Background Image
                  widget.reel.backgroundImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.reel.backgroundImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : const Center(
                          child: Text(
                            'No Background Yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                  // 2. Middle Layer: Dark Gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // 3. Top Layer: The Script Text
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        _scriptController.text.isEmpty
                            ? 'Enter your script below'
                            : _scriptController.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTROLS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ReelProvider>().fetchNewBackground(widget.reel);
                },
                icon: const Icon(Icons.wallpaper),
                label: const Text('Generate Aesthetic Background'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _scriptController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Edit Script / Quote',
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  // Rebuilds the UI as you type so the Stack updates in real-time
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
