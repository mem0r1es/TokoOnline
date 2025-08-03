import 'package:flutter/material.dart';
import 'package:flutter_web/controllers/profile_image_controller.dart';
import 'package:get/get.dart';

class ProfilePic extends StatelessWidget {
  ProfilePic({super.key});

  final ProfileImageController controller =
      Get.put(ProfileImageController(), permanent: true); 

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final imageProvider = controller.profileImageUrl.value.isNotEmpty
          ? NetworkImage(controller.profileImageUrl.value)
          : const AssetImage('assets/default_profile.png') as ImageProvider;

      return SizedBox(
        height: 115,
        width: 115,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundImage: imageProvider,
              backgroundColor: Colors.grey[200],
            ),
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
            Positioned(
              right: -10,
              bottom: 0,
              child: SizedBox(
                height: 46,
                width: 46,
               
              ),
            ),
          ],
        ),
      );
    });
  }
}

