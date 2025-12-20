import 'package:flutter/material.dart';

class ProGatingService {
  // Mock Pro status - in production, this would check subscription status
  bool get isPro => false;

  bool canAddTrack(int currentTrackCount) {
    const maxFreeTracks = 2;
    return isPro || currentTrackCount < maxFreeTracks;
  }

  bool canAddClip(int currentClipCount) {
    const maxFreeClips = 10;
    return isPro || currentClipCount < maxFreeClips;
  }

  bool canUseAiFeature(String feature) {
    // All AI features are Pro-only in this implementation
    return isPro;
  }

  bool canExportVideo(String quality) {
    if (quality == '4k') return isPro;
    if (quality == '1080p') return isPro;
    return true; // 720p is free
  }

  void showProUpgradeDialog() {
    // In production, this would show a proper upgrade dialog
    // For now, we'll just print to console
    debugPrint('Pro upgrade needed!');
  }

  String getExportQualityLimit() {
    return isPro ? '4k' : '720p';
  }

  int? getMaxTracks() {
    return isPro ? null : 2;
  }

  int? getMaxClips() {
    return isPro ? null : 10;
  }

  bool get showProBadges => !isPro;
}

// Riverpod provider for ProGatingService
final proGatingServiceProvider = Provider<ProGatingService>((ref) => ProGatingService());