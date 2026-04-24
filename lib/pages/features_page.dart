import 'package:flutter/material.dart';
import 'package:projek_akhir/pages/balance_game_page.dart';
import 'package:projek_akhir/pages/chat_page.dart';
import 'package:projek_akhir/pages/quiz_page.dart';
import 'package:projek_akhir/pages/seating_page.dart';
import 'package:projek_akhir/pages/budget_estimator_page.dart';


class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'title': 'Bli-AI Heritage Guide',
        'subtitle': 'Tanya soal adat & hajatan',
        'icon': Icons.auto_awesome,
        'page': const ChatPage(),
      },
      {
        'title': 'Tahu Adat Nggak?',
        'subtitle': 'Kuis interaktif budaya Nusantara',
        'icon': Icons.quiz_outlined,
        'page': const QuizPage(),
      },
      {
        'title': 'Acak Kursi Tamu',
        'subtitle': 'Guncang HP untuk mengacak',
        'icon': Icons.shuffle,
        'page': const SeatingPage(),
      },
      {
        'title': 'Balance the Offerings',
        'subtitle': 'Game gyroscope sesaji',
        'icon': Icons.sports_esports_outlined,
        'page': const BalanceGamePage(),
      },
      
      {
        'title': 'Estimasi Budget Hajatan',
        'subtitle': 'Kalkulasi biaya otomatis berdasarkan skala acara',
        'icon': Icons.calculate_outlined,
        'page': const BudgetEstimatorPage(),
},
    ];

    return Scaffold(
      backgroundColor: const Color(0xfffcf9f8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fitur Interaktif',
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'AI, Game & Sensor',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ...features.map((f) => _featureCard(context, f)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard(
      BuildContext context, Map<String, dynamic> feature) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => feature['page'] as Widget),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFd4af37).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: const Color(0xFFd4af37),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature['title'] as String,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    feature['subtitle'] as String,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}