import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final currentPage = 0.obs;
  final pageCount = 3;

  void goToPage(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < pageCount - 1) {
      currentPage.value++;
    } else {
      finishOnboarding();
    }
  }

  void finishOnboarding() {
    Get.offAllNamed('/login');
  }
}
