class EventoHistoricoModel {
  final String id;
  String titulo;
  String? descripcion;
  String? anio;
  String? era;
  String? imagenUrl;
  String? leccionId;

  EventoHistoricoModel({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.anio,
    this.era,
    this.imagenUrl,
    this.leccionId,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'anio': anio,
        'era': era,
        'imagen_url': imagenUrl,
        'leccion_id': leccionId,
      };

  // Factory desde JSON
  factory EventoHistoricoModel.fromJson(Map<String, dynamic> json) =>
      EventoHistoricoModel(
        id: json['id'],
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        anio: json['anio'],
        era: json['era'],
        imagenUrl: json['imagen_url'],
        leccionId: json['leccion_id'],
      );

  // copyWith (recomendado)
  EventoHistoricoModel copyWith({
    String? titulo,
    String? descripcion,
    String? anio,
    String? era,
    String? imagenUrl,
    String? leccionId,
  }) {
    return EventoHistoricoModel(
      id: id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      anio: anio ?? this.anio,
      era: era ?? this.era,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      leccionId: leccionId ?? this.leccionId,
    );
  }
}