import 'package:flutter/material.dart';

class TimezoneCard extends StatelessWidget {
  final String code;
  final String fullName;
  final String time;
  final String cities;
  final bool isBase;

  const TimezoneCard({
    super.key,
    required this.code,
    required this.fullName,
    required this.time,
    required this.cities,
    this.isBase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isBase
            ? const Color(0xFFd4af37).withOpacity(0.08)
            : const Color(0xfff6f3f2),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isBase
                ? const Color(0xFFd4af37)
                : const Color(0xFFd4af37).withOpacity(0.3),
            width: isBase ? 4 : 2,
          ),
        ),
      ),
      child: Row(
        children: [
          // Info zona
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isBase
                            ? const Color(0xFF884513)
                            : const Color(0xFF1C1C1C),
                      ),
                    ),
                    if (isBase) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFd4af37),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Lokal',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF884513),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  fullName,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  cities,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),

          // Jam besar
          Text(
            time,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isBase
                  ? const Color(0xFFd4af37)
                  : const Color(0xFF1C1C1C),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}