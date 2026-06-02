import 'package:get/get.dart';
import 'package:kankui_app/features/learning/data/repositories/categoria_repository.dart';
import 'package:kankui_app/features/learning/domain/models/categoria_model.dart';
import 'package:kankui_app/shared/data/seed/vocablos_data.dart';

class RecursosQrController extends GetxController {
  final CategoriaRepository _categoriaRepo = Get.find();

  final categorias = <CategoriaModel>[].obs;
  final isLoading = true.obs;
  final categoriaSeleccionada = Rxn<CategoriaModel>();
  final objetosDeCategoria = <Vocablo>[].obs;
  final isLoadingObjetos = false.obs;
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    try {
      final data = await _categoriaRepo.getCategorias();
      categorias.assignAll(data);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> seleccionarCategoria(CategoriaModel cat) async {
    categoriaSeleccionada.value = cat;
    isLoadingObjetos.value = true;
    errorMessage.value = null;

    try {
      final objetos = await _categoriaRepo.getVocablosPorCategoria(cat.id);
      objetosDeCategoria.assignAll(objetos);
    } catch (_) {
      errorMessage.value = 'Error al descargar las palabras de la base de datos';
    } finally {
      isLoadingObjetos.value = false;
    }
  }

  void limpiarSeleccion() {
    categoriaSeleccionada.value = null;
    objetosDeCategoria.clear();
  }
}
