import 'package:flutter/material.dart';

// references: https://www.dhiwise.com/post/user-selection-guide-to-flutter-dropdownbuttonformfield
class MultiSelectDropdown extends FormField<List<String>> {
  MultiSelectDropdown({
    super.key,
    required List<String> items,
    super.onSaved,
    super.validator,
    List<String>? initialValue,
  }): super(
    initialValue: initialValue ?? [],
    builder: (FormFieldState<List<String>> state) {
      return InputDecorator(
        decoration: InputDecoration(
          label: const Padding(
            padding: EdgeInsets.only(left: 12, right: 20),
            child: Text('Select User Role(s)'),
          ),
          errorText: state.errorText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(0),
        ),
        isEmpty: state.value == null || state.value!.isEmpty,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: null,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: StatefulBuilder(
                  builder: (context, _setState) {
                    final selected = state.value!.contains(item);
                    return Row(
                      children: <Widget>[
                        Checkbox(
                          value: selected,
                          onChanged: (checked) {
                            final newValue = List<String>.from(state.value!);
                            if (checked == true) {
                              newValue.add(item);
                            } else {
                              newValue.remove(item);
                            }
                            _setState(() {});
                            state.didChange(newValue);
                          },
                        ),
                        Text(item),
                      ],
                    );
                  },
                ),
              );
            }).toList(),
            onChanged: (value) {},
          ),
        ),
      );


    }
  );
}


// use with the following widget in practice
// MultiSelectDropdown(
//   items: const [
//     'Financial Analyst',
//     'Data Steward',
//     'Admin',
//   ],
//   onSaved: (value) {
//     _userRole = value!;
//   },
//   validator: (value) {
//     if (value == null || value.isEmpty) {
//       return 'Please select at least one user role';
//     }
//     return null;
//   },
// ),