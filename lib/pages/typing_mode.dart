import 'package:flutter/material.dart';

class TypingMode extends StatefulWidget {
  final String verseText;
  final VoidCallback onComplete;
  final String verseReference;

  const TypingMode({
    Key? key,
    required this.verseText,
    required this.onComplete,
    required this.verseReference,
  }) : super(key: key);

  @override
  State<TypingMode> createState() => _TypingModeState();
}

class _TypingModeState extends State<TypingMode> {
  late List<String> words;
  int currentWordIndex = 0;
  late TextEditingController _controller;
  int incorrectAttempts = 0;
  double correctnessPercentage = 100.0;
  int totalWords = 0;
  int correctWords = 0;
  bool showCoinAnimation = false;
  int gardenerImageIndex = 1;
  bool showRedFlash = false;
  bool showCompletionGif = false;

  @override
  void initState() {
    super.initState();
    words = widget.verseText.split(' ');
    totalWords = words.length;
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkInput(String input) {
    if (input.isEmpty) return;

    if (input.toLowerCase() == words[currentWordIndex][0].toLowerCase()) {
      setState(() {
        correctWords++;
        currentWordIndex++;
        incorrectAttempts = 0;
        correctnessPercentage =
            100.0 - ((incorrectAttempts / totalWords) * 100);
        showCoinAnimation = true;
        if (currentWordIndex == words.length) {
          widget.onComplete();
          _showCongratsMessage();
          showCompletionGif =
              true; // Show completion GIF when verse is complete
        }
        _updateGardenerImage();
      });
    } else {
      setState(() {
        incorrectAttempts++;
        showRedFlash = true;
        if (incorrectAttempts >= 4) {
          currentWordIndex++;
          incorrectAttempts = 0;
          if (currentWordIndex == words.length) {
            widget.onComplete();
            _showCongratsMessage();
            showCompletionGif =
                true; // Show completion GIF when verse is complete
          }
        }
        correctnessPercentage =
            100.0 - ((incorrectAttempts / totalWords) * 100);
      });

      // Reset the red flash after a short delay
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          showRedFlash = false;
        });
      });
    }

    _controller.clear();
  }

  void _updateGardenerImage() {
    int progress = (correctnessPercentage ~/ 20);
    setState(() {
      gardenerImageIndex = progress + 1;
    });
  }

  void _showCongratsMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Congratulations!"),
        content: Text("You have successfully completed the verse."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  String _getDisplayText() {
    String typedText = words.take(currentWordIndex).join(' ');
    if (typedText.length > 50) {
      return '...${typedText.substring(typedText.length - 50)}';
    }
    return typedText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Typing Mode"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/gardener_$gardenerImageIndex.png',
                        height: 200,
                      ),
                      Text(
                        "Correctness: ${correctnessPercentage.toStringAsFixed(1)}%",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _getDisplayText() +
                              (currentWordIndex < words.length ? ' _' : ''),
                          style: const TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Green progress bar at the bottom
              Container(
                height: 10,
                width: double.infinity,
                child: LinearProgressIndicator(
                  value: correctWords / totalWords,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  onChanged: _checkInput,
                  decoration: const InputDecoration(
                    hintText: 'Type the first letter...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          if (showRedFlash)
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              color: Colors.red.withOpacity(0.3),
            ),
          if (showCoinAnimation)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: TweenAnimationBuilder(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, -100 * value),
                      child: Opacity(
                        opacity: 1 - value,
                        child: Image.asset(
                          'assets/images/coin.png',
                          height: 50,
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    setState(() {
                      showCoinAnimation = false;
                    });
                  },
                ),
              ),
            ),
          if (showCompletionGif)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/gifs/completion.gif',
                  height: 200,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Typing Mode',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TypingMode(
        verseText: "For God so loved the world that He gave His only Son",
        verseReference: "John 3:16",
        onComplete: () {
          // Callback when typing is complete
          print("Verse complete!");
        },
      ),
    );
  }
}
