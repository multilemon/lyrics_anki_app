import 'package:flutter_riverpod/flutter_riverpod.dart';

// Signal to clear the Home Page form fields (Song Title, Artist)
// Increment this value to trigger a clear action.
final clearHomeFormSignalProvider = StateProvider<int>((ref) => 0);
