class FingerprintsEntity {
  final double score;
  final double offsetSeconds;
  final String songId;
  final String confidence;

  const FingerprintsEntity({
    required this.score,
    required this.offsetSeconds,
    required this.songId,
    required this.confidence,
  });
}