import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/video_clip.dart';

class MediaAsset {
  final String id;
  final String name;
  final String filePath;
  final ClipType type;
  final double? duration;
  final Size? dimensions;
  final String? thumbnailPath;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  MediaAsset({
    required this.id,
    required this.name,
    required this.filePath,
    required this.type,
    this.duration,
    this.dimensions,
    this.thumbnailPath,
    this.createdAt,
    this.metadata,
  });

  MediaAsset copyWith({
    String? id,
    String? name,
    String? filePath,
    ClipType? type,
    double? duration,
    Size? dimensions,
    String? thumbnailPath,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return MediaAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      dimensions: dimensions ?? this.dimensions,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String get displayName => name ?? filePath.split('/').last;
  
  String get displayDuration {
    if (duration == null) return '';
    final minutes = (duration! ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration! % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class MediaFolder {
  final String id;
  final String name;
  final String? parentId;
  final bool isSystemFolder;
  final List<MediaAsset> assets;

  MediaFolder({
    required this.id,
    required this.name,
    this.parentId,
    this.isSystemFolder = false,
    required this.assets,
  });

  MediaFolder copyWith({
    String? id,
    String? name,
    String? parentId,
    bool? isSystemFolder,
    List<MediaAsset>? assets,
  }) {
    return MediaFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      isSystemFolder: isSystemFolder ?? this.isSystemFolder,
      assets: assets ?? this.assets,
    );
  }
}

class MediaBinState {
  final List<MediaFolder> folders;
  final String? selectedFolderId;
  final String? searchQuery;
  final List<ClipType> selectedFilters;
  final bool isLoading;
  final String? errorMessage;

  const MediaBinState({
    required this.folders,
    this.selectedFolderId,
    this.searchQuery,
    this.selectedFilters = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MediaBinState copyWith({
    List<MediaFolder>? folders,
    String? selectedFolderId,
    String? searchQuery,
    List<ClipType>? selectedFilters,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MediaBinState(
      folders: folders ?? this.folders,
      selectedFolderId: selectedFolderId ?? this.selectedFolderId,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  MediaFolder? get selectedFolder {
    if (selectedFolderId == null) return null;
    return folders.firstWhere(
      (f) => f.id == selectedFolderId,
    );
  }

  List<MediaAsset> get filteredAssets {
    final folder = selectedFolder;
    if (folder == null) return [];

    var assets = folder.assets;

    // Apply search filter
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      assets = assets.where((asset) => 
        asset.name.toLowerCase().contains(searchQuery!.toLowerCase())
      ).toList();
    }

    // Apply type filters
    if (selectedFilters.isNotEmpty) {
      assets = assets.where((asset) => 
        selectedFilters.contains(asset.type)
      ).toList();
    }

    return assets;
  }
}