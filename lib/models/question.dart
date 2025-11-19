// lib/models/question.dart

import 'dart:convert';
import 'package:html_unescape/html_unescape.dart'; // <--- NEW IMPORT

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Initialize the unescaper
    final unescape = HtmlUnescape(); // <--- NEW INSTANCE

    // Decode all strings from HTML entities
    final rawQuestion = json['question'] as String;
    final decodedQuestion = unescape.convert(rawQuestion); // <--- DECODED

    final rawCorrectAnswer = json['correct_answer'] as String;
    final decodedCorrectAnswer = unescape.convert(rawCorrectAnswer); // <--- DECODED

    final rawIncorrectAnswers = List<String>.from(json['incorrect_answers']);
    final decodedIncorrectAnswers = rawIncorrectAnswers
        .map((answer) => unescape.convert(answer))
        .toList(); // <--- DECODED LIST

    // Combine incorrect answers with the correct answer and shuffle them.
    List<String> options = decodedIncorrectAnswers;
    options.add(decodedCorrectAnswer);
    options.shuffle();

    return Question(
      question: decodedQuestion, // <--- USE DECODED STRING
      options: options,
      correctAnswer: decodedCorrectAnswer, // <--- USE DECODED STRING
    );
  }
}