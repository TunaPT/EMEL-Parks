import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackArrow;

  const AppBarWidget({super.key, 
    required this.showBackArrow,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(56, 105, 184, 1),
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        alignment: Alignment.center,
        child: Image.asset('images/parkease.png',fit: BoxFit.cover),
      ),
      automaticallyImplyLeading: showBackArrow,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
