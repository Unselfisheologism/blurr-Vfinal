import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/document_item.dart';

/// Audio player widget for Learning Platform
/// 
/// Provides audio playback controls for AI-generated study guides
/// with speed control, progress tracking, and playback features.
class AudioPlayerWidget extends StatefulWidget {
  final AudioOverview audioOverview;

  const AudioPlayerWidget({
    Key? key,
    required this.audioOverview,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  double _currentPosition = 0.0;
  double _duration = 0.0;
  double _playbackSpeed = 1.0;
  
  // Stream subscriptions
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _progressController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    
    // Setup progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));

    // Setup audio player
    try {
      // Request audio permission
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        _showPermissionDeniedMessage();
        return;
      }

      // Set audio source
      await _audioPlayer.setFilePath(widget.audioOverview.filePath);
      
      // Setup stream listeners
      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentPosition = position.inMilliseconds / 1000.0;
          _progressController.value = _duration > 0 ? 
            _currentPosition / _duration : 0.0;
        });
      });

      _durationSubscription = _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          setState(() {
            _duration = duration.inMilliseconds / 1000.0;
          });
        }
      });

      _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
                     state.processingState == ProcessingState.buffering;
          
          if (state.processingState == ProcessingState.error) {
            _hasError = true;
            _errorMessage = 'Audio playback error';
          }
        });
      });

      setState(() {
        _isLoading = false;
        _hasError = false;
      });

      // Set initial speed
      await _audioPlayer.setSpeed(_playbackSpeed);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load audio: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Audio overview header
        _buildHeader(),
        
        // Waveform visualization (placeholder)
        _buildWaveformPlaceholder(),
        
        // Progress bar and time display
        _buildProgressControls(),
        
        // Main playback controls
        _buildPlaybackControls(),
        
        // Additional controls
        _buildAdditionalControls(),
        
        // Error state
        if (_hasError) _buildErrorState(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.headphones,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Study Guide',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.audioOverview.title,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _showOptionsMenu,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _formatDuration(widget.audioOverview.duration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.speed, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${_playbackSpeed}x',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformPlaceholder() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (index) {
            final height = (index % 4 == 0) ? 80.0 : 
                          (index % 4 == 1) ? 40.0 :
                          (index % 4 == 2) ? 60.0 : 20.0;
            
            return AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final progress = _progressAnimation.value;
                final isActive = (index / 20.0) <= progress;
                
                return Container(
                  width: 3,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isActive 
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProgressControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Progress slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Colors.grey[300],
              thumbColor: Theme.of(context).primaryColor,
              overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _currentPosition.clamp(0.0, _duration),
              min: 0.0,
              max: _duration,
              onChanged: _isLoading || _hasError ? null : (value) {
                setState(() {
                  _currentPosition = value;
                });
              },
              onChangeEnd: _isLoading || _hasError ? null : (value) {
                _seekTo(value);
              },
            ),
          ),
          
          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatTime(_currentPosition)),
              Text(_formatTime(_duration)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rewind 15 seconds
          _buildControlButton(
            icon: Icons.replay_15,
            tooltip: 'Rewind 15 seconds',
            onPressed: _isLoading || _hasError ? null : _rewind15,
          ),
          
          // Play/Pause
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: _isLoading 
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
              onPressed: _isLoading || _hasError ? null : _togglePlayPause,
            ),
          ),
          
          // Forward 15 seconds
          _buildControlButton(
            icon: Icons.forward_15,
            tooltip: 'Forward 15 seconds',
            onPressed: _isLoading || _hasError ? null : _forward15,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Speed control
          Text('Speed:', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: 8),
          DropdownButton<double>(
            value: _playbackSpeed,
            onChanged: _isLoading || _hasError ? null : (speed) {
              if (speed != null) {
                setPlaybackSpeed(speed);
              }
            },
            items: const [
              DropdownMenuItem(value: 0.5, child: Text('0.5x')),
              DropdownMenuItem(value: 0.75, child: Text('0.75x')),
              DropdownMenuItem(value: 1.0, child: Text('1x')),
              DropdownMenuItem(value: 1.25, child: Text('1.25x')),
              DropdownMenuItem(value: 1.5, child: Text('1.5x')),
              DropdownMenuItem(value: 2.0, child: Text('2x')),
            ],
          ),
          
          const Spacer(),
          
          // Loop control
          IconButton(
            icon: const Icon(Icons.loop),
            tooltip: 'Loop playback',
            onPressed: _isLoading || _hasError ? null : _toggleLoop,
          ),
          
          // Sleep timer
          IconButton(
            icon: const Icon(Icons.timer),
            tooltip: 'Sleep timer',
            onPressed: _isLoading || _hasError ? null : _showSleepTimerDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        iconSize: 32,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(
            'Playback Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[600]),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = '';
              });
              _initializeAudioPlayer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Playback control methods
  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Playback failed: $e';
      });
    }
  }

  Future<void> _seekTo(double seconds) async {
    try {
      await _audioPlayer.seek(Duration(seconds: seconds.toInt()));
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Seek failed: $e';
      });
    }
  }

  Future<void> _rewind15() async {
    final newPosition = (_currentPosition - 15).clamp(0.0, _duration);
    await _seekTo(newPosition);
  }

  Future<void> _forward15() async {
    final newPosition = (_currentPosition + 15).clamp(0.0, _duration);
    await _seekTo(newPosition);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
      setState(() {
        _playbackSpeed = speed;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change speed: $e')),
      );
    }
  }

  Future<void> _toggleLoop() async {
    try {
      await _audioPlayer.setLoopMode(
        _audioPlayer.loopMode == LoopMode.one ? LoopMode.off : LoopMode.one,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle loop: $e')),
      );
    }
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.timer_off),
              title: const Text('Stop in 15 minutes'),
              onTap: () {
                Navigator.pop(context);
                _setSleepTimer(const Duration(minutes: 15));
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Stop in 30 minutes'),
              onTap: () {
                Navigator.pop(context);
                _setSleepTimer(const Duration(minutes: 30));
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Stop in 60 minutes'),
              onTap: () {
                Navigator.pop(context);
                _setSleepTimer(const Duration(hours: 1));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setSleepTimer(Duration duration) {
    Future.delayed(duration, () {
      if (mounted) {
        _audioPlayer.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sleep timer ended')),
        );
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Audio will stop in ${duration.inMinutes} minutes')),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Audio Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Audio'),
              onTap: () {
                Navigator.pop(context);
                _shareAudio();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download Audio'),
              onTap: () {
                Navigator.pop(context);
                _downloadAudio();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Audio'),
              onTap: () {
                Navigator.pop(context);
                _deleteAudio();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareAudio() {
    // TODO: Implement audio sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing feature coming soon')),
    );
  }

  void _downloadAudio() {
    // TODO: Implement audio download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download feature coming soon')),
    );
  }

  void _deleteAudio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Audio'),
        content: const Text('Are you sure you want to delete this audio overview?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio playback permission denied'),
        backgroundColor: Colors.orange,
      ),
    );
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Audio permission required for playback';
    });
  }

  // Utility methods
  String _formatTime(double seconds) {
    if (seconds.isNaN || seconds.isInfinite) return '--:--';
    final minutes = seconds.floor() ~/ 60;
    final remainingSeconds = (seconds % 60).floor();
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds <= 0) return '--:--';
    final seconds = (milliseconds / 1000).floor();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}