import 'dart:async';
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
  final frameSize = 4096;
  final hopSize = 2058;
  final windowSize = 4096;
  final scaleX = 4;
  final scaleY = 1;

  @override
  Future<Either<Exception, void>> startRecording(AudioRecorder recorder) async {
    try {
      debugPrint("Checking microphone permission...");
      final hasPermission = await recorder.hasPermission();
      if (!hasPermission) {
        throw Exception("Microphone permission denied");
      }

      final tempDir = await getTemporaryDirectory();
      debugPrint("Temporary directory path: ${tempDir.path}");

      final filePath = '${tempDir.path}/recording.wav';

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        bitRate: 128000,
        numChannels: 1,
      );

      debugPrint("Starting recording to file: $filePath");

      await recorder.start(config, path: filePath);

      return Right(null);
    } catch (e) {
      debugPrint("Failed to start recording: $e");
      return Left(Exception("Failed to start recording: $e"));
    }
  }

  @override
  Future<Either<Exception, List<FingerprintModel>>> stopRecording(
    AudioRecorder recorder,
  ) async {
    debugPrint("Stopping recording...");
    try {
      final path = await recorder.stop();

      if (path == null) {
        throw Exception("Recording stop failed, no file path returned.");
      }

      final audioFile = File(path);
      if (!await audioFile.exists()) {
        throw Exception("Recorded file does not exist at path: $path");
      }

      debugPrint("Recorded audio saved at: $path");
      debugPrint("File size: ${await audioFile.length()} bytes");
      debugPrint("Preparing to send data to the backend...");

      final url = Uri.parse("${dotenv.env['API_URL']}/search");

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({'Content-Type': 'multipart/form-data'});
      request.files.add(await http.MultipartFile.fromPath('audio', path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      try {
        await audioFile.delete();
        debugPrint("Temporary file deleted successfully.");
      } catch (e) {
        debugPrint("Error deleting temporary file: $e");
      }

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to send data: ${response.statusCode} - ${response.body}",
        );
      } else {
        debugPrint("Data sent successfully. Response: ${response.body}");
        final body = List.from(jsonDecode(response.body));
        List<FingerprintModel> models =
            body.map<FingerprintModel>((e) {
              return FingerprintModel.fromJson(e);
            }).toList();
        if (models.length < 4)
          return Right(models);
        else
          return Right(models.sublist(0, 4));
      }
    } catch (e, stacktrace) {
      debugPrint("Error in stopRecording: $e\n$stacktrace");
      return Left(Exception("Failed to stop recording and send data: $e"));
    }
  }
}
