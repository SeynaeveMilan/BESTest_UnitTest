import 'dart:convert';
import 'package:flutter/services.dart';

Future<void> main() async {
  final String jsonData = await loadJsonData();
  final Map<String, dynamic> data = json.decode(jsonData);

  // Get domain 1, test 1 descriptors
  List<String> descriptors = getDescriptors1_1(data);
  print(descriptors);

  // Example of calculating score
  int score = calculateScore([
    {'descriptor_id': 1, 'subdivision_id': 1, 'score': 2},
    {'descriptor_id': 2, 'subdivision_id': 2, 'score': 2},
  ]);
  print(score); // Should print 0 due to the specific condition

  // Example of another calculation
  score = calculateScore([
    {'descriptor_id': 1, 'subdivision_id': 1, 'score': 2},
    {'descriptor_id': 2, 'score': 2},
  ]);
  print(score); // Should print 2 (the minimum score)

  // Example of another calculation
  score = calculateScore([
    {'descriptor_id': 1, 'subdivision_id': 1, 'score': 2},
    {'descriptor_id': 3, 'score': 3},
  ]);
  print(score); // Should print 2 (the minimum score)
}

Future<String> loadJsonData() async {
  return await rootBundle.loadString('assets/leeftijd11_14.json');
}

// Get domain 1, test 1 descriptors
List<String> getDescriptors1_1(Map<String, dynamic> data) {
  List<String> descriptors = [];
  var descriptorsList =
      data['domains'][0]['tests'][0]['subtitles'][0]['descriptors'];
  for (var descriptor in descriptorsList) {
    descriptors.add(descriptor['descriptor_name']);
  }
  return descriptors;
}

int calculateScore(List<Map<String, dynamic>> selectedScores) {
  if (selectedScores.isEmpty) {
    return 0; // Default score if no descriptors are selected
  }

  // Check for specific condition
  bool hasDescriptor2 = false;
  bool hasSubdivision2 = false;

  // specific for domain 1, item 1
  for (var score in selectedScores) {
    if (score['descriptor_id'] == 2) {
      print("pain");
      hasDescriptor2 = true;
    }
    if (score['subdivision_id'] == 1) {
      print("both feet");
      hasSubdivision2 = true;
    }
  }

  if (hasDescriptor2 && hasSubdivision2) {
    print('match');
    return 0; // Specific condition met
  }

  // Calculate the minimum score (overal use)
  return selectedScores
      .map((e) => e['score'] as int)
      .reduce((value, element) => value < element ? value : element);
}
