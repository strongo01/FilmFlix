import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubePlayerWidget extends StatefulWidget {
  final String videoId;
  const YouTubePlayerWidget({Key? key, required this.videoId}) : super(key: key);

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
        mute: false,
      ),
      autoPlay: false,
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        YoutubePlayer(
          controller: _controller,
        ),
          // Custom fullscreen button to enter immersive fullscreen
        Positioned(
            right: 8,
            bottom: 8,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black54,
              onPressed: () => _enterFullscreen(context),
              child: const Icon(Icons.fullscreen, color: Colors.white),
            ),
        ),
      ],
    );
  }

  Future<void> _enterFullscreen(BuildContext context) async {
    // Push fullscreen route; the route handles setting/restoring UI & orientation
    await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return _FullScreenPlayer(controller: _controller);
    }));
  }

}

class _FullScreenPlayer extends StatefulWidget {
  final YoutubePlayerController controller;

  const _FullScreenPlayer({Key? key, required this.controller}) : super(key: key);

  @override
  State<_FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<_FullScreenPlayer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('FullScreenPlayer: initState — entering fullscreen');
    // Enter immersive fullscreen and force landscape when this route is shown
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    debugPrint('FullScreenPlayer: dispose — leaving fullscreen');
    WidgetsBinding.instance.removeObserver(this);
    // Restore system UI and portrait orientation when leaving fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If app goes to background while in fullscreen, try to restore UI/orientation
    if (state == AppLifecycleState.paused) {
      debugPrint('FullScreenPlayer: app paused — restoring orientation');
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: YoutubePlayer(controller: widget.controller),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
