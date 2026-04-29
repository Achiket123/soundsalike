import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:soundsalike/features/recording/data/models/fingerprints_model.dart';

abstract class RecordingDataSource {
  Future<Either<Exception, void>> startRecording(AudioRecorder recorder);
  Future<Either<Exception, List<FingerprintModel>>> stopRecording(
    AudioRecorder recorder,
  );
}

class RecordingDataSourceImpl implements RecordingDataSource {
  @override
  Future<Either<Exception, void>> startRecording(
    AudioRecorder recorder,
  ) async {
    try {
      final hasPermission = await recorder.hasPermission();
      if (!hasPermission) {
        return Left(Exception('Microphone permission denied'));
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/shazam_query.wav';

      // Record at 44100 Hz mono WAV — the backend downsamples to 8 kHz itself.
      // Higher source rate = better lowpass anti-aliasing before downsampling.
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        numChannels: 1,
      );

      await recorder.start(config, path: filePath);
      debugPrint('[rec] started → $filePath');
      return const Right(null);
    } catch (e) {
      debugPrint('[rec] startRecording error: $e');
      return Left(Exception('Failed to start recording: $e'));
    }
  }

  @override
  Future<Either<Exception, List<FingerprintModel>>> stopRecording(
    AudioRecorder recorder,
  ) async {
    try {
      final path = await recorder.stop();
      if (path == null) {
        return Left(Exception('Recording stop returned no file path'));
      }

      final audioFile = File(path);
      if (!await audioFile.exists()) {
        return Left(Exception('Recorded file missing at: $path'));
      }

      debugPrint('[rec] saved ${await audioFile.length()} bytes → $path');

      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null || apiUrl.isEmpty) {
        return Left(Exception('API_URL not set in .env'));
      }

      final url = Uri.parse('$apiUrl/search');
      final request = http.MultipartRequest('POST', url);
      // Field name must be 'audio' — matches the backend's MultipartForm.File["audio"]
      request.files.add(await http.MultipartFile.fromPath('audio', path));

      debugPrint('[rec] POST $url');
      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timed out after 30s'),
      );
      final response = await http.Response.fromStream(streamed);

      // Clean up temp file regardless of outcome
      try {
        await audioFile.delete();
      } catch (_) {}

      if (response.statusCode != 200) {
        return Left(Exception(
          'Server error ${response.statusCode}: ${response.body}',
        ));
      }

      debugPrint('[rec] response: ${response.body}');

      final decoded = jsonDecode(response.body);

      // Backend returns null when no songs are in DB — treat as empty list
      if (decoded == null) return const Right([]);

      final body = decoded as List<dynamic>;
      final models = body
          .map((e) => FingerprintModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Filter to only high/medium confidence results before returning
      final confident = models
          .where((m) => m.confidence == 'high' || m.confidence == 'medium')
          .toList();

      // Fall back to all results if nothing clears the confidence bar
      return Right(confident.isNotEmpty ? confident : models);
    } catch (e, st) {
      debugPrint('[rec] stopRecording error: $e\n$st');
      return Left(Exception('Failed to recognise song: $e'));
    }
  }
}