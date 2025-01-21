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
  late List<String> blanks;
  late List<String> pool;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    words = widget.verseText.split(' ');
    blanks = [...words]; // Replace nouns with '_'.
    pool = ['example', 'words']; // Add words to a pool.
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          children: blanks
              .map((word) => word == '_'
                  ? Container(width: 50, height: 30, color: Colors.grey)
                  : Text(word))
              .toList(),
        ),
        Wrap(
          children: pool
              .map((word) => Draggable<String>(
                    data: word,
                    feedback: Text(word),
                    child: Text(word),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
