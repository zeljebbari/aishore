import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
class AdminPage extends StatefulWidget {
  const AdminPage({super.key, required this.title});
  final String title;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<String> _userRole = [];
  // references: https://pub.dev/packages/multi_select_flutter
  final List<MultiSelectItem<String>> _roles = [
    MultiSelectItem('Financial_Analyst', 'Financial Analyst'),
    MultiSelectItem('Data_Steward', 'Data Steward'),
    MultiSelectItem('Admin', 'Admin'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: const LogoAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  const Center(
                    child: Text(
                      'Admin Portal',
                      style: TextStyle(
                        fontSize: 32, 
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0), 
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'User Email',
                    ),
                    validator: (value) {
                      if (value == null|| value.isEmpty) {
                        return 'Please enter user email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'User First Name',
                    ),
                    validator: (value) {
                      if (value == null|| value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'User Last Name',
                    ),
                    validator: (value) {
                      if (value == null|| value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  MultiSelectDialogField(
                    items: _roles,
                    initialValue: _userRole,
                    title: const Text('Select User Role(s)'),
                    confirmText: const Text('Confirm'),
                    cancelText: const Text('Cancel'),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDarkTheme ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(5.0),
                      color: isDarkTheme ? Colors.grey[800] : Colors.white, // Box color
                    ),
                    buttonIcon: const Icon(Icons.arrow_drop_down),
                    buttonText: const Text('Select User Role(s)'),
                    itemsTextStyle: TextStyle(
                      fontFamily: "Avenir",
                      color: isDarkTheme ? const Color.fromRGBO(204, 204, 204, 1.0) : Colors.black,
                    ),
                    selectedItemsTextStyle: TextStyle(
                      fontFamily: "Avenir",
                      color: isDarkTheme ? const Color.fromRGBO(204, 204, 204, 1.0) : Colors.black,
                    ),
                    backgroundColor: isDarkTheme ? const Color.fromRGBO(41, 41, 41, 1) : Colors.white,
                    selectedColor: isDarkTheme ? Colors.grey[800] : Colors.grey[300],
                    chipDisplay: MultiSelectChipDisplay<String>(
                      chipColor: isDarkTheme ? Colors.grey[700] : Colors.grey[300],
                      textStyle: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onConfirm: (results) {
                      setState(() {
                        _userRole = results.cast<String>();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select at least one user role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:() {}, // TO-DO
                    child: const Text('Provision Access'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}