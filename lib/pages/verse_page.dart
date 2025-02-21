import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:verse_vault/pages/drag_and_drop_mode.dart';
import 'package:verse_vault/pages/typing_mode.dart';
import 'package:verse_vault/pages/bible_wordle.dart';
import 'package:verse_vault/providers/points_provider.dart'; // Import PointsProvider
import 'package:verse_vault/providers/verses_provider.dart';
import 'flashcard_mode.dart';

class VersePage extends StatefulWidget {
  final String selectedTranslation;
  VersePage({required this.selectedTranslation});
  @override
  _VersePageState createState() => _VersePageState();
}

class _VersePageState extends State<VersePage> {
  String? verseReference;
  String? verseText;
  Map<String, dynamic>? commentaryData;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      setState(() {
        verseReference = args;
      });
      if (verseReference != null) {
        _loadVerse();
        _loadCommentary();
      }
    });
  }

  Future<void> _loadVerse() async {
    try {
      final String filePath =
          'assets/data/verses${widget.selectedTranslation.toLowerCase()}.json';

      final String jsonString = await rootBundle.loadString(filePath);

      final Map<String, dynamic> verses = json.decode(jsonString);

      if (verseReference != null) {
        final singleVerseRegex = RegExp(r'^(.+)\s(\d+):(\d+)$');
        final rangeVerseRegex = RegExp(r'^(.+)\s(\d+):(\d+)-(\d+)$');

        if (singleVerseRegex.hasMatch(verseReference!)) {
          setState(() {
            verseText = verses[verseReference!] ?? "Verse not found.";
          });
        } else if (rangeVerseRegex.hasMatch(verseReference!)) {
          final match = rangeVerseRegex.firstMatch(verseReference!);
          if (match != null) {
            final book = match.group(1);
            final chapter = match.group(2);
            final startVerse = int.parse(match.group(3)!);
            final endVerse = int.parse(match.group(4)!);

            List<String> versesInRange = [];
            for (int i = startVerse; i <= endVerse; i++) {
              final key = '$book $chapter:$i';
              if (verses.containsKey(key)) {
                versesInRange.add(verses[key]);
              } else {
                versesInRange.add("[Verse $key not found]");
              }
            }

            setState(() {
              verseText = versesInRange.join(' ');
            });
          }
        } else {
          setState(() {
            verseText = "Invalid verse reference.";
          });
        }
      }
    } catch (e) {
      setState(() {
        verseText = "Error loading verse: $e";
      });
      print("Error loading verse file: $e");
    }
  }

  Future<void> _loadCommentary() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/savedCommentary.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      setState(() {
        commentaryData = {
          for (var entry in jsonData)
            entry['verseReference']: {
              'commentary': entry['commentary'],
              'commentaryReference': entry['commentaryReference']
            }
        };
      });
    } catch (e) {
      print("Error loading commentary: $e");
    }
  }

  Future<void> _updateDateMemorized(
      String verseReference, int days, int hours) async {
    final versesProvider = Provider.of<VersesProvider>(context, listen: false);
    await versesProvider.saveVerse(
        verseReference, days, hours); // Save the verse with the updated date
  }

  void _navigateToMode(BuildContext context, Widget modeWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => modeWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (verseReference == null || verseText == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Loading...")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$verseReference"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                verseText!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _navigateToMode(
                  context,
                  FlashcardMode(
                    verseReference: verseReference!,
                    verseText: verseText!,
                    onComplete: () {},
                  ),
                ),
                child: Text("Flash Card"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _navigateToMode(
                  context,
                  DragAndDropMode(
                    verseText: verseText!,
                    onComplete: () async {
                      // Use PointsProvider to update points
                      final pointsProvider =
                          Provider.of<PointsProvider>(context, listen: false);
                      pointsProvider.updatePoints(
                          pointsProvider.points + 2); // Add 2 points
                      await _updateDateMemorized(verseReference!, 0, 12);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("+2 points!")),
                      );
                    },
                  ),
                ),
                child: Text("Drag and Drop (2 points)"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _navigateToMode(
                  context,
                  TypingMode(
                    verseText: verseText!,
                    verseReference: verseReference!,
                    onComplete: () async {
                      // Use PointsProvider to update points
                      final pointsProvider =
                          Provider.of<PointsProvider>(context, listen: false);
                      pointsProvider.updatePoints(
                          pointsProvider.points + 5); // Add 5 points
                      await _updateDateMemorized(
                          verseReference!, 1, 0); // Update dateMemorized
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("+5 points! Date memorized updated.")),
                      );
                    },
                  ),
                ),
                child: Text("Type it Out (5 points)"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _navigateToMode(
                  context,
                  BibleWordle(
                    verseText: verseText!,
                    verseReference: verseReference!,
                    onComplete: () async {
                      // Use PointsProvider to update points
                      final pointsProvider =
                          Provider.of<PointsProvider>(context, listen: false);
                      pointsProvider.updatePoints(
                          pointsProvider.points + 1); // Add 1 point
                      await _updateDateMemorized(
                          verseReference!, 1, 0); // Update dateMemorized
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("+1 point! Date memorized updated.")),
                      );
                    },
                  ),
                ),
                child: Text("Wordle (1 point)"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (commentaryData != null &&
                      commentaryData!.containsKey(verseReference)) {
                    final commentary = commentaryData![verseReference];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentaryPage(
                          commentary: commentary['commentary'],
                          reference: commentary['commentaryReference'],
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Commentary not found for this verse."),
                      ),
                    );
                  }
                },
                child: Text("Commentary"),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ComingSoonPage(),
                    ),
                  );
                },
                child: Text("Speak It Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentaryPage extends StatelessWidget {
  final String commentary;
  final String reference;

  CommentaryPage({required this.commentary, required this.reference});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Commentary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              commentary,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "Reference: $reference",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class ComingSoonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Coming Soon"),
      ),
      body: Center(
        child: Text(
          "This feature is coming soon!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
