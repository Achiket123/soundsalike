import 'package:flutter/material.dart';
import 'package:soundsalike/widgets/mic_widget.dart';

class RecordingPage extends StatefulWidget {
  static const routePath = '/recording';
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  bool isRecording = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.lightBlue,
            const Color.fromARGB(255, 10, 61, 86),
            Colors.black,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: Container(
                height: height * 0.8,
                width: width * 0.9,
                decoration: BoxDecoration(
                  color: Color(0xFF22ACD2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: MicWidget(
                    key: const Key('mic_widget'),
                    onTap: () async {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
