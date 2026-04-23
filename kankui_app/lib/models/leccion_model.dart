class LeccionModel {
  final String id;
  String titulo;
  String? categoria;
  List<String> palabras;
  int orden;

  LeccionModel({
    required this.id,
    required this.titulo,
    this.categoria,
    List<String>? palabras,
    this.orden = 0,
  }) : palabras = palabras ?? [];

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'categoria': categoria,
        'palabras': palabras,
        'orden': orden,
      };

  // Factory desde JSON
  factory LeccionModel.fromJson(Map<String, dynamic> json) =>
      LeccionModel(
        id: json['id'],
        titulo: json['titulo'],
        categoria: json['categoria'],
        palabras: json['palabras'] != null
            ? List<String>.from(json['palabras'])
            : [],
        orden: json['orden'] ?? 0,
      );

  // copyWith (recomendado)
  LeccionModel copyWith({
    String? titulo,
    String? categoria,
    List<String>? palabras,
    int? orden,
  }) {
    return LeccionModel(
      id: id,
      titulo: titulo ?? this.titulo,
      categoria: categoria ?? this.categoria,
      palabras: palabras ?? this.palabras,
      orden: orden ?? this.orden,
    );
  }
}