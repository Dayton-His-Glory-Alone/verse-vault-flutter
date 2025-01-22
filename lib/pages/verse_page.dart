import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'flashcard_mode.dart';
import 'drag_and_drop_mode.dart';
import 'typing_mode.dart';
import '../utils/progress_manager.dart';

class VersePage extends StatefulWidget {
  @override
  _VersePageState createState() => _VersePageState();
}

class _VersePageState extends State<VersePage> {
  int currentMode = 0;
  String? verseReference;
  String? verseText;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        verseReference = args as String?;
      });
      if (verseReference != null) {
        _loadVerse();
      }
    });
    _loadProgress();
  }

  Future<void> _loadVerse() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/verses.json');
      final Map<String, dynamic> verses = json.decode(jsonString);

      setState(() {
        verseText = verses[verseReference] as String?;
      });
    } catch (e) {
      setState(() {
        verseText = "Error loading verse.";
      });
    }
  }

  Future<void> _loadProgress() async {
    currentMode = await ProgressManager.getCurrentMode();
    setState(() {});
  }

  Future<void> _saveCompletion() async {
    if (verseReference == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/completion_log.txt');

      final String logEntry =
          '${DateTime.now()}: Completed $verseReference\n';

      await file.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      print("Error saving completion log: $e");
    }
  }

  void _onModeComplete() async {
    setState(() {
      currentMode++;
    });

    if (currentMode >= 3) {
      await _saveCompletion();
      setState(() {
        currentMode = 0; // Reset the mode after completing all
      });
    }
    await ProgressManager.setCurrentMode(currentMode);
  }

  @override
  Widget build(BuildContext context) {
    if (verseReference == null || verseText == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget modeWidget;

    switch (currentMode) {
      case 0:
        modeWidget = FlashcardMode(
          verseReference: verseReference!,
          verseText: verseText!,
          onComplete: _onModeComplete,
        );
        break;
      case 1:
        modeWidget = DragAndDropMode(
          verseText: verseText!,
          onComplete: _onModeComplete,
        );
        break;
      case 2:
        modeWidget = TypingMode(
          verseText: verseText!,
          onComplete: _onModeComplete,
        );
        break;
      default:
        modeWidget = Center(child: Text("You've completed all modes!"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Verse Mode ${currentMode + 1}"),
      ),
      body: modeWidget,
    );
  }
}
