import 'package:flutter/material.dart';
import 'package:projek_akhir/models/quiz_model.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _quizFinished = false;

  List<QuizQuestion> get _questions => quizBank;
  QuizQuestion get _current => _questions[_currentIndex];

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _current.correctIndex) _score++;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      setState(() => _quizFinished = true);
    }
  }

  void _restart() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedOption = null;
      _answered = false;
      _quizFinished = false;
    });
  }

  Color _optionColor(int index) {
    if (!_answered) return Colors.white;
    if (index == _current.correctIndex) return const Color(0xFFE8F5E9);
    if (index == _selectedOption) return const Color(0xFFFFEBEE);
    return Colors.white;
  }

  Color _optionBorder(int index) {
    if (!_answered) return Colors.grey.shade200;
    if (index == _current.correctIndex) return Colors.green;
    if (index == _selectedOption) return Colors.red;
    return Colors.grey.shade200;
  }

  IconData? _optionIcon(int index) {
    if (!_answered) return null;
    if (index == _current.correctIndex) return Icons.check_circle;
    if (index == _selectedOption) return Icons.cancel;
    return null;
  }

  Color? _optionIconColor(int index) {
    if (index == _current.correctIndex) return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      appBar: AppBar(
        backgroundColor: const Color(0xfffcf9f8),
        elevation: 0,
        title: const Text(
          'Tahu Adat Nggak? 🎯',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF1C1C1C)),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFd4af37).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Skor: $_score',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF884513),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _quizFinished ? _resultScreen() : _questionScreen(),
    );
  }

  Widget _questionScreen() {
    final progress = (_currentIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                'Soal ${_currentIndex + 1} dari ${_questions.length}',
                style:
                    const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '${(_score / (_currentIndex + (_answered ? 1 : 0.0001)) * 100).isNaN ? 0 : (_score / (_currentIndex + (_answered ? 1 : 0.0001)) * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFd4af37),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFFd4af37),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 28),

          // Kartu pertanyaan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFd4af37).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFd4af37).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.quiz_outlined,
                    color: Color(0xFFd4af37), size: 32),
                const SizedBox(height: 12),
                Text(
                  _current.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pilihan jawaban
          ...List.generate(_current.options.length, (i) {
            return GestureDetector(
              onTap: () => _selectOption(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _optionColor(i),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _optionBorder(i), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          ['A', 'B', 'C', 'D'][i],
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _current.options[i],
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                    if (_answered && _optionIcon(i) != null)
                      Icon(_optionIcon(i),
                          color: _optionIconColor(i), size: 22),
                  ],
                ),
              ),
            );
          }),

          // Penjelasan jawaban
          if (_answered) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _current.explanation,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFd4af37),
                foregroundColor: const Color(0xFF884513),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
              child: Text(
                _currentIndex < _questions.length - 1
                    ? 'Soal Berikutnya →'
                    : 'Lihat Hasil',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultScreen() {
    final percentage = (_score / _questions.length * 100).round();
    String title;
    String emoji;
    Color color;

    if (percentage >= 80) {
      title = 'Luar Biasa!';
      emoji = '🏆';
      color = Colors.green;
    } else if (percentage >= 60) {
      title = 'Bagus!';
      emoji = '⭐';
      color = const Color(0xFFd4af37);
    } else {
      title = 'Terus Belajar!';
      emoji = '📚';
      color = Colors.orange;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu menjawab benar $_score dari ${_questions.length} soal',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Skor besar
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 6),
                color: color.withOpacity(0.08),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                    Text(
                      '$_score / ${_questions.length}',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFd4af37),
                foregroundColor: const Color(0xFF884513),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
              child: const Text(
                'Main Lagi 🎯',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}