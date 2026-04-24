import 'package:flutter/material.dart';
import 'package:projek_akhir/models/currency_model.dart';

class CurrencyCard extends StatelessWidget {
  final CurrencyModel rate;
  final double inputAmount;

  const CurrencyCard({
    super.key,
    required this.rate,
    required this.inputAmount,
  });

  // Flag emoji berdasarkan kode mata uang
  String get _flag {
    switch (rate.code) {
      case 'MYR': return '🇲🇾';
      case 'SAR': return '🇸🇦';
      case 'USD': return '🇺🇸';
      case 'SGD': return '🇸🇬';
      case 'EUR': return '🇪🇺';
      case 'GBP': return '🇬🇧';
      default:    return '🏳';
    }
  }

  String get _resultText {
    if (inputAmount <= 0) {
      return '1 IDR = ${rate.rate.toStringAsFixed(6)} ${rate.code}';
    }
    final converted = rate.convert(inputAmount);
    // Format angka dengan pemisah ribuan
    if (converted >= 1000) {
      return converted.toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return converted.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final hasAmount = inputAmount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: Color(0xFFd4af37), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Flag + kode
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 2),
              Text(
                rate.code,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              Text(
                rate.name,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),

          const Spacer(),

          // Hasil konversi
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hasAmount ? _resultText : '-',
                style: TextStyle(
                  fontSize: hasAmount ? 20 : 14,
                  fontWeight: FontWeight.bold,
                  color: hasAmount
                      ? const Color(0xFF884513)
                      : Colors.grey,
                ),
              ),
              if (hasAmount) ...[
                const SizedBox(height: 2),
                Text(
                  '1 IDR = ${rate.rate.toStringAsFixed(6)}',
                  style: const TextStyle(
                      fontSize: 10, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 4),
              // Badge kode mata uang
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFd4af37).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rate.code,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF884513),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}