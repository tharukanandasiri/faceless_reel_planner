import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  final ScreenshotController _screenshotController = ScreenshotController();

  // New State variables for customization
  Color _textColor = Colors.white;
  TextAlign _textAlign = TextAlign.center;
  bool _isExporting = false;

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

  // --- THE EXPORT LOGIC ---
  Future<void> _exportAndShare() async {
    setState(() => _isExporting = true);
    try {
      // 1. Capture the Stack as a byte array
      final imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
      ); // High-res capture

      if (imageBytes != null) {
        // 2. Save it to a temporary file
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File(
          '${directory.path}/reel_${widget.reel.id}.png',
        ).create();
        await imagePath.writeAsBytes(imageBytes);

        // 3. Share it using native OS share sheet
        await Share.shareXFiles([
          XFile(imagePath.path),
        ], text: 'Check out my new reel idea!');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              ).showSnackBar(const SnackBar(content: Text('Saved!')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- WRAP THE STACK IN SCREENSHOT WIDGET ---
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                height: 600,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  // Remove border radius during export so the final image is a perfect rectangle
                  borderRadius: BorderRadius.circular(_isExporting ? 0 : 16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    widget.reel.backgroundImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: widget.reel.backgroundImageUrl!,
                            fit: BoxFit.cover,
                          )
                        : const Center(child: Text('No Background')),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          _scriptController.text.isEmpty
                              ? 'Type below...'
                              : _scriptController.text,
                          textAlign: _textAlign,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            shadows: const [
                              Shadow(color: Colors.black, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- NEW: STYLING TOOLBAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.format_align_left),
                    onPressed: () =>
                        setState(() => _textAlign = TextAlign.left),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_align_center),
                    onPressed: () =>
                        setState(() => _textAlign = TextAlign.center),
                  ),
                  IconButton(
                    icon: const Icon(Icons.circle, color: Colors.white),
                    onPressed: () => setState(() => _textColor = Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.circle, color: Colors.yellowAccent),
                    onPressed: () =>
                        setState(() => _textColor = Colors.yellowAccent),
                  ),
                  IconButton(
                    icon: const Icon(Icons.circle, color: Colors.greenAccent),
                    onPressed: () =>
                        setState(() => _textColor = Colors.greenAccent),
                  ),
                ],
              ),
            ),

            // --- CONTROLS ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context
                          .read<ReelProvider>()
                          .fetchNewBackground(widget.reel),
                      icon: const Icon(Icons.wallpaper),
                      label: const Text('New BG'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportAndShare,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _scriptController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Edit Script',
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
