import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      print(e);
      // Handle error appropriately (e.g., show a dialog to the user)
      setState(() {
        _loading = false;
        // Optionally set an error message
      });
    }
  }

  void _submitAnswer(String selectedAnswer) {
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;

      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _answered = false;
      _selectedAnswer = "";
      _feedbackText = "";
      _currentQuestionIndex++;
    });
  }

  Widget _buildOptionButton(String option) {
    final isCorrect = option == _questions[_currentQuestionIndex].correctAnswer;
    final isSelected = option == _selectedAnswer;

    Color? getButtonColor() {
      if (!_answered) {
        return Colors.blue; // Default color before answering
      } else {
        if (isCorrect) {
          return Colors.green; // Correct answer is always green
        } else if (isSelected) {
          return Colors.red; // Incorrectly selected answer is red
        } else {
          return Colors.grey; // Unselected incorrect answer
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        // Disable button if an answer has already been submitted
        onPressed: _answered ? null : () => _submitAnswer(option),
        child: Text(option),
        style: ElevatedButton.styleFrom(
          primary: getButtonColor(),
          onPrimary: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if the quiz is finished
    if (_currentQuestionIndex >= _questions.length) {
      return Scaffold(
        body: Center(
          child:
              Text('Quiz Finished! Your Score: $_score/${_questions.length}'),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Trivia Quiz App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              question.question,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Dynamically generate option buttons
            ...question.options.map((option) => _buildOptionButton(option)).toList(),
            
            SizedBox(height: 20),
            
            // Feedback and Next Button section
            if (_answered) ...[
              Text(
                _feedbackText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _selectedAnswer == question.correctAnswer
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text('Next Question'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}