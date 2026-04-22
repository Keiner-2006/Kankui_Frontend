class CategoriaModel {
  final String id;
  String nombre;
  String? icono;
  int totalPalabras;
  int orden;

  CategoriaModel({
    required this.id,
    required this.nombre,
    this.icono,
    this.totalPalabras = 0,
    this.orden = 0,
  });

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'icono': icono,
        'total_palabras': totalPalabras,
        'orden': orden,
      };

  // Factory desde JSON
  factory CategoriaModel.fromJson(Map<String, dynamic> json) =>
      CategoriaModel(
        id: json['id'],
        nombre: json['nombre'],
        icono: json['icono'],
        totalPalabras: json['total_palabras'] ?? 0,
        orden: json['orden'] ?? 0,
      );

  // copyWith (recomendado)
  CategoriaModel copyWith({
    String? nombre,
    String? icono,
    int? totalPalabras,
    int? orden,
  }) {
    return CategoriaModel(
      id: id,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      totalPalabras: totalPalabras ?? this.totalPalabras,
      orden: orden ?? this.orden,
    );
  }
}