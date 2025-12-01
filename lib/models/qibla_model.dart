class QiblaModel {
  final double direction;

  QiblaModel({required this.direction});

  factory QiblaModel.fromJson(Map<String, dynamic> json) {
    return QiblaModel(
      direction: json["data"]["direction"] * 1.0, // pastikan double
    );
  }
}
