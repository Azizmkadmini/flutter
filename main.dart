import 'dart:convert';
import 'package:flutter/material.dart';

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  Map<int, dynamic> _selectedAnswers = {}; // Stocke les réponses sélectionnées par l'utilisateur
  int _score = 0; // Score initialisé à zéro
  bool _answersSubmitted = false; // Variable pour suivre si les réponses ont été soumises

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    String jsonString =
        await DefaultAssetBundle.of(context).loadString('assets/questions.json');
    List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      _questions = jsonList.map((json) => Question.fromJson(json)).toList(); // Convertit les données JSON en liste d'objets Question
    });
  }

  void _submitAnswers() {
    int correctAnswers = 0;
    _selectedAnswers.forEach((questionIndex, selectedAnswer) {
      if (_questions[questionIndex].answer == selectedAnswer) { // Vérifie si la réponse sélectionnée correspond à la réponse correcte
        correctAnswers++;
        _questions[questionIndex].isAnsweredCorrectly = true; // Marque la question comme répondue correctement
      } else {
        _questions[questionIndex].isAnsweredCorrectly = false; // Marque la question comme répondue incorrectement
      }
    });
    setState(() {
      _score = correctAnswers; // Met à jour le score avec le nombre de réponses correctes
      _answersSubmitted = true; // Indique que les réponses ont été soumises
    });
    // Affiche une boîte de dialogue avec les résultats du quiz
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Résultats du quiz'),
          content: Text(
              'Vous avez obtenu $_score bonnes réponses sur ${_questions.length}.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: _questions.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: QuestionWidget(
                          question: _questions[index],
                          onAnswerSelected: (selectedAnswer) {
                            setState(() {
                              _selectedAnswers[index] = selectedAnswer; // Enregistre la réponse sélectionnée par l'utilisateur
                            });
                          },
                          selectedAnswer: _selectedAnswers.containsKey(index)
                              ? _selectedAnswers[index]
                              : null, // Vérifie si une réponse a été sélectionnée pour cette question
                          isAnsweredCorrectly: _answersSubmitted ? _questions[index].isAnsweredCorrectly : null, // Vérifie si la réponse a été soumise et récupère si la question a été répondue correctement
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _submitAnswers,
                    child: Text('Soumettre les réponses'),
                  ),
                ),
                Text(
                  'Score: $_score / ${_questions.length}',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final dynamic answer;
  bool isAnsweredCorrectly;

  Question({
    required this.question,
    required this.options,
    required this.answer,
    this.isAnsweredCorrectly = false, // Initialise la propriété à false par défaut
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final Question question;
  final ValueChanged<dynamic> onAnswerSelected;
  final dynamic selectedAnswer;
  final bool? isAnsweredCorrectly;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.onAnswerSelected,
    required this.selectedAnswer,
    required this.isAnsweredCorrectly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    if (isAnsweredCorrectly != null) {
      backgroundColor = isAnsweredCorrectly! ? Colors.green : Colors.red; // Définit la couleur en vert si la question a été répondue correctement, sinon en rouge
    }

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: question.options.asMap().entries.map((entry) {
                int index = entry.key;
                String option = entry.value;
                return RadioListTile(
                  title: Text(option),
                  value: index,
                  groupValue: selectedAnswer,
                  onChanged: (value) {
                    onAnswerSelected(value);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
