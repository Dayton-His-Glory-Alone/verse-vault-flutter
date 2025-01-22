import 'package:flutter/material.dart';

class DragAndDropMode extends StatefulWidget {
  final String verseText;
  final VoidCallback onComplete;

  const DragAndDropMode({
    Key? key,
    required this.verseText,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<DragAndDropMode> createState() => _DragAndDropModeState();
}

class _DragAndDropModeState extends State<DragAndDropMode> {
  late List<String> words;
  late List<String?> blanks;
  late List<String> pool;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    words = widget.verseText.split(' ');
    blanks = List<String?>.from(words);

    // Make every third word blank
    for (int i = 2; i < words.length; i += 3) {
      blanks[i] = null;
    }

    // Populate the pool with missing words
    pool = words
        .where((word) => blanks.contains(null) && !blanks.contains(word))
        .toList();
    pool.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Drag and Drop Game")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: blanks.asMap().entries.map((entry) {
                final index = entry.key;
                final word = entry.value;

                return word == null
                    ? DragTarget<String>(
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: 60,
                            height: 30,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Text(
                              '____',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        },
                        onAccept: (data) {
                          setState(() {
                            blanks[index] = data;
                            pool.remove(data);

                            // Check if the game is complete
                            if (!blanks.contains(null)) {
                              widget.onComplete();
                            }
                          });
                        },
                      )
                    : Text(
                        word,
                        style: const TextStyle(fontSize: 16),
                      );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: pool
                  .map((word) => Draggable<String>(
                        data: word,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Text(
                            word,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: Text(
                            word,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        child: Text(
                          word,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
