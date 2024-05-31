import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/scoring.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String jsonData = await loadJsonData();
  runApp(MyApp(jsonData: jsonData));
}

Future<String> loadJsonData() async {
  return await rootBundle.loadString('assets/leeftijd11_14.json');
}

void parseSubtitles(String jsonData) {
  var data = jsonDecode(jsonData);
  var subtitles = data['subtitles'];

  for (var subtitle in subtitles) {
    print('Subtitle: ${subtitle['sub_title']}');
    var descriptors = subtitle['descriptors'];
    for (var descriptor in descriptors) {
      print('Descriptor ID: ${descriptor['descriptor_id']}');
      print('Descriptor Name: ${descriptor['descriptor_name']}');
    }
  }
}

class MyApp extends StatelessWidget {
  final String jsonData;

  MyApp({required this.jsonData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(jsonData: jsonData),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String jsonData;

  MyHomePage({required this.jsonData});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stopwatch stopwatch;
  late Timer t;
  late Duration elapsed = Duration.zero;
  int score = 0;

  void handleStartStop() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
      elapsed = stopwatch.elapsed;
    } else {
      stopwatch.start();
    }
  }

  String returnFormattedText() {
    var milli = stopwatch.elapsed.inMilliseconds;

    String milliseconds = (milli % 1000).toString().padLeft(3, "0");
    String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0");
    String minutes = ((milli ~/ 1000) ~/ 60).toString().padLeft(2, "0");

    return "$minutes:$seconds:$milliseconds";
  }

  Map<int, bool> selectedDescriptors = {};
  Map<int, int?> selectedSubdivisions = {};
  late Map<String, dynamic> testData;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    testData = jsonDecode(widget.jsonData);
    t = Timer.periodic(Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  int selectedDomain = 3;
  int selectedItem = 0;

  void updateScore() {
    final selectedScores = <Map<String, dynamic>>[];
    var domain = testData['domains'].firstWhere(
      (domain) => domain['domain_id'] == selectedDomain,
      orElse: () => null,
    );

    if (domain != null) {
      var test = domain['tests'][selectedItem];
      var subtitles = test['subtitles'];

      subtitles.forEach((subtitle) {
        if (subtitle['sub_title'] != "Interference") {
          var descriptors = subtitle['descriptors'];

          selectedDescriptors.forEach((descriptorId, isSelected) {
            if (isSelected) {
              var descriptor = descriptors.firstWhere(
                (d) => d['descriptor_id'] == descriptorId,
                orElse: () => null,
              );

              if (descriptor != null) {
                if (descriptor['subdivision'] != null) {
                  var subdivisionId = selectedSubdivisions[descriptorId];
                  if (subdivisionId != null) {
                    selectedScores.add({
                      'descriptor_id': descriptorId,
                      'subdivision_id': subdivisionId,
                      'score': descriptor['subdivision'].firstWhere(
                          (subdivision) =>
                              subdivision['subdivision_id'] ==
                              subdivisionId)['score'],
                    });
                  }
                } else {
                  selectedScores.add({
                    'descriptor_id': descriptorId,
                    'score': descriptor['score'],
                  });
                }
              }
            }
          });
        }
      });

      setState(() {
        score = calculateScore(selectedScores);
        print("Calculated score: $score");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var domain = testData['domains'].firstWhere(
      (domain) => domain['domain_id'] == selectedDomain,
      orElse: () => null,
    );

    if (domain == null || domain['tests'].length <= 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Domain not found or index out of bounds'),
        ),
        body: Center(
          child: Text(
              'Domain with id $selectedDomain not found or test index out of bounds'),
        ),
      );
    }

    // Select specific item here
    var test = domain['tests'][selectedItem];
    var subtitles = test['subtitles'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(domain['domain_name']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      handleStartStop();
                    },
                    child: Container(
                      height: 250,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xff0395eb),
                          width: 4,
                        ),
                      ),
                      child: Text(
                        returnFormattedText(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      stopwatch.reset();
                    },
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(elapsed.toString()),
                  ),
                ],
              ),
              // test score
              // update score in text field
              Text(
                'Score: $score',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              Text(
                test['test_title'],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Column(
                children: List<Widget>.generate(subtitles.length, (int index) {
                  var subtitle = subtitles[index];
                  var descriptors = subtitle['descriptors'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // if subtitle is null return empty string
                        subtitle['sub_title'] ?? '',

                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: List<Widget>.generate(descriptors.length,
                            (int index) {
                          var descriptor = descriptors[index];
                          var hasSubdivision =
                              descriptor['subdivision'] != null;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                title: Text(descriptor['descriptor_name']),
                                value: selectedDescriptors[
                                        descriptor['descriptor_id']] ??
                                    false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedDescriptors[
                                            descriptor['descriptor_id']] =
                                        value ?? false;
                                    if (value == false) {
                                      selectedSubdivisions
                                          .remove(descriptor['descriptor_id']);
                                    }
                                    updateScore();
                                  });
                                },
                              ),
                              if (selectedDescriptors[
                                      descriptor['descriptor_id']] ??
                                  false)
                                if (hasSubdivision)
                                  Column(
                                    children: List<Widget>.generate(
                                        descriptor['subdivision'].length,
                                        (int subIndex) {
                                      var subdivision =
                                          descriptor['subdivision'][subIndex];
                                      return RadioListTile<int>(
                                        title: Text(
                                            subdivision['subdivision_name']),
                                        value: subdivision['score'],
                                        groupValue: selectedSubdivisions[
                                            descriptor['descriptor_id']],
                                        onChanged: (int? value) {
                                          setState(() {
                                            selectedSubdivisions[descriptor[
                                                'descriptor_id']] = value;
                                            updateScore();
                                          });
                                        },
                                      );
                                    }),
                                  ),
                            ],
                          );
                        }),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
