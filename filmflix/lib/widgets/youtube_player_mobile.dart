import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        return Stack(
          children: [
            player,
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
    _fsController.dispose();
    super.dispose();
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