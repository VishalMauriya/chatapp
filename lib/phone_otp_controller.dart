import 'package:chatapp/auth.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/register_user.dart';
import 'package:get/get.dart';
import 'authenticationModel.dart';
import 'otp_screen.dart';

class PhoneOtpController extends GetxController {
  static PhoneOtpController get instance => Get.find();

  void phoneAuthentication(String phno) {
    Get.put(AuthenticationModel().phoneAuth(phno));
    Get.to(() => OtpScreen(
          phno: phno,
        ));
    // AuthenticationModel.instance.phoneAuth(phno);
  }

  void verifyOTP(var otp) async {
    var isVerified = await AuthenticationModel.instance.verifyOTP(otp);
    isVerified ? Get.to(Register_User()) : Get.offAll(() => const Auth());
  }
}
