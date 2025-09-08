import 'package:flutter/material.dart';
import 'package:pardarsh_application/model/user.dart';
import '../screens/user/user_home_screen.dart';
import '../screens/contractor/contractor_home_screen.dart';

class RoleRouter extends StatelessWidget {
  final UserModel user;

  const RoleRouter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    switch (user.role) {
      case "Contractor":
        return const ContractorHomeScreen();
      case "Government Official":
        return const UserHomeScreen(); // Replace with govt screen later
      default:
        return const UserHomeScreen();
    }
  }
}
