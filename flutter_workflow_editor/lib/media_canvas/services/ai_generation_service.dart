/// AI generation service for multimodal media
/// Uses existing ImageGenerationTool, VideoGenerationTool, AudioGenerationTool, MusicGenerationTool
/// from the Ultra-Generalist Agent infrastructure
import '../models/media_layer_node.dart';
import '../../services/platform_bridge.dart';

class AIGenerationService {
  final PlatformBridge _platformBridge = PlatformBridge();

  /// Generate image from prompt using ImageGenerationTool
  Future<MediaLayerNode?> generateImage({
    required String prompt,
    double? width,
    double? height,
  }) async {
    try {
      // Use the existing ImageGenerationTool via agent
      // Tool parameters: prompt, model (optional), size (optional)
      final result = await _platformBridge.executeAgentTask(
        'Use the image_generation tool to create an image: $prompt',
      );

      if (result['success'] == true && result['result'] != null) {
        // ImageGenerationTool returns image URL
        final imageUrl = result['result'] as String;
        
        return MediaLayerNode.image(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'AI Image',
          imageUrl: imageUrl,
          transform: LayerTransform(
            x: 100,
            y: 100,
            width: width ?? 512,
            height: height ?? 512,
          ),
        );
      }
    } catch (e) {
      print('Error generating image: $e');
    }
    return null;
  }

  /// Generate video from prompt using VideoGenerationTool
  Future<MediaLayerNode?> generateVideo({
    required String prompt,
    double? duration,
  }) async {
    try {
      // Use the existing VideoGenerationTool via agent
      // Tool parameters: prompt, duration (optional)
      final result = await _platformBridge.executeAgentTask(
        'Use the video_generation tool to create a video: $prompt',
      );

      if (result['success'] == true && result['result'] != null) {
        // VideoGenerationTool returns video URL
        final videoUrl = result['result'] as String;
        
        return MediaLayerNode.video(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'AI Video',
          videoUrl: videoUrl,
          duration: duration,
          transform: const LayerTransform(
            x: 100,
            y: 100,
            width: 640,
            height: 360,
          ),
        );
      }
    } catch (e) {
      print('Error generating video: $e');
    }
    return null;
  }

  /// Generate audio from prompt using AudioGenerationTool or MusicGenerationTool
  Future<MediaLayerNode?> generateAudio({
    required String prompt,
    double? duration,
    bool isMusic = false,
  }) async {
    try {
      // Use AudioGenerationTool for speech/sound effects
      // Use MusicGenerationTool for music generation
      final toolName = isMusic ? 'music_generation' : 'audio_generation';
      final result = await _platformBridge.executeAgentTask(
        'Use the $toolName tool to create audio: $prompt',
      );

      if (result['success'] == true && result['result'] != null) {
        // Tools return audio URL
        final audioUrl = result['result'] as String;
        
        return MediaLayerNode.audio(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: isMusic ? 'AI Music' : 'AI Audio',
          audioUrl: audioUrl,
          duration: duration,
          transform: const LayerTransform(
            x: 100,
            y: 100,
            width: 400,
            height: 80,
          ),
        );
      }
    } catch (e) {
      print('Error generating audio: $e');
    }
    return null;
  }

  /// AI layout suggestions (Refly-inspired pilot)
  Future<String?> suggestLayout({
    required List<MediaLayerNode> layers,
    required String intent,
  }) async {
    try {
      final layerInfo = layers.map((l) => '${l.type.name}: ${l.name}').join(', ');
      
      final result = await _platformBridge.executeAgentTask(
        'Analyze canvas layers: $layerInfo. User intent: $intent. Suggest layout improvements.',
      );

      if (result['success'] == true) {
        return result['result'] as String?;
      }
    } catch (e) {
      print('Error suggesting layout: $e');
    }
    return null;
  }

  /// Generate text content
  Future<MediaLayerNode?> generateText({
    required String prompt,
  }) async {
    try {
      final result = await _platformBridge.executeAgentTask(
        'Generate text content: $prompt',
      );

      if (result['success'] == true && result['result'] != null) {
        final textContent = result['result'] as String;
        
        return MediaLayerNode.text(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'AI Text',
          content: textContent,
          transform: const LayerTransform(
            x: 100,
            y: 100,
            width: 400,
            height: 100,
          ),
        );
      }
    } catch (e) {
      print('Error generating text: $e');
    }
    return null;
  }

  /// Generate 3D model from prompt using Model3DGenerationTool
  Future<MediaLayerNode?> generate3DModel({
    required String prompt,
  }) async {
    try {
      // Use the existing Model3DGenerationTool via agent
      // Tool uses Meshy, Tripo, or other 3D generation services
      final result = await _platformBridge.executeAgentTask(
        'Use the model_3d_generation tool to create a 3D model: $prompt',
      );

      if (result['success'] == true && result['result'] != null) {
        // Model3DGenerationTool returns GLB/GLTF URL
        final modelUrl = result['result'] as String;
        
        return MediaLayerNode.model3d(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'AI 3D Model',
          modelUrl: modelUrl,
          transform: const LayerTransform(
            x: 100,
            y: 100,
            width: 300,
            height: 300,
          ),
        );
      }
    } catch (e) {
      print('Error generating 3D model: $e');
    }
    return null;
  }

  /// Analyze scene and provide suggestions
  Future<Map<String, dynamic>?> analyzeScene({
    required List<MediaLayerNode> layers,
  }) async {
    try {
      final layerInfo = layers.map((l) {
        return {
          'type': l.type.name,
          'name': l.name,
          'position': {'x': l.transform.x, 'y': l.transform.y},
          'size': {'width': l.transform.width, 'height': l.transform.height},
        };
      }).toList();

      final result = await _platformBridge.executeAgentTask(
        'Analyze canvas scene with layers: ${layerInfo.toString()}. Provide composition, balance, and improvement suggestions.',
      );

      if (result['success'] == true) {
        return {
          'suggestions': result['result'],
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      print('Error analyzing scene: $e');
    }
    return null;
  }
}
