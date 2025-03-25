import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String pageName;
  final bool implyLeading;
  final Color color;

  const AppBarWidget(
      {super.key,
      required this.pageName,
      this.implyLeading = false,
      this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: implyLeading,
      backgroundColor: color,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        pageName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [Image.asset('assets/images/logo.png')],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
