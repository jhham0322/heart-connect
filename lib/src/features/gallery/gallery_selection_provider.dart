import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the ID or Path of the currently selected element in the main view.
/// This allows the global Floating Action Button (in ScaffoldWithNav) to know
/// what item is currently being viewed or selected in the child screens.
final currentSelectionProvider = StateProvider<String?>((ref) => null);
