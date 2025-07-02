import 'dart:convert';

class FingerprintsEntity {
  final int Score;
  double? Offset;
  final String SongID;

  FingerprintsEntity({
    required this.Score,
    required this.SongID,
    this.Offset,
  });

  String toJson() => jsonEncode({
    'Score': Score,
    'Offset': Offset,
    'SongID': SongID,
  });
  
}
