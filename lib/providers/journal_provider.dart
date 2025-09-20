import 'package:flutter/foundation.dart';
import '../models/creation_model.dart';

class JournalProvider with ChangeNotifier {
  // A private list to hold all creations.
  final List<CreationModel> _creations = [];

  // A public getter to allow other parts of the app to read the list.
  List<CreationModel> get creations => _creations;

  // A method to add a new creation to the list.
  void addCreation(CreationModel newCreation) {
    _creations.add(newCreation);
    
    // This is the most important part! It tells any widget that is
    // 'listening' to this provider that the data has changed and
    // it needs to rebuild its UI.
    notifyListeners();
  }
}