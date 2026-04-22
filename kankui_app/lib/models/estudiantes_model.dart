class EstudianteModel {
  final String id;
  final String usuarioId;
  String? curso;
  int? grupo;
  double promedio;
  String? pin;
  String? maestroId;

  EstudianteModel({
    required this.id,
    required this.usuarioId,
    this.curso,
    this.grupo,
    this.promedio = 0,
    this.pin,
    this.maestroId,
  });

  // Convertir a JSON (para enviar a DB)
  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'curso': curso,
        'grupo': grupo,
        'promedio': promedio,
        'pin': pin,
        'maestro_id': maestroId,
      };

  // Factory desde JSON (desde DB o API)
  factory EstudianteModel.fromJson(Map<String, dynamic> json) =>
      EstudianteModel(
        id: json['id'],
        usuarioId: json['usuario_id'],
        curso: json['curso'],
        grupo: json['grupo'],
        promedio: (json['promedio'] ?? 0).toDouble(),
        pin: json['pin'],
        maestroId: json['maestro_id'],
      );
}