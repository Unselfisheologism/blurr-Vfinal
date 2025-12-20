import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/media_bin.dart';
import '../services/media_service.dart';
import '../services/pro_gating_service.dart';
import 'timeline_provider.dart';

class MediaBinNotifier extends Notifier<MediaBinState> {
  late final MediaService _mediaService;
  late final ProGatingService _proGatingService;

  @override
  MediaBinState build() {
    _mediaService = ref.watch(mediaServiceProvider);
    _proGatingService = ref.watch(proGatingServiceProvider);
    
    // Initialize with empty state
    return const MediaBinState(folders: []);
  }

  Future<void> loadMediaAssets() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final mediaAssets = await _mediaService.loadAllMediaAssets();
      
      // Create folders for different media types
      final folders = <MediaFolder>[
        _createFolder(
          id: 'all',
          name: 'All Media',
          assets: mediaAssets,
          isSystemFolder: true,
        ),
        _createFolder(
          id: 'videos',
          name: 'Videos',
          assets: mediaAssets.where((a) => a.type == ClipType.video).toList(),
          isSystemFolder: true,
        ),
        _createFolder(
          id: 'audio',
          name: 'Audio',
          assets: mediaAssets.where((a) => a.type == ClipType.audio).toList(),
          isSystemFolder: true,
        ),
        _createFolder(
          id: 'images',
          name: 'Images',
          assets: mediaAssets.where((a) => a.type == ClipType.image).toList(),
          isSystemFolder: true,
        ),
      ];

      state = MediaBinState(
        folders: folders,
        selectedFolderId: 'all',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load media assets: $e',
      );
    }
  }

  MediaFolder _createFolder({
    required String id,
    required String name,
    required List<MediaAsset> assets,
    bool isSystemFolder = false,
  }) {
    return MediaFolder(
      id: id,
      name: name,
      isSystemFolder: isSystemFolder,
      assets: assets,
    );
  }

  void setSelectedFolder(String folderId) {
    state = state.copyWith(selectedFolderId: folderId);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleFilter(ClipType filter) {
    final filters = [...state.selectedFilters];
    if (filters.contains(filter)) {
      filters.remove(filter);
    } else {
      filters.add(filter);
    }
    state = state.copyWith(selectedFilters: filters);
  }

  void clearFilters() {
    state = state.copyWith(selectedFilters: []);
  }

  Future<void> importMediaAsset(ClipType type) async {
    try {
      final asset = await _mediaService.importMediaAsset(type);
      if (asset != null) {
        // Add to all media folder and appropriate type folder
        final updatedFolders = state.folders.map((folder) {
          if (folder.id == 'all' || 
              (folder.id == 'videos' && type == ClipType.video) ||
              (folder.id == 'audio' && type == ClipType.audio) ||
              (folder.id == 'images' && type == ClipType.image)) {
            return folder.copyWith(assets: [...folder.assets, asset]);
          }
          return folder;
        }).toList();

        state = state.copyWith(folders: updatedFolders);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to import media: $e');
    }
  }

  Future<void> refreshMediaAssets() async {
    await loadMediaAssets();
  }
}

final mediaBinProvider = NotifierProvider<MediaBinNotifier, MediaBinState>(
  MediaBinNotifier.new,
);