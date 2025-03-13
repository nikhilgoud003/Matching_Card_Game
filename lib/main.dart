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

  final int gridSize = 4;

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

  Future<void> flipCard(int index) async {
    if (isBusy || cards[index].isFaceUp || cards[index].isMatched) return;

    setState(() {
      cards[index].isFaceUp = true;
    });

    selectedCards.add(index);

    if (selectedCards.length == 2) {
      isBusy = true;
      pauseTimer();

      await Future.delayed(Duration(milliseconds: 800));

      if (cards[selectedCards[0]].front != cards[selectedCards[1]].front) {
        setState(() {
          cards[selectedCards[0]].isFaceUp = false;
          cards[selectedCards[1]].isFaceUp = false;
          score = math.max(0, score - 5);
        });
      } else {
        setState(() {
          cards[selectedCards[0]].isMatched = true;
          cards[selectedCards[1]].isMatched = true;
          score += 10;

          if (timeElapsed < 30) {
            score += 5;
          }
        });
      }

      selectedCards.clear();
      isBusy = false;
      resumeTimer();
    }

    if (cards.every((card) => card.isMatched)) {
      pauseTimer();
      timer.cancel();

      int stars = 1;
      if (score > 80 && timeElapsed < 60) {
        stars = 3;
      } else if (score > 50 && timeElapsed < 90) {
        stars = 2;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 64),
                SizedBox(height: 16),
                Text(
                  'You completed the game!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      3,
                      (index) => Icon(
                            index < stars ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 36,
                          )),
                ),
                SizedBox(height: 16),
                Table(
                  children: [
                    TableRow(children: [
                      Text('Time:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$timeElapsed seconds'),
                    ]),
                    TableRow(children: [
                      Text('Score:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$score points'),
                    ]),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
                child: Text('PLAY AGAIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
              ),
            ],
          );
        },
      );
    }
  }

  void resetGame() {
    setState(() {
      initializeGame();
      startTimer();
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animal Card Matching Game'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => flipCard(index),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: cards[index].isFaceUp ? Colors.white : Colors.black,
                    child: Center(
                      child: Text(
                        cards[index].isFaceUp
                            ? cards[index].front
                            : cards[index].back,
                        style: TextStyle(
                          fontSize: 30.0,
                          color: cards[index].isFaceUp
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.blue.shade800,
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SCORE',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70)),
                    Text('$score',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TIME',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70)),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.white),
                        SizedBox(width: 4),
                        Text('$timeElapsed s',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
