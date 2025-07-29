import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GeneralService extends GetxService {
  var backgroundUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLandingBackground();
  }

  Future<void> fetchLandingBackground() async {
    try {
      print('Fetching backgrounds...');
      final response = await Supabase.instance.client
          .from('backgrounds')
          .select('image_url')
          .limit(1)
          .maybeSingle();

      print('Response: $response');

      if (response != null && response['image_url'] != null) {
        backgroundUrl.value = response['image_url'];
      } else {
        print('No background image found.');
      }
    } catch (e) {
      print('Error fetching background image: $e');
    }
  }
}
