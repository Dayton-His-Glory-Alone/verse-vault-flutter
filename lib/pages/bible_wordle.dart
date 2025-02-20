import 'package:flutter/material.dart';

class BibleWordle extends StatefulWidget {
  final String verseText; // The full verse text
  final String verseReference; // The verse reference (e.g., "Hebrews 11:1")
  final VoidCallback onComplete;

  const BibleWordle({
    Key? key,
    required this.verseText,
    required this.verseReference,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<BibleWordle> createState() => _BibleWordleState();
}

class _BibleWordleState extends State<BibleWordle> {
  final int maxAttempts = 6; // Maximum number of guesses
  List<String> guesses = []; // Stores user guesses
  String currentGuess = ''; // Current guess being typed
  late String targetWord; // The target word extracted from the verse

  @override
  void initState() {
    super.initState();
    targetWord = _extractTargetWord(widget.verseText); // Extract the target word
  }

  // Extract the target word from the verse text
  String _extractTargetWord(String verseText) {
    // Split the verse into words
    List<String> words = verseText.split(' ');

    // Remove common stop words (e.g., "the", "and", "of")
    List<String> stopWords = ["the", "and", "of", "in", "to", "a", "is", "it"];
    words.removeWhere((word) => stopWords.contains(word.toLowerCase()));

    // Pick the longest word as the target (or use other logic)
    String target = words.reduce((a, b) => a.length > b.length ? a : b);

    // Alternatively, you could use a list of common biblical themes
    List<String> biblicalThemes = ["faith", "love", "grace", "hope", "peace", "joy"];
    for (String word in words) {
      if (biblicalThemes.contains(word.toLowerCase())) {
        return word.toLowerCase();
      }
    }

    return target.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bible Wordle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the verse reference as a clue
            Text(
              "Clue: ${widget.verseReference}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Display the grid of guesses
            Expanded(
              child: ListView.builder(
                itemCount: maxAttempts,
                itemBuilder: (context, index) {
                  if (index < guesses.length) {
                    return _buildGuessRow(guesses[index]);
                  } else if (index == guesses.length) {
                    return _buildCurrentGuessRow();
                  } else {
                    return _buildEmptyRow();
                  }
                },
              ),
            ),

            // Keyboard for input
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  // Build a row for a completed guess
  Widget _buildGuessRow(String guess) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: guess.split('').asMap().entries.map((entry) {
        final int index = entry.key;
        final String letter = entry.value;
        final String targetLetter = targetWord.split('')[index];

        Color backgroundColor;
        if (letter == targetLetter) {
          backgroundColor = Colors.green; // Correct letter in correct position
        } else if (targetWord.contains(letter)) {
          backgroundColor = Colors.yellow; // Correct letter in wrong position
        } else {
          backgroundColor = Colors.grey; // Incorrect letter
        }

        return Container(
          margin: const EdgeInsets.all(4),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: Colors.black),
          ),
          child: Text(
            letter.toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  // Build the current guess row
  Widget _buildCurrentGuessRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(targetWord.length, (index) {
        final String letter = index < currentGuess.length ? currentGuess[index] : '';
        return Container(
          margin: const EdgeInsets.all(4),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
          ),
          child: Text(
            letter.toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  // Build an empty row for future guesses
  Widget _buildEmptyRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(targetWord.length, (index) {
        return Container(
          margin: const EdgeInsets.all(4),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
        );
      }),
    );
  }

  // Build the on-screen keyboard
  Widget _buildKeyboard() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
        return Padding(
          padding: const EdgeInsets.all(4),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (currentGuess.length < targetWord.length) {
                  currentGuess += letter.toLowerCase();
                }
              });
            },
            child: Text(letter),
          ),
        );
      }).toList(),
    );
  }

  // Handle guess submission
  void _submitGuess() {
    if (currentGuess.length == targetWord.length) {
      setState(() {
        guesses.add(currentGuess);
        currentGuess = '';

        // Check if the guess is correct
        if (guesses.last == targetWord) {
          widget.onComplete();
        }
      });
    }
  }
}
