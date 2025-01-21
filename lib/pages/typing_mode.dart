import 'package:flutter/material.dart';

class TypingMode extends StatefulWidget {
  final String verseText;
  final VoidCallback onComplete;

  const TypingMode({
    Key? key,
    required this.verseText,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<TypingMode> createState() => _TypingModeState();
}

class _TypingModeState extends State<TypingMode> {
  late List<String> words;
  int currentWordIndex = 0;

  @override
  void initState() {
    super.initState();
    words = widget.verseText.split(' ');
  }

  void _checkInput(String input) {
    if (input.toLowerCase() == words[currentWordIndex][0].toLowerCase()) {
      setState(() {
        currentWordIndex++;
        if (currentWordIndex == words.length) widget.onComplete();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          words
              .take(currentWordIndex)
              .join(' ') +
              (currentWordIndex < words.length ? ' _' : ''),
          style: TextStyle(fontSize: 24),
        ),
        TextField(
          onChanged: _checkInput,
        ),
      ],
    );
  }
}
