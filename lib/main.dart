import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;

void main() => runApp(MyApp());

class CardModel {
  String front;
  String back;
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.front,
    required this.back,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CardMatchingGame(),
    );
  }
}

class CardMatchingGame extends StatefulWidget {
  @override
  _CardMatchingGameState createState() => _CardMatchingGameState();
}

class _CardMatchingGameState extends State<CardMatchingGame> {
  late List<CardModel> cards;
  late List<int> selectedCards;
  late bool isBusy;
  late Timer timer;
  int score = 0;
  int timeElapsed = 0;
  bool isTimerActive = true;

  final int gridSize = 4; // Change grid size here

  @override
  void initState() {
    super.initState();
    initializeGame();
    startTimer();
  }
 void initializeGame() {
    List<String> icons = [
      '🐶',
      '🐱',
      '🐭',
      '🐹',
      '🐰',
      '🦊',
      '🐻',
      '🐼',
      '🐨',
      '🦁',
      '🐯',
      '🐮'
    ];

    int totalPairs = (gridSize * gridSize) ~/ 2;
    if (icons.length < totalPairs) {
      throw Exception('Not enough icons to populate the grid.');
    }

    cards = [];
    for (int i = 0; i < totalPairs; i++) {
      cards.add(CardModel(front: icons[i], back: '■'));
      cards.add(CardModel(front: icons[i], back: '■'));
    }
    cards.shuffle();
    selectedCards = [];
    isBusy = false;
  }

  void startTimer() {
    timeElapsed = 0;
    isTimerActive = true;
    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (isTimerActive) {
          timeElapsed++;
        }
      });
    });
  }

  void pauseTimer() {
    setState(() {
      isTimerActive = false;
    });
  }

  void resumeTimer() {
    setState(() {
      isTimerActive = true;
    });
  }