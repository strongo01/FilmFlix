import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cinetrackr/l10n/app_localizations.dart';

class YouTubePlayerWidget extends StatefulWidget {
  final String videoId;

  const YouTubePlayerWidget({
    Key? key,
    required this.videoId,
  }) : super(key: key);

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  late YoutubePlayerController _controller;
  bool _error150Handled = false;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    // add listener to surface playback errors for debugging (e.g. code 150)
    _controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  void _controllerListener() {
    try {
      final val = _controller.value;
      // many versions expose an `errorCode` int on the value
      final dynamic err = (val as dynamic).errorCode;
      if (err != null) {
        try {
          final code = int.tryParse(err.toString()) ?? 0;
          if (code != 0) {
            debugPrint('YouTube player error (inline): code=$code for video ${widget.videoId}');
            if (code == 150 && !_error150Handled) {
              _error150Handled = true;
              debugPrint('Playback disabled by video owner (error 150) for video ${widget.videoId} — offering external fallback');
              if (mounted) {
                final snack = SnackBar(
                  content: Text(AppLocalizations.of(context)!.playbackDisabledByVideoOwner),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context)!.open,
                    onPressed: () async {
                      final url = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');
                      try {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        debugPrint('Failed to open external YouTube: $e');
                      }
                    },
                  ),
                );
                try {
                  ScaffoldMessenger.of(context).showSnackBar(snack);
                } catch (e) {
                  debugPrint('Failed to show snackbar: $e');
                }
              }
            }
          }
        } catch (e) {
          debugPrint('YouTube player error parsing code: $e');
        }
      }
    } catch (e) {
      debugPrint('YouTube controller listener failed: $e');
    }
  }

  Future<void> _enterFullscreen() async {
    final currentPosition = _controller.value.position;
    final isPlaying = _controller.value.isPlaying;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenPlayer(
          videoId: widget.videoId,
          startAt: currentPosition,
          wasPlaying: isPlaying,
        ),
      ),
    );

    // Na terugkomst van fullscreen, de UI herstellen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
      builder: (context, player) {
        // Wrap player in GestureDetector so tapping opens external YouTube
        final gesturePlayer = GestureDetector(
          onTap: () async {
            final url = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');
            try {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Failed to open external YouTube from tap: $e');
            }
          },
          child: player,
        );

        return Stack(
          children: [
            gesturePlayer,
            Positioned(
              right: 8,
              bottom: 8,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black54,
                onPressed: _enterFullscreen,
                child: const Icon(Icons.fullscreen, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FullScreenPlayer extends StatefulWidget {
  final String videoId;
  final Duration startAt;
  final bool wasPlaying;

  const FullScreenPlayer({
    Key? key,
    required this.videoId,
    this.startAt = Duration.zero,
    this.wasPlaying = false,
  }) : super(key: key);

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer>
    with WidgetsBindingObserver {
  late YoutubePlayerController _fsController;
  bool _isCurrentlyFullscreen = true;
  bool _error150Handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fsController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.wasPlaying,
        mute: false,
        startAt: widget.startAt.inSeconds,
      ),
    );
    _fsController.addListener(_fsControllerListener);
    try {
      _isCurrentlyFullscreen = _fsController.value.isFullScreen;
    } catch (_) {
      _isCurrentlyFullscreen = true;
    }

    // Landscape + immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exitFullscreen();
    _fsController.removeListener(_fsControllerListener);
    _fsController.dispose();
    super.dispose();
  }

  void _fsControllerListener() {
    try {
      final val = _fsController.value;
      final dynamic err = (val as dynamic).errorCode;
            // detect player's own fullscreen toggle: if it becomes false, close route
            try {
              final dynamic isFs = (val as dynamic).isFullScreen;
              if (isFs is bool) {
                if (!isFs && _isCurrentlyFullscreen) {
                  _isCurrentlyFullscreen = false;
                  if (mounted) {
                    _exitFullscreen();
                    try {
                      Navigator.of(context).pop();
                    } catch (_) {}
                  }
                } else if (isFs && !_isCurrentlyFullscreen) {
                  _isCurrentlyFullscreen = true;
                }
              }
            } catch (_) {}
      if (err != null) {
        try {
          final code = int.tryParse(err.toString()) ?? 0;
          if (code != 0) {
            debugPrint('YouTube player error (fullscreen): code=$code for video ${widget.videoId}');
            if (code == 150 && !_error150Handled) {
              _error150Handled = true;
              debugPrint('Playback disabled by video owner (error 150) in fullscreen for video ${widget.videoId} — offering external fallback');
              if (mounted) {
                final snack = SnackBar(
                  content: Text(AppLocalizations.of(context)!.playbackDisabledByVideoOwner),
                  action: SnackBarAction(
                    label: AppLocalizations.of(context)!.open,
                    onPressed: () async {
                      final url = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');
                      try {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        debugPrint('Failed to open external YouTube from fullscreen: $e');
                      }
                    },
                  ),
                );
                try {
                  ScaffoldMessenger.of(context).showSnackBar(snack);
                } catch (e) {
                  debugPrint('Failed to show snackbar (fullscreen): $e');
                }
              }
            }
          }
        } catch (e) {
          debugPrint('YouTube fs player error parsing code: $e');
        }
      }
    } catch (e) {
      debugPrint('YouTube fs controller listener failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _exitFullscreen();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _exitFullscreen();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: YoutubePlayer(
                controller: _fsController,
              ),
            ),

            /// Back button
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  _exitFullscreen();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}