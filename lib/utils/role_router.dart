import 'package:flutter/material.dart';
import 'package:pardarsh_application/model/user.dart';
import '../screens/government/user_home_screen.dart';
import '../screens/contractor/contractor_home_screen.dart';
import '../screens/general_user/general_user_home_screen.dart';

class RoleRouter extends StatelessWidget {
  final UserModel user;

  const RoleRouter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Use the helper methods from UserModel
    if (user.isContractor) {
      return const ContractorHomeScreen();
    } else if (user.isGovernmentOfficial) {
      return const UserHomeScreen(); // Government Official dashboard
    } else if (user.isGeneralUser) {
      return const GeneralUserHomeScreen();
    } else {
      // Default fallback
      return const GeneralUserHomeScreen();
    }
  }
}
