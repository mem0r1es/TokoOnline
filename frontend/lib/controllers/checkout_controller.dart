
import 'package:flutter_web/models/info_user.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  var selectedAddressId = ''.obs;
  var selectedAddressUser = Rxn<InfoUser>();
  var selectedPayment = 'Direct bank transfer'.obs;
}
