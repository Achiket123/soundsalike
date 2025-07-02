import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundsalike/features/recording/presentation/bloc/record_bloc.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MicWidget extends StatefulWidget {
  final double size;
  final int waveCount;
  final Color color;
  final Function onTap;
  const MicWidget({
    super.key,
    this.size = 200.0,
    this.waveCount = 3,
    this.color = const Color(0xFF12827A),
    required this.onTap,
  });

  @override
  State<MicWidget> createState() {
    return _MicWidgetState();
  }
}

class _MicWidgetState extends State<MicWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isAnimating = false;
  List<YoutubePlayerController> controllers = [];
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAnimation() {
    setState(() {
      _isAnimating = !_isAnimating;
      if (_isAnimating) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecordBloc, RecordState>(
      listener: (context, state) {
        if (state is RecordingError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is RecordingStopped) {
          if (state.data.isNotEmpty) {
            showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, secondaryAnimation) {
                for (var e in state.data) {
                  final controller = YoutubePlayerController(
                    params: YoutubePlayerParams(
                      showControls: true,

                      showFullscreenButton: false,
                    ),
                  );
                  debugPrint(e.SongID);
                  controller.loadVideoById(videoId: e.SongID);
                  controller.cueVideoById(videoId: e.SongID);
                  controllers.add(controller);
                }
                return Material(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: //[YoutubePlayer(controller: controllers[0])],
                              [
                            Center(
                              child: Icon(Icons.check, color: Colors.green),
                            ),
                            ...controllers.map<Widget>((controller) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.teal.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: YoutubePlayer(
                                  controller: controller,
                                  aspectRatio: 16 / 9,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Song Not Found')));
          }
        }
      },
      builder: (context, state) {
        if (state is RecordingInProgress) {
          return GestureDetector(
            onTap: () {
              if (!_isAnimating) {
                context.read<RecordBloc>().add(StartRecordingEvent());
              } else {
                context.read<RecordBloc>().add(StopRecordingEvent());
              }
              _toggleAnimation();

              widget.onTap();
            },
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isAnimating)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: CirclePainter(
                            animation: _animationController,
                            waveCount: widget.waveCount,
                            baseColor: widget.color,
                          ),
                        );
                      },
                    ),

                  Container(
                    width: widget.size * 0.5,
                    height: widget.size * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                    ),
                  ),

                  Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: widget.size * 0.25,
                  ),
                ],
              ),
            ),
          );
        } else if (state is RecordingLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: widget.color,
              strokeWidth: 2.0,
            ),
          );
        }
        return GestureDetector(
          onTap: () {
            if (!_isAnimating) {
              context.read<RecordBloc>().add(StartRecordingEvent());
            } else {
              context.read<RecordBloc>().add(StopRecordingEvent());
            }
            _toggleAnimation();
            widget.onTap();
          },
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isAnimating)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: CirclePainter(
                          animation: _animationController,
                          waveCount: widget.waveCount,
                          baseColor: widget.color,
                        ),
                      );
                    },
                  ),

                Container(
                  width: widget.size * 0.5,
                  height: widget.size * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),

                Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: widget.size * 0.25,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CirclePainter extends CustomPainter {
  final Animation<double> animation;
  final int waveCount;
  final Color baseColor;

  CirclePainter({
    required this.animation,
    required this.waveCount,
    required this.baseColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    final center = rect.center;
    final maxRadius = min(size.width, size.height) / 2;

    final baseRadius = maxRadius * 0.5;

    for (int wave = 0; wave < waveCount; wave++) {
      final progress = (animation.value + (wave / waveCount)) % 1.0;
      final currentRadius = baseRadius + (maxRadius - baseRadius) * progress;

      final opacity = 1.0 - progress;

      final waveColor =
          Color.lerp(baseColor, const Color(0xFF4DD0E1), progress)!;

      final paint =
          Paint()
            ..color = waveColor.withValues(alpha: max(0, opacity))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0;

      if (currentRadius > baseRadius) {
        canvas.drawCircle(center, currentRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    return true;
  }
}
