import '../models/kankuama_info_model.dart';

class KankuamaInfoRepository {
  // Mock data para la demostración
  final List<KankuamaInfoModel> _mockData = [
    KankuamaInfoModel(
      id: 'qr_mochila_kankuama',
      title: 'La Mochila Kankuama',
      description: 'La mochila Kankuama no es solo un objeto, es una representación del pensamiento y del universo. Los hilos entrelazados simbolizan la unión de la comunidad, la conexión con la madre tierra y la resiliencia de nuestro pueblo. Tradicionalmente se teje en fique extraído de la penca maguey.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Mochila_arhuaca.jpg/800px-Mochila_arhuaca.jpg',
      type: 'Arte y Símbolo',
    ),
    KankuamaInfoModel(
      id: 'qr_mito_creacion',
      title: 'Mito de la Creación',
      description: 'En el principio, los padres y madres espirituales tejieron el mundo en la Sierra Nevada. Nosotros, los cuatro pueblos de la sierra (Kankuamos, Arhuacos, Wiwas y Koguis), somos los hermanos mayores, guardianes del equilibrio del universo. La sierra es el corazón del mundo.',
      imageUrl: 'https://live.staticflickr.com/5135/5475143322_cf5e305e94_b.jpg',
      type: 'Historia y Mitología',
    ),
    KankuamaInfoModel(
      id: 'qr_lugares_sagrados',
      title: 'Los Espacios Sagrados',
      description: 'La Sierra Nevada de Santa Marta está llena de espacios sagrados interconectados por la línea negra. En estos lugares, los Mamos realizan pagamentos (tributos espirituales) para mantener la armonía de la naturaleza, pedir permiso a los elementos y sanar el territorio.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Sierra_Nevada_de_Santa_Marta.jpg/1024px-Sierra_Nevada_de_Santa_Marta.jpg',
      type: 'Territorio',
    ),
  ];

  Future<KankuamaInfoModel?> getInfoById(String id) async {
    // Simulamos un pequeño retraso de red para dar efecto de carga
    await Future.delayed(const Duration(milliseconds: 600));
    
    try {
      return _mockData.firstWhere((element) => element.id == id);
    } catch (e) {
      return null; // Retorna null si el ID escaneado no existe
    }
  }
}
