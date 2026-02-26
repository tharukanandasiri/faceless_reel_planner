import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // --- NEW: Expanded State Variables ---
  Color _textColor = Colors.white;
  TextAlign _textAlign = TextAlign.center;
  bool _isExporting = false;

  double _fontSize = 28.0;
  double _bgOpacity = 0.5;
  String _selectedFont = 'Montserrat'; // Default premium font

  // List of fonts
  final List<String> _fontOptions = [
    'Montserrat',
    'Playfair Display',
    'Oswald',
    'Bebas Neue',
    'Caveat',
  ];

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

  Future<void> _exportAndShare() async {
    setState(() => _isExporting = true);
    try {
      final imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File(
          '${directory.path}/reel_${widget.reel.id}.png',
        ).create();
        await imagePath.writeAsBytes(imageBytes);
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

  // Get Google Font
  TextStyle _getGoogleFont() {
    switch (_selectedFont) {
      case 'Playfair Display':
        return GoogleFonts.playfairDisplay();
      case 'Oswald':
        return GoogleFonts.oswald();
      case 'Bebas Neue':
        return GoogleFonts.bebasNeue();
      case 'Caveat':
        return GoogleFonts.caveat();
      default:
        return GoogleFonts.montserrat();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ReelProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reel Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              context.read<ReelProvider>().updateScript(
                widget.reel,
                _scriptController.text,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to database!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. THE CANVAS ---
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                height: 550, // Slightly shorter to make room for controls
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(_isExporting ? 0 : 16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    // Layer 1: Background
                    widget.reel.backgroundImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: widget.reel.backgroundImageUrl!,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Text(
                              'Tap "New BG" below',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                    // Layer 2: Dynamic Dimming Overlay
                    Container(color: Colors.black.withOpacity(_bgOpacity)),

                    // Layer 3: Text Customization
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          _scriptController.text.isEmpty
                              ? 'Type below...'
                              : _scriptController.text,
                          textAlign: _textAlign,
                          style: _getGoogleFont().copyWith(
                            color: _textColor,
                            fontSize: _fontSize,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            // Dynamic shadow
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 2. THE CONTROL PANEL ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Input
                  TextField(
                    controller: _scriptController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter your quote or script...',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onChanged: (text) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Sliders
                  Row(
                    children: [
                      const Icon(Icons.format_size, size: 20),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 16.0,
                          max: 60.0,
                          onChanged: (val) => setState(() => _fontSize = val),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.brightness_4, size: 20),
                      Expanded(
                        child: Slider(
                          value: _bgOpacity,
                          min: 0.0,
                          max: 0.9,
                          activeColor: Colors.grey,
                          onChanged: (val) => setState(() => _bgOpacity = val),
                        ),
                      ),
                    ],
                  ),

                  // Font & Alignment Toolbar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Font Dropdown
                        DropdownButton<String>(
                          value: _selectedFont,
                          items: _fontOptions.map((String font) {
                            return DropdownMenuItem<String>(
                              value: font,
                              child: Text(
                                font,
                                style: TextStyle(fontFamily: font),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedFont = val!),
                        ),
                        const SizedBox(width: 16),
                        // Formatting
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
                        // Quick Colors
                        IconButton(
                          icon: const Icon(Icons.circle, color: Colors.white),
                          onPressed: () =>
                              setState(() => _textColor = Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.circle,
                            color: Colors.yellowAccent,
                          ),
                          onPressed: () =>
                              setState(() => _textColor = Colors.yellowAccent),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context
                              .read<ReelProvider>()
                              .fetchNewBackground(widget.reel),
                          icon: const Icon(Icons.wallpaper),
                          label: const Text('New Image'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportAndShare,
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.ios_share),
                          label: const Text('Export Reel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
