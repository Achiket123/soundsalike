import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundsalike/features/recording/domain/entities/fingerprints_entity.dart';
import 'package:soundsalike/features/recording/presentation/bloc/record_bloc.dart';

class MicWidget extends StatefulWidget {
  final double size;
  final int waveCount;
  final Color color;

  const MicWidget({
    super.key,
    this.size = 200.0,
    this.waveCount = 3,
    this.color = const Color(0xFF12827A),
  });

  @override
  State<MicWidget> createState() => _MicWidgetState();
}

class _MicWidgetState extends State<MicWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  // Track whether we are mid-recording so a single tap toggles correctly
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context) {
    if (_isRecording) {
      _isRecording = false;
      _animController
        ..stop()
        ..reset();
      context.read<RecordBloc>().add(const StopRecordingEvent());
    } else {
      _isRecording = true;
      _animController.repeat();
      context.read<RecordBloc>().add(const StartRecordingEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecordBloc, RecordState>(
      listener: (context, state) {
        if (state is RecordingError) {
          // Make sure animation stops on error
          _isRecording = false;
          _animController
            ..stop()
            ..reset();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red[700],
            ),
          );
        } else if (state is RecordingStopped) {
          _isRecording = false;
          _animController
            ..stop()
            ..reset();
          if (state.data.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Song not recognised — try again')),
            );
          } else {
            _showResultsSheet(context, state.data);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is RecordingLoading;

        if (isLoading) {
          return SizedBox(
            width: widget.size * 0.5,
            height: widget.size * 0.5,
            child: CircularProgressIndicator(
              color: widget.color,
              strokeWidth: 3,
            ),
          );
        }

        // Disable tap while loading
        return GestureDetector(
          onTap: () => _handleTap(context),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isRecording)
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (_, __) => CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: CirclePainter(
                        animation: _animController,
                        waveCount: widget.waveCount,
                        baseColor: widget.color,
                      ),
                    ),
                  ),
                Container(
                  width: widget.size * 0.5,
                  height: widget.size * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? widget.color.withOpacity(0.85)
                        : widget.color,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.4),
                        blurRadius: _isRecording ? 20 : 8,
                        spreadRadius: _isRecording ? 4 : 0,
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: widget.size * 0.22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResultsSheet(BuildContext context, List<FingerprintsEntity> results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultsSheet(results: results),
    );
  }
}

// ── Results bottom sheet ────────────────────────────────────────────────────

class _ResultsSheet extends StatelessWidget {
  final List<FingerprintsEntity> results;
  const _ResultsSheet({required this.results});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Results',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: results.length,
                itemBuilder: (_, i) => _ResultCard(result: results[i], rank: i + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final FingerprintsEntity result;
  final int rank;
  const _ResultCard({required this.result, required this.rank});

  Color get _confidenceColor {
    switch (result.confidence) {
      case 'high':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String get _offsetLabel {
    final mins = (result.offsetSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (result.offsetSeconds % 60).toStringAsFixed(0).padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _confidenceColor.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _confidenceColor.withOpacity(0.15),
              border: Border.all(color: _confidenceColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: _confidenceColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Song info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.songId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      'at $_offsetLabel',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.bar_chart_rounded,
                        size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      'score ${result.score.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Confidence chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _confidenceColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.confidence,
              style: TextStyle(
                color: _confidenceColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wave animation painter ──────────────────────────────────────────────────

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
    final center = size.center(Offset.zero);
    final maxRadius = min(size.width, size.height) / 2;
    final baseRadius = maxRadius * 0.5;

    for (int wave = 0; wave < waveCount; wave++) {
      final progress = (animation.value + wave / waveCount) % 1.0;
      final radius = baseRadius + (maxRadius - baseRadius) * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final color =
          Color.lerp(baseColor, const Color(0xFF4DD0E1), progress)!;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(CirclePainter old) => true;
}