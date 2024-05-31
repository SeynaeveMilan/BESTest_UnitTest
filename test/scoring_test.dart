// // test/scoring_test.dart
// import 'package:flutter_application_1/scoring.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   group('Score Calculation Tests', () {
//     test('Single selection, score 3', () {
//       expect(calculateScore([3]), 3);
//     });

//     test('Single selection, score 1', () {
//       expect(calculateScore([1]), 1);
//     });

//     test('Multiple selections, scores 3 and 1, should return 1', () {
//       expect(calculateScore([3, 1]), 1);
//     });

//     test('Multiple selections, scores 2, 2, and 1, should return 1', () {
//       expect(calculateScore([2, 2, 1]), 1);
//     });

//     test('Multiple selections, scores 3, 2, and 0, should return 0', () {
//       expect(calculateScore([3, 2, 0]), 0);
//     });

//     test('Multiple selections, scores 0 and 1, should return 0', () {
//       expect(calculateScore([0, 1]), 0);
//     });

//     test('No selections, should return 0', () {
//       expect(calculateScore([]), 0);
//     });
//   });
// }
