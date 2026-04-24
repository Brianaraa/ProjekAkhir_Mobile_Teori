class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

// Bank soal — bisa diperluas
const List<QuizQuestion> quizBank = [
  QuizQuestion(
    question: 'Prosesi adat Jawa sebelum akad nikah yang dilakukan malam hari disebut?',
    options: ['Siraman', 'Midodareni', 'Panggih', 'Sungkeman'],
    correctIndex: 1,
    explanation: 'Midodareni adalah prosesi malam sebelum pernikahan, calon pengantin wanita didandani seperti bidadari.',
  ),
  QuizQuestion(
    question: 'Dalam adat Jawa, "neptu" digunakan untuk?',
    options: [
      'Menentukan jumlah tamu undangan',
      'Menghitung hari baik berdasarkan hari dan pasaran',
      'Menentukan mas kawin',
      'Memilih warna pakaian pengantin',
    ],
    correctIndex: 1,
    explanation: 'Neptu adalah nilai hari (Senin=4, dst) dijumlah dengan nilai pasaran (Pon=7, dst) untuk menentukan hari baik.',
  ),
  QuizQuestion(
    question: 'Upacara "siraman" dalam pernikahan adat Jawa bertujuan untuk?',
    options: [
      'Membersihkan jiwa dan raga calon pengantin',
      'Memperkenalkan calon pengantin ke keluarga besar',
      'Menentukan tanggal pernikahan',
      'Menyambut tamu undangan',
    ],
    correctIndex: 0,
    explanation: 'Siraman adalah ritual mandi dengan air kembang untuk membersihkan jiwa dan raga calon pengantin.',
  ),
  QuizQuestion(
    question: 'Dalam kalender Jawa, satu minggu terdiri dari berapa hari pasaran?',
    options: ['3 hari', '4 hari', '5 hari', '7 hari'],
    correctIndex: 2,
    explanation: 'Pekan Jawa (sepasar) terdiri dari 5 hari: Legi, Pahing, Pon, Wage, dan Kliwon.',
  ),
  QuizQuestion(
    question: 'Prosesi "panggih" dalam adat pernikahan Jawa adalah?',
    options: [
      'Prosesi ijab kabul',
      'Prosesi pertemuan kedua mempelai',
      'Prosesi pemberian mas kawin',
      'Prosesi sungkem ke orang tua',
    ],
    correctIndex: 1,
    explanation: 'Panggih (temu) adalah prosesi bertemunya kedua mempelai setelah akad nikah.',
  ),
  QuizQuestion(
    question: 'Upacara "mitoni" atau "tingkeban" dalam adat Jawa dilaksanakan saat kehamilan berumur?',
    options: ['3 bulan', '5 bulan', '7 bulan', '9 bulan'],
    correctIndex: 2,
    explanation: 'Mitoni/tingkeban adalah selamatan kehamilan 7 bulan, angka 7 (pitu) berarti pitulungan (pertolongan).',
  ),
  QuizQuestion(
    question: 'Dalam kalender Hijriyah, bulan yang dianggap paling baik untuk pernikahan adalah?',
    options: ['Muharram', 'Syawwal', 'Rajab', 'Dzulhijjah'],
    correctIndex: 1,
    explanation: 'Bulan Syawwal dianggap bulan sunnah pernikahan karena Nabi Muhammad SAW menikahi Aisyah di bulan ini.',
  ),
  QuizQuestion(
    question: 'Prosesi "sungkeman" dalam adat Jawa adalah?',
    options: [
      'Pengantin memberi salam hormat kepada orang tua',
      'Melempar sirih kepada pengantin wanita',
      'Menyalakan lilin sebagai simbol kehidupan baru',
      'Prosesi makan bersama keluarga besar',
    ],
    correctIndex: 0,
    explanation: 'Sungkeman adalah prosesi pengantin berlutut dan menyembah orang tua sebagai tanda bakti dan memohon restu.',
  ),
  QuizQuestion(
    question: 'Upacara "aqiqah" dalam Islam dilaksanakan pada hari ke berapa setelah bayi lahir?',
    options: ['Hari ke-3', 'Hari ke-7', 'Hari ke-14', 'Hari ke-40'],
    correctIndex: 1,
    explanation: 'Aqiqah disunnahkan pada hari ke-7 setelah kelahiran, dengan menyembelih 2 kambing untuk bayi laki-laki dan 1 untuk perempuan.',
  ),
  QuizQuestion(
    question: 'Dalam budaya Jawa, "selamatan" setelah seseorang meninggal dilakukan pada hari ke?',
    options: [
      '3, 7, 40, 100, 1000',
      '1, 3, 7, 30, 100',
      '7, 14, 30, 100, 1000',
      '3, 9, 27, 100, 1000',
    ],
    correctIndex: 0,
    explanation: 'Selamatan dilaksanakan pada hari ke-3 (nelung dino), ke-7 (mitung dino), ke-40 (matang puluh), ke-100 (nyatus), dan ke-1000 (nyewu).',
  ),
];