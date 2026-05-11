class Palabra {
  final String id;
  final String termino;
  final String pronunciacion;
  final String traduccion;
  final String? audioUrl;
  final String? categoriaId;

  Palabra({
    required this.id,
    required this.termino,
    required this.pronunciacion,
    required this.traduccion,
    this.audioUrl,
    this.categoriaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'termino': termino,
      'pronunciacion': pronunciacion,
      'traduccion': traduccion,
      'audio_url': audioUrl,
      'categoria_id': categoriaId,
    };
  }

  factory Palabra.fromMap(Map<String, dynamic> map) {
    return Palabra(
      id: map['id'],
      termino: map['termino'],
      pronunciacion: map['pronunciacion'] ?? '',
      traduccion: map['traduccion'],
      audioUrl: map['audio_url'],
      categoriaId: map['categoria_id'],
    );
  }
}
