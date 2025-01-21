import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlashcardMode extends StatelessWidget {
  final String verseReference;
  final String verseText;
  final VoidCallback onComplete;

  const FlashcardMode({
    Key? key,
    required this.verseReference,
    required this.verseText,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlipCard(
        onFlipDone: (isFront) {
          if (!isFront) onComplete();
        },
        front: Card(
          elevation: 4,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                verseReference,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
        back: Card(
          elevation: 4,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                verseText,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
