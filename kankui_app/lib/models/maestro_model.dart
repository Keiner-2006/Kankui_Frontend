class MaestroModel {
  final String id;
  String usuarioId;
  int aniosExperiencia;

  MaestroModel({
    required this.id,
    required this.usuarioId,
    this.aniosExperiencia = 0,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'anios_experiencia': aniosExperiencia,
      };

  // Factory desde JSON
  factory MaestroModel.fromJson(Map<String, dynamic> json) =>
      MaestroModel(
        id: json['id'],
        usuarioId: json['usuario_id'],
        aniosExperiencia: json['anios_experiencia'] ?? 0,
      );

  // copyWith
  MaestroModel copyWith({
    String? usuarioId,
    int? aniosExperiencia,
  }) {
    return MaestroModel(
      id: id,
      usuarioId: usuarioId ?? this.usuarioId,
      aniosExperiencia: aniosExperiencia ?? this.aniosExperiencia,
    );
  }

  // 🔥 PRO: lógica útil
  bool get esExperimentado => aniosExperiencia >= 5;
}