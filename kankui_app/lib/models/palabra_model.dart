class PalabraModel {
  final String id;
  String termino;
  String? pronunciacion;
  String? traduccion;
  String? audioUrl;
  String? categoriaId;

  PalabraModel({
    required this.id,
    required this.termino,
    this.pronunciacion,
    this.traduccion,
    this.audioUrl,
    this.categoriaId,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'termino': termino,
        'pronunciacion': pronunciacion,
        'traduccion': traduccion,
        'audio_url': audioUrl,
        'categoria_id': categoriaId,
      };

  // Factory desde JSON
  factory PalabraModel.fromJson(Map<String, dynamic> json) =>
      PalabraModel(
        id: json['id'],
        termino: json['termino'],
        pronunciacion: json['pronunciacion'],
        traduccion: json['traduccion'],
        audioUrl: json['audio_url'],
        categoriaId: json['categoria_id'],
      );

  // copyWith (recomendado)
  PalabraModel copyWith({
    String? termino,
    String? pronunciacion,
    String? traduccion,
    String? audioUrl,
    String? categoriaId,
  }) {
    return PalabraModel(
      id: id,
      termino: termino ?? this.termino,
      pronunciacion: pronunciacion ?? this.pronunciacion,
      traduccion: traduccion ?? this.traduccion,
      audioUrl: audioUrl ?? this.audioUrl,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }
}