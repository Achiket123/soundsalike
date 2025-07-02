import 'dart:convert';

import 'package:soundsalike/features/recording/domain/entities/fingerprints_entity.dart';

class FingerprintModel extends FingerprintsEntity {
  FingerprintModel({super.Offset, required super.Score, required super.SongID});

  String toJson() =>
      jsonEncode({'SongID': SongID, 'Offset': Offset, 'Score': Score});
  factory FingerprintModel.fromJson(Map<String, dynamic> json) {
    return FingerprintModel(
      Score: json['Score'],
      SongID: json['SongID'],
      Offset: json['Offset'].toDouble(),
    );
  }
}
