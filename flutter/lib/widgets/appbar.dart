import 'package:flutter/material.dart';
import '../widgets/hammenu.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/theme.dart';


class LogoAppBar extends StatelessWidget implements PreferredSizeWidget{
  const LogoAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, 
      titleSpacing: 0,
      title: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 30.0),
            child: HamMenu(),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                './assets/color.png',
                height: 50,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              children: [
                Tooltip(
                  message: 'Contact Support',
                  child: IconButton(
                    icon: const Icon(Icons.mail_outline),
                    onPressed: () async {
                      String email = Uri.encodeComponent("zyad@aishore.ai");
                      String subject = Uri.encodeComponent("AiShore LendMarq Website Support Request");
                      Uri mail = Uri.parse("mailto:$email?subject=$subject");
                      if (await launchUrl(mail)) {
                        // email application opened, do nothing
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: SelectableText('Could not open the default email app. Please contact zyad@aishore.ai directly.'),
                            duration: Duration(seconds: 20),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8,),
                Tooltip(
                  message: 'Settings',
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Settings'),
                            content: Consumer<ThemeProvider>(
                              builder: (context, themeProvider, child) {
                                return SwitchListTile(
                                  title: const Text('Dark Mode'),
                                  value: themeProvider.themeMode == ThemeMode.dark,
                                  onChanged: (value) {
                                    themeProvider.toggleTheme();
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
