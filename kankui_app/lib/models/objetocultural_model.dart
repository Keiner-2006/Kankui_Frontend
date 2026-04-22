class ObjetoCulturalModel {
  final String id;
  String nombre;
  String? codigoQr;
  String? significado;
  String? patron;
  String? audioMayorUrl;
  String? imagenUrl;
  String? categoriaId;

  ObjetoCulturalModel({
    required this.id,
    required this.nombre,
    this.codigoQr,
    this.significado,
    this.patron,
    this.audioMayorUrl,
    this.imagenUrl,
    this.categoriaId,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'codigo_qr': codigoQr,
        'significado': significado,
        'patron': patron,
        'audio_mayor_url': audioMayorUrl,
        'imagen_url': imagenUrl,
        'categoria_id': categoriaId,
      };

  // Factory desde JSON
  factory ObjetoCulturalModel.fromJson(Map<String, dynamic> json) =>
      ObjetoCulturalModel(
        id: json['id'],
        nombre: json['nombre'],
        codigoQr: json['codigo_qr'],
        significado: json['significado'],
        patron: json['patron'],
        audioMayorUrl: json['audio_mayor_url'],
        imagenUrl: json['imagen_url'],
        categoriaId: json['categoria_id'],
      );

  // copyWith (recomendado)
  ObjetoCulturalModel copyWith({
    String? nombre,
    String? codigoQr,
    String? significado,
    String? patron,
    String? audioMayorUrl,
    String? imagenUrl,
    String? categoriaId,
  }) {
    return ObjetoCulturalModel(
      id: id,
      nombre: nombre ?? this.nombre,
      codigoQr: codigoQr ?? this.codigoQr,
      significado: significado ?? this.significado,
      patron: patron ?? this.patron,
      audioMayorUrl: audioMayorUrl ?? this.audioMayorUrl,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }
}