import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

/// A Flutter widget that provides a page picker dialog for selecting a specific page number.
/// 
/// This widget displays an AlertDialog with a NumberPicker that allows users to select
/// a page number within a specified range. It's commonly used in PDF viewers and similar
/// applications where users need to navigate to a specific page.
/// 
/// The dialog includes:
/// - A customizable title
/// - A number picker with configurable min/max values
/// - A confirmation button (customizable)
/// 
/// Example usage:
/// ```dart
/// // Show the page picker dialog
/// int? selectedPage = await showDialog<int>(
///   context: context,
///   builder: (BuildContext context) {
///     return PagePicker(
///       title: 'Go to Page',
///       maxValue: 100,
///       initialValue: 1,
///     );
///   },
/// );
/// 
/// if (selectedPage != null) {
///   print('User selected page: $selectedPage');
/// }
/// ```
class PagePicker extends StatefulWidget {
  /// Creates a PagePicker widget.
  /// 
  /// All parameters except [numberPickerConfirmWidget] are required.
  /// 
  /// Parameters:
  /// - [title]: The title text displayed at the top of the dialog
  /// - [maxValue]: The maximum selectable page number
  /// - [initialValue]: The initially selected page number
  /// - [numberPickerConfirmWidget]: Optional custom widget for the confirm button.
  ///   If not provided, defaults to a Text widget with 'OK'
  const PagePicker({super.key,
    required this.title,
    required this.maxValue,
    required this.initialValue,
    this.numberPickerConfirmWidget,
  });

  /// The title text displayed at the top of the dialog.
  /// 
  /// This text appears in the dialog's title bar and typically describes
  /// the purpose of the page picker (e.g., "Go to Page", "Select Page").
  final String title;
  
  /// The maximum selectable page number.
  /// 
  /// This value represents the total number of pages available for selection.
  /// The number picker will not allow selection beyond this value.
  /// Must not be null and should be greater than 0.
  final int? maxValue;
  
  /// The initially selected page number when the dialog opens.
  /// 
  /// This value determines which page number is pre-selected when the
  /// picker is first displayed. Should be between 1 and [maxValue].
  /// Must not be null.
  final int? initialValue;
  
  /// Optional custom widget for the confirmation button.
  /// 
  /// If not provided, the dialog will display a default 'OK' button.
  /// This allows for customization of the button appearance, text,
  /// or even replacing it with an icon button.
  /// 
  /// Example:
  /// ```dart
  /// numberPickerConfirmWidget: Icon(Icons.check),
  /// ```
  final Widget? numberPickerConfirmWidget;

  @override
  State<PagePicker> createState() => _PagePickerState();
}

/// The state class for [PagePicker].
/// 
/// This class manages the internal state of the page picker, specifically
/// tracking the currently selected value as the user interacts with the
/// number picker widget.
class _PagePickerState extends State<PagePicker> {
  /// The currently selected page number.
  /// 
  /// This value changes as the user interacts with the number picker
  /// and represents the value that will be returned when the user
  /// confirms their selection.
  int? _currentValue;

  /// Initializes the state with the initial value from the widget.
  /// 
  /// Sets [_currentValue] to the [widget.initialValue] provided
  /// when the PagePicker was created.
  @override
  void initState() {
    _currentValue = widget.initialValue;
    super.initState();
  }

  /// Builds the page picker dialog widget.
  /// 
  /// Creates an AlertDialog containing:
  /// - A title with the provided [widget.title]
  /// - A NumberPicker with range from 1 to [widget.maxValue]
  /// - A confirmation button that closes the dialog and returns the selected value
  /// 
  /// The NumberPicker allows users to select a value between 1 and [widget.maxValue].
  /// When a new value is selected, the widget's state is updated to reflect the change.
  /// 
  /// The confirmation button, when pressed, closes the dialog and returns the
  /// currently selected value via [Navigator.pop].
  /// 
  /// Returns:
  /// An [AlertDialog] widget configured with the page picker functionality.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: NumberPicker(
        minValue: 1,
        maxValue: widget.maxValue!,
        value: _currentValue!,
        onChanged: (value) => setState(() => _currentValue = value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_currentValue),
          child: widget.numberPickerConfirmWidget ?? const Text('OK'),
        ),
      ],
    );
  }
}