import 'package:soundsalike/features/recording/domain/entities/fingerprints_entity.dart';

class FingerprintModel extends FingerprintsEntity {
  const FingerprintModel({
    required super.score,
    required super.offsetSeconds,
    required super.songId,
    required super.confidence,
  });

  // Backend now returns snake_case keys and confidence field:
  // { "song_id": "...", "score": 32.0, "offset_seconds": 12.5, "confidence": "high" }
  factory FingerprintModel.fromJson(Map<String, dynamic> json) {
    return FingerprintModel(
      songId: json['song_id'] as String,
      score: (json['score'] as num).toDouble(),
      offsetSeconds: (json['offset_seconds'] as num? ?? 0).toDouble(),
      confidence: json['confidence'] as String? ?? 'low',
    );
  }
}