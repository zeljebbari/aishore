import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // DrawerHeader(
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).colorScheme.primary,
          //   ),
          //   child: const Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       Text(
          //         'Navigation Drawer',
          //         style: TextStyle(color: Colors.black, fontSize: 20),
          //       ),
          //     ],
          //   ),
          // ),
          ListTile(
            title: const Text('Upload'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushNamed(context, '/upload');
            },
          ),
          ListTile(
            title: const Text('Steward'),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushNamed(context, '/steward');
            },
          ),
        ],
      ),
    );
  }
}
