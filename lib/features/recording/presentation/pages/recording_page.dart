import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundsalike/features/recording/presentation/bloc/record_bloc.dart';
import 'package:soundsalike/widgets/mic_widget.dart';

class RecordingPage extends StatelessWidget {
  static const routePath = '/';
  const RecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF29B6F6),
            Color(0xFF0A3D56),
            Colors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: const [
                    Text(
                      'SoundsAlike',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tap the mic to identify a song',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Mic card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22ACD2).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: BlocBuilder<RecordBloc, RecordState>(
                      builder: (context, state) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MicWidget(size: size.width * 0.55),
                            const SizedBox(height: 32),
                            _statusText(state),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusText(RecordState state) {
    String text;
    Color color;

    if (state is RecordingInProgress) {
      text = 'Listening… tap to stop';
      color = Colors.greenAccent;
    } else if (state is RecordingLoading) {
      text = 'Processing…';
      color = Colors.white70;
    } else if (state is RecordingError) {
      text = 'Error — try again';
      color = Colors.redAccent;
    } else {
      text = 'Tap the mic to start';
      color = Colors.white60;
    }

    return Text(
      text,
      style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500),
    );
  }
}