import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';

class VoiceMode extends StatefulWidget {
  final String verseReference;
  final String verseText;
  final VoidCallback onComplete;

  const VoiceMode({
    Key? key,
    required this.verseReference,
    required this.verseText,
    required this.onComplete,
  }) : super(key: key);

  @override
  _VoiceModeState createState() => _VoiceModeState();
}

class _VoiceModeState extends State<VoiceMode> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _feedback = '';
  Color _feedbackColor = Colors.black;
  int _currentWordIndex = 0;
  List<String> _verseWords = [];
  bool _processingSpeech = false;
  bool _speechInitialized = false;
  bool _showHints = false;
  String _lastRecognizedText = '';
  late List<String> _originalVerseWords;

  // Expanded homonym map with common biblical terms
  final Map<String, List<String>> _homonymMap = {
    'by': ['buy', 'bye'],
    'buy': ['by', 'bye'],
    'weekend': ['weakened'],
    'weakened': ['weekend'],
    'son': ['sun'],
    'sun': ['son'],
    'peace': ['piece'],
    'piece': ['peace'],
    'right': ['write', 'rite'],
    'write': ['right', 'rite'],
    'lord': ['laud'],
    'laud': ['lord'],
    'heal': ['heel', 'he\'ll'],
    'heel': ['heal', 'he\'ll'],
    'whole': ['hole'],
    'hole': ['whole'],
    'soul': ['sole'],
    'sole': ['soul'],
  };

  // Common contractions and their expansions
  final Map<String, String> _contractionMap = {
    "i'm": "i am",
    "you're": "you are",
    "he's": "he is",
    "she's": "she is",
    "it's": "it is",
    "we're": "we are",
    "they're": "they are",
    "i'll": "i will",
    "you'll": "you will",
    "he'll": "he will",
    "she'll": "she will",
    "we'll": "we will",
    "they'll": "they will",
    "i've": "i have",
    "you've": "you have",
    "we've": "we have",
    "they've": "they have",
    "i'd": "i would",
    "you'd": "you would",
    "he'd": "he would",
    "she'd": "she would",
    "we'd": "we would",
    "they'd": "they would",
    "don't": "do not",
    "doesn't": "does not",
    "didn't": "did not",
    "can't": "cannot",
    "couldn't": "could not",
    "won't": "will not",
    "wouldn't": "would not",
    "shouldn't": "should not",
    "isn't": "is not",
    "aren't": "are not",
    "wasn't": "was not",
    "weren't": "were not",
    "hasn't": "has not",
    "haven't": "have not",
    "hadn't": "had not",
    "let's": "let us",
    "that's": "that is",
    "there's": "there is",
    "what's": "what is",
    "where's": "where is",
    "who's": "who is",
    "why's": "why is",
    "how's": "how is",
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _originalVerseWords =
        widget.verseText.split(' ').where((w) => w.isNotEmpty).toList();
    _verseWords = _originalVerseWords.map((word) => _normalize(word)).toList();
    _initializeSpeech();
  }

  List<String> _preprocessVerseText(String verseText) {
    return verseText
        .split(' ')
        .map((word) => _normalize(word))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  Future<void> _initializeSpeech() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        var status = await Permission.microphone.request();
        if (!status.isGranted) {
          _setFeedback('Microphone permission denied', Colors.red);
          return;
        }
      }

      bool initialized = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' && _isListening && !_processingSpeech) {
            _startListening();
          }
          if (status == 'done') {
            if (_isListening) {
              _startListening();
            }
          }
        },
        onError: (error) {
          _setFeedback('Error: ${error.errorMsg}', Colors.red);
          _stopListening();
        },
      );

      setState(() {
        _speechInitialized = initialized;
      });

      if (!initialized) {
        _setFeedback('Speech initialization failed. Try again.', Colors.red);
      } else {
        _setFeedback('Ready to listen. Tap the microphone.', Colors.blue);
      }
    } catch (e) {
      _setFeedback('Initialization error: ${e.toString()}', Colors.red);
    }
  }

  void _startListening() async {
    if (_isListening || _processingSpeech || !_speechInitialized) return;
    if (_currentWordIndex >= _verseWords.length) return;

    bool hasPermission = await Permission.microphone.isGranted;
    if (!hasPermission) {
      await Permission.microphone.request();
      hasPermission = await Permission.microphone.isGranted;
    }

    if (!hasPermission) {
      _setFeedback('Microphone permission required', Colors.red);
      return;
    }

    _setStateListening(true);

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _processSpeech(result.recognizedWords);
        } else {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        }
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      localeId: 'en_US',
      partialResults: true,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      onSoundLevelChange: (level) {},
    );
  }

  void _setStateListening(bool isListening) {
    setState(() {
      _isListening = isListening;
      if (!isListening) {
        _recognizedText = '';
      }
      _feedback = isListening ? 'Listening...' : 'Tap microphone to speak';
      _feedbackColor = isListening ? Colors.blue : Colors.black;
    });
  }

  void _setFeedback(String text, Color color) {
    setState(() {
      _feedback = text;
      _feedbackColor = color;
    });
  }

  void _processSpeech(String recognizedText) async {
    if (_processingSpeech || !_isListening) return;
    _processingSpeech = true;
    _lastRecognizedText = recognizedText;

    try {
      if (recognizedText.isNotEmpty) {
        List<String> spokenWords = _preprocessSpokenText(recognizedText);
        int correctWords = 0;
        bool perfectMatch = true;

        for (int i = 0;
            i < spokenWords.length &&
                _currentWordIndex + i < _verseWords.length;
            i++) {
          String expected = _verseWords[_currentWordIndex + i];
          String spoken = spokenWords[i];

          if (_wordsMatch(expected, spoken)) {
            correctWords++;
          } else {
            perfectMatch = false;
            break;
          }
        }

        if (correctWords > 0) {
          setState(() {
            _currentWordIndex += correctWords;
            if (_currentWordIndex >= _verseWords.length) {
              _setFeedback('🎉 Congratulations! Verse complete.', Colors.green);
              widget.onComplete();
            } else {
              _setFeedback('Correct! Keep going.', Colors.green);
            }
          });
        } else {
          _setFeedback('Try again. Listen closely.', Colors.orange);
          setState(() {
            _showHints = true;
          });
        }

        // Always restart listening after processing
        if (_currentWordIndex < _verseWords.length) {
          _stopListening();
          Future.delayed(Duration(milliseconds: 300), () {
            if (!_isListening) {
              _startListening();
            }
          });
        }
      }
    } finally {
      _processingSpeech = false;
    }
  }

  List<String> _preprocessSpokenText(String text) {
    return text
        .split(' ')
        .map((word) => _normalize(word))
        .where((word) => word.isNotEmpty)
        .map((word) => _expandContractions(word))
        .toList();
  }

  String _expandContractions(String word) {
    return _contractionMap[word] ?? word;
  }

  bool _wordsMatch(String expected, String spoken) {
    if (expected == spoken) return true;
    if (_homonymMap[expected]?.contains(spoken) ?? false) return true;

    if (expected.endsWith('s') &&
        expected.substring(0, expected.length - 1) == spoken) {
      return true;
    }
    if (spoken.endsWith('s') &&
        spoken.substring(0, spoken.length - 1) == expected) {
      return true;
    }

    return false;
  }

  String _normalize(String word) {
    return word.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      _setStateListening(false);
    }
  }

  String _getExpectedNextWords({int count = 5}) {
    int endIndex = (_currentWordIndex + count).clamp(0, _verseWords.length);
    return _originalVerseWords.sublist(_currentWordIndex, endIndex).join(' ');
  }

  String _getCompletedWords() {
    return _originalVerseWords.sublist(0, _currentWordIndex).join(' ');
  }

  void _toggleHints() {
    setState(() {
      _showHints = !_showHints;
    });
  }

  void _skipWord() {
    if (_currentWordIndex < _verseWords.length) {
      setState(() {
        _currentWordIndex++;
        _showHints = false;
      });
      _stopListening();
      Future.delayed(Duration(milliseconds: 300), _startListening);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Memorization'),
        leading: BackButton(),
        actions: [
          IconButton(
            icon: Icon(_showHints ? Icons.visibility_off : Icons.visibility),
            onPressed: _toggleHints,
            tooltip: _showHints ? 'Hide hints' : 'Show hints',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  widget.verseReference,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    children: [
                      TextSpan(
                        text: _getCompletedWords() + ' ',
                        style: TextStyle(color: Colors.green),
                      ),
                      TextSpan(
                        text: _getExpectedNextWords(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (_showHints && _currentWordIndex < _verseWords.length)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Next word: "${_verseWords[_currentWordIndex]}"',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                if (_recognizedText.isNotEmpty)
                  Text(
                    'You said: "$_recognizedText"',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                if (_lastRecognizedText.isNotEmpty && _showHints)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Last attempt: "$_lastRecognizedText"',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            Column(
              children: [
                Text(
                  _feedback,
                  style: TextStyle(fontSize: 18, color: _feedbackColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: _skipWord,
                      child: Text('Skip Word'),
                    ),
                  ],
                ),
                Text(
                  'Progress: $_currentWordIndex/${_verseWords.length} words',
                  style: TextStyle(fontSize: 16),
                ),
                LinearProgressIndicator(
                  value: _verseWords.isEmpty
                      ? 0
                      : _currentWordIndex / _verseWords.length,
                  minHeight: 10,
                ),
              ],
            ),
            AvatarGlow(
              animate: _isListening,
              glowColor: Colors.blue,
              endRadius: 60.0,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              child: FloatingActionButton(
                onPressed: _isListening ? _stopListening : _startListening,
                child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
