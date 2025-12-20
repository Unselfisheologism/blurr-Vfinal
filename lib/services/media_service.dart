import 'package:flutter/services.dart';

class MediaService {
  static const _channel = MethodChannel('com.blurr.voice/media');
  static const String _tag = 'MediaService';

  /// Imports a media asset from device storage
  Future<Map<String, dynamic>?> importMediaAsset(String type) async {
    try {
      final result = await _channel.invokeMethod<Map<String, dynamic>>(
        'importMediaAsset',
        {'type': type},
      );
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to import media asset: ${e.message}');
    }
  }

  /// Loads all available media assets from device
  Future<List<Map<String, dynamic>>> loadAllMediaAssets() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'loadAllMediaAssets',
        {},
      );
      
      return result?.cast<Map<String, dynamic>>() ?? [];
    } on PlatformException catch (e) {
      throw Exception('Failed to load media assets: ${e.message}');
    }
  }

  /// Gets asset thumbnail for preview
  Future<String?> getAssetThumbnail(String assetPath) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'getAssetThumbnail',
        {'asset_path': assetPath},
      );
      return result;
    } on PlatformException catch (e) {
      print('Error getting thumbnail: $e');
      return null;
    }
  }

  /// Gets asset dimensions (width/height)
  Future<Map<String, int>?> getAssetDimensions(String assetPath) async {
    try {
      final result = await _channel.invokeMethod<Map<String, int>>(
        'getAssetDimensions',
        {'asset_path': assetPath},
      );
      return result;
    } on PlatformException catch (e) {
      print('Error getting dimensions: $e');
      return null;
    }
  }

  /// Gets asset duration for video/audio files
  Future<double?> getAssetDuration(String assetPath) async {
    try {
      final result = await _channel.invokeMethod<double>(
        'getAssetDuration',
        {'asset_path': assetPath},
      );
      return result;
    } on PlatformException catch (e) {
      print('Error getting duration: $e');
      return null;
    }
  }
}

// Riverpod provider for MediaService
final mediaServiceProvider = Provider<MediaService>((ref) => MediaService());