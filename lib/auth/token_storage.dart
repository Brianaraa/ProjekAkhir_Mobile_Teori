import 'dart:math';

String generateToken() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random();
  return List.generate(32, (index) => chars[rand.nextInt(chars.length)]).join();
}