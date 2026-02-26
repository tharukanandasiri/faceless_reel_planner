import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/reel_idea.dart';
import '../services/unsplash_service.dart';

class ReelProvider extends ChangeNotifier {
  final Box<ReelIdea> _reelBox = Hive.box<ReelIdea>('reels');
  final UnsplashService _unsplashService = UnsplashService();

  List<ReelIdea> get reels => _reelBox.values.toList();

  Future<void> addReelIdea(String title) async {
    final newReel = ReelIdea(
      id: DateTime.now().toString(),
      title: title,
      scriptText: 'Enter your fact or quote here...',
    );
    await _reelBox.put(newReel.id, newReel);
    notifyListeners();
  }

  Future<void> fetchNewBackground(ReelIdea reel) async {
    final newUrl = await _unsplashService.fetchAestheticBackground();
    if (newUrl != null) {
      reel.backgroundImageUrl = newUrl;
      await reel.save();
      notifyListeners();
    }
  }

  Future<void> updateScript(ReelIdea reel, String newText) async {
    reel.scriptText = newText;
    await reel.save();
    notifyListeners();
  }

  Future<void> deleteReel(ReelIdea reel) async {
    await reel.delete();
    notifyListeners();
  }
}
