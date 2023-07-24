import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class VideoRenderder extends StatefulWidget {
  final File videoFile;

  VideoRenderder({Key? key, required this.videoFile}) : super(key: key);

  @override
  _VideoRenderderState createState() => _VideoRenderderState();
}

class _VideoRenderderState extends State<VideoRenderder> {
  late VideoPlayerController _controller;
  bool _finishedPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..addListener(checkVideo)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  void checkVideo() {
    // If the video is playing and the current position is at the end,
    // consider it as finished.
    if (!_controller.value.isBuffering &&
        !_controller.value.isPlaying &&
        _controller.value.position == _controller.value.duration) {
      setState(() {
        _finishedPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _playPause() {
    setState(() {
      if (_finishedPlaying) {
        _controller.seekTo(Duration.zero);
        _controller.play();
        _finishedPlaying = false;
      } else if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(),
          ),
        ),
        Clickable(
          onTap: () {
            _playPause();
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              Expanded(
                child: VideoProgressIndicator(
                  _controller,
                  colors: VideoProgressColors(
                    playedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.black.withOpacity(0.1),
                    bufferedColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  ),
                  allowScrubbing: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
