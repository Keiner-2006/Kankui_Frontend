class InstitucionModel {
  final String id;
  String nombre;
  DateTime createdAt;

  InstitucionModel({
    required this.id,
    required this.nombre,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'created_at': createdAt.toIso8601String(),
      };

  // Factory desde JSON
  factory InstitucionModel.fromJson(Map<String, dynamic> json) =>
      InstitucionModel(
        id: json['id'],
        nombre: json['nombre'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
      );

  // copyWith (recomendado)
  InstitucionModel copyWith({
    String? nombre,
    DateTime? createdAt,
  }) {
    return InstitucionModel(
      id: id,
      nombre: nombre ?? this.nombre,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}