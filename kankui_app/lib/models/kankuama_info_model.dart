class KankuamaInfoModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? type;

  KankuamaInfoModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.type,
  });

  factory KankuamaInfoModel.fromJson(Map<String, dynamic> json) {
    return KankuamaInfoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      type: json['type'],
    );
  }
}
