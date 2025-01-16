import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String pageName;
  final bool implyLeading;

  const AppBarWidget({
    Key? key,
    required this.pageName,
    this.implyLeading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: implyLeading,
      backgroundColor: Colors.blue,
      elevation: 0,
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
