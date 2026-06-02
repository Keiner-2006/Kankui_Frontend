import 'package:get/get.dart';
import 'package:kankui_app/features/qr_scanner/domain/models/kankuama_info_model.dart';
import 'package:kankui_app/features/qr_scanner/data/repositories/kankuama_info_repository.dart';

class KankuamaInfoController extends GetxController {
  final KankuamaInfoRepository _repository = Get.find();

  final isLoading = true.obs;
  final info = Rxn<KankuamaInfoModel>();

  late final String qrCodeId;

  @override
  void onInit() {
    super.onInit();
    qrCodeId = (Get.arguments as Map)['qrCodeId'] as String;
    fetchInfo();
  }

  Future<void> fetchInfo() async {
    try {
      final data = await _repository.getInfoById(qrCodeId);
      info.value = data;
    } finally {
      isLoading.value = false;
    }
  }
}
