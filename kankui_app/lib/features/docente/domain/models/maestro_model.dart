class MaestroModel {
  final String id;
  String usuarioId;
  int aniosExperiencia;
  String? institucionId;
  String? especializacion;
  List<String> materias;
  List<String> gradosAsignados;
  String? telefono;
  String? correoInstitucional;

  MaestroModel({
    required this.id,
    required this.usuarioId,
    this.aniosExperiencia = 0,
    this.institucionId,
    this.especializacion,
    List<String>? materias,
    List<String>? gradosAsignados,
    this.telefono,
    this.correoInstitucional,
  })  : materias = materias ?? [],
        gradosAsignados = gradosAsignados ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'anios_experiencia': aniosExperiencia,
        'institucion_id': institucionId,
        'especializacion': especializacion,
        'materias': materias,
        'grados_asignados': gradosAsignados,
        'telefono': telefono,
        'correo_institucional': correoInstitucional,
      };

  factory MaestroModel.fromJson(Map<String, dynamic> json) =>
      MaestroModel(
        id: json['id'],
        usuarioId: json['usuario_id'],
        aniosExperiencia: json['anios_experiencia'] ?? 0,
        institucionId: json['institucion_id'],
        especializacion: json['especializacion'],
        materias: json['materias'] != null
            ? List<String>.from(json['materias'])
            : [],
        gradosAsignados: json['grados_asignados'] != null
            ? List<String>.from(json['grados_asignados'])
            : [],
        telefono: json['telefono'],
        correoInstitucional: json['correo_institucional'],
      );

  MaestroModel copyWith({
    String? usuarioId,
    int? aniosExperiencia,
    String? institucionId,
    String? especializacion,
    List<String>? materias,
    List<String>? gradosAsignados,
    String? telefono,
    String? correoInstitucional,
  }) {
    return MaestroModel(
      id: id,
      usuarioId: usuarioId ?? this.usuarioId,
      aniosExperiencia: aniosExperiencia ?? this.aniosExperiencia,
      institucionId: institucionId ?? this.institucionId,
      especializacion: especializacion ?? this.especializacion,
      materias: materias ?? this.materias,
      gradosAsignados: gradosAsignados ?? this.gradosAsignados,
      telefono: telefono ?? this.telefono,
      correoInstitucional: correoInstitucional ?? this.correoInstitucional,
    );
  }

  bool get esExperimentado => aniosExperiencia >= 5;
}
