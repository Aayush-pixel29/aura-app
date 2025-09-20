import 'package:uuid/uuid.dart';

// An enum to clearly define the type of creation
enum CreationType {
  art,
  story,
  music
}

class CreationModel {
  final String id;
  final String prompt;
  final String resultData; // For art, this will be an image URL. For a story, the text.
  final CreationType type;
  final DateTime timestamp;

  CreationModel({
    required this.prompt,
    required this.resultData,
    required this.type,
  }) : id = const Uuid().v4(), // Automatically generate a unique ID
       timestamp = DateTime.now(); // Automatically record the creation time
}