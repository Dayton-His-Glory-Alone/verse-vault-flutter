import 'package:flutter/material.dart';
import 'dart:convert';
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
  String? verseReference; // Nullable until initialized
  String? verseText;

  @override
  void initState() {
    super.initState();
    // Delay accessing the ModalRoute until after initState
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments;
      setState(() {
        verseReference = args as String?;
      });
      if (verseReference != null) {
        _loadVerse(); // Load verse once the reference is set
      }
    });
    _loadProgress();
  }

  /// Load the verse text from the JSON file
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

  /// Load the user's progress
  Future<void> _loadProgress() async {
    currentMode = await ProgressManager.getCurrentMode();
    setState(() {});
  }

  /// Handle mode completion
  void _onModeComplete() async {
    setState(() {
      currentMode++;
    });
    await ProgressManager.setCurrentMode(currentMode);
  }

  @override
  Widget build(BuildContext context) {
    if (verseReference == null || verseText == null) {
      // Show loading indicator while fetching the verse reference or text
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
