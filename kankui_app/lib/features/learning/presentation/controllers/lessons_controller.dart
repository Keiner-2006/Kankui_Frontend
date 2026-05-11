import 'package:get/get.dart';
import 'package:kankui_app/features/learning/domain/models/categoria_model.dart';
import 'package:kankui_app/shared/data/user_progress.dart';
import 'package:kankui_app/features/learning/data/repositories/categoria_repository.dart';
import 'package:kankui_app/shared/data/local/palabra_local.dart';
import 'package:kankui_app/shared/data/seed/vocablos_data.dart';

class LessonsController extends GetxController {
  final CategoriaRepository _categoriaRepo = Get.find();
  final PalabraLocal _palabraLocal = PalabraLocal();

  final categorias = <CategoriaModel>[].obs;
  final loading = true.obs;
  final userProgress = Rxn<UserProgress>();

  @override
  void onInit() {
    super.onInit();
    fetchCategorias();
  }

  Future<void> fetchCategorias() async {
    final data = await _categoriaRepo.getCategorias();
    categorias.assignAll(data);
    loading.value = false;
  }

  double calcularProgresoCategoria(String categoriaId) {
    if (categoriaId.contains('saludos')) return 0.75;
    if (categoriaId.contains('familia')) return 0.6;
    if (categoriaId.contains('naturaleza')) return 0.4;
    if (categoriaId.contains('objetos')) return 0.25;
    if (categoriaId.contains('numeros')) return 0.5;
    return 0.1;
  }
}
