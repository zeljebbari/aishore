import 'package:flutter/material.dart';

// references: https://api.flutter.dev/flutter/material/MenuAnchor-class.html#material.MenuAnchor.1 
// references: https://github.com/flutter/flutter/issues/148104
class HamMenu extends StatelessWidget {
  const HamMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: <Widget>[
        const SizedBox(height: 1.0),
        // financial analyst (upload) portal
        MenuItemButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>((states) {
              return const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0); // Internal padding
            }),
            shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
              if (states.contains(WidgetState.hovered)) {
                return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0), // Rounded corners on hover
                );
              }
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0), // Default rounded corners
              );
            }),
          ),
          onPressed: () {
            Navigator.pop(context); 
            Navigator.pushNamed(context, '/analyst');
          },
          child: const Text('Financial Analyst Portal'),
        ),
        const SizedBox(height: 0.0),
        // data steward (editing) portal
        MenuItemButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>((states) {
              return const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0); // Internal padding
            }),
            shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
              if (states.contains(WidgetState.hovered)) {
                return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0), // Rounded corners on hover
                );
              }
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0), // Default rounded corners
              );
            }),
          ),
          onPressed: () {
            Navigator.pop(context); 
            Navigator.pushNamed(context, '/steward');
          },
          child: const Text('Data Steward Portal'),
        ),
        const SizedBox(height: 0.0),
        // admin button
        MenuItemButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>((states) {
              return const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0); // Internal padding
            }),
            shape: WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
              if (states.contains(WidgetState.hovered)) {
                return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0), // Rounded corners on hover
                );
              }
              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0), // Default rounded corners
              );
            }),
          ),
          onPressed: () {
            Navigator.pop(context); 
            Navigator.pushNamed(context, '/admin');
          },
          child: const Text('Admin Portal'),
        ),
        const SizedBox(height: 0.0),


      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.menu),
        );
      },
    );
  }
}
