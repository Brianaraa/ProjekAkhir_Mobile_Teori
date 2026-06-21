// Javanese Calendar Tools — Pure Dart, no external dependencies.
//
// Fungsi-fungsi ini dipakai sebagai "Agent Skill / Tool" yang didaftarkan
// ke Gemini API sebagai FunctionDeclaration. Ketika Gemini memutuskan
// butuh data weton yang akurat, ia akan memanggil tool ini secara otomatis
// (Function Calling / Tool Use).

// ── Tabel neptu hari (Senin–Minggu, mengikuti index weekday Dart) ─────────
// Dart: weekday → 1=Mon, 2=Tue, ..., 7=Sun
const Map<String, int> _neptuHari = {
  'Senin': 4,
  'Selasa': 3,
  'Rabu': 7,
  'Kamis': 8,
  'Jumat': 6,
  'Sabtu': 9,
  'Minggu': 5,
};

// ── Tabel neptu pasaran ───────────────────────────────────────────────────
const Map<String, int> _neptuPasaran = {
  'Legi': 5,
  'Pahing': 9,
  'Pon': 7,
  'Wage': 4,
  'Kliwon': 8,
};

// ── Urutan pasaran (basis: 1 Januari 2000 = Sabtu Legi, index 1) ─────────
const List<String> _pasaranList = ['Kliwon', 'Legi', 'Pahing', 'Pon', 'Wage'];

// ── Nama hari dalam seminggu (weekday Dart 1–7) ───────────────────────────
const Map<int, String> _namaHari = {
  1: 'Senin',
  2: 'Selasa',
  3: 'Rabu',
  4: 'Kamis',
  5: 'Jumat',
  6: 'Sabtu',
  7: 'Minggu',
};

// ─────────────────────────────────────────────────────────────────────────
// Fungsi Publik
// ─────────────────────────────────────────────────────────────────────────

/// Menghitung hari pasaran Jawa dari [date].
/// Return: 'Legi' | 'Pahing' | 'Pon' | 'Wage' | 'Kliwon'
String hitungPasaran(DateTime date) {
  final base = DateTime(2000, 1, 1); // Sabtu Legi (index 1 dalam _pasaranList)
  final diff = date.difference(base).inDays;
  // index 1 = Legi, shift ke 0-based: (diff + 1) % 5
  return _pasaranList[(diff + 1) % 5];
}

/// Mengembalikan nama hari dalam Bahasa Indonesia dari [date].
String hitungNamaHari(DateTime date) => _namaHari[date.weekday] ?? 'Minggu';

/// Menghitung neptu total (hari + pasaran) dari [date].
int hitungNeptu(DateTime date) {
  final hari = hitungNamaHari(date);
  final pasaran = hitungPasaran(date);
  return (_neptuHari[hari] ?? 0) + (_neptuPasaran[pasaran] ?? 0);
}

/// Fungsi utama yang dipanggil oleh WetonAdvisorAgent sebagai Tool.
///
/// Menerima string tanggal format 'YYYY-MM-DD', mengembalikan Map
/// berisi data weton lengkap yang bisa langsung dikirim ke Gemini
/// sebagai function response.
///
/// Contoh return:
/// ```json
/// {
///   "tanggal_input": "2026-12-12",
///   "hari": "Sabtu",
///   "pasaran": "Pon",
///   "neptu": 16,
///   "weton": "Sabtu Pon",
///   "neptu_hari": 9,
///   "neptu_pasaran": 7,
///   "catatan": "Neptu 16: ..."
/// }
/// ```
Map<String, dynamic> hitungWetonJawa(String tanggalStr) {
  DateTime date;
  try {
    date = DateTime.parse(tanggalStr);
  } catch (_) {
    return {
      'error': 'Format tanggal tidak valid. Gunakan format YYYY-MM-DD.',
      'tanggal_input': tanggalStr,
    };
  }

  final hari = hitungNamaHari(date);
  final pasaran = hitungPasaran(date);
  final neptuH = _neptuHari[hari] ?? 0;
  final neptuP = _neptuPasaran[pasaran] ?? 0;
  final totalNeptu = neptuH + neptuP;
  final weton = '$hari $pasaran';

  // Penafsiran sederhana berdasarkan neptu (berdasar primbon Jawa umum)
  String penafsiran;
  if (totalNeptu >= 16) {
    penafsiran =
        'Neptu $totalNeptu tergolong tinggi dan sangat baik. Weton $weton '
        'membawa energi kuat, cocok untuk hari akad pernikahan.';
  } else if (totalNeptu >= 13) {
    penafsiran =
        'Neptu $totalNeptu tergolong baik. Weton $weton cukup menguntungkan '
        'untuk memulai ikatan pernikahan.';
  } else if (totalNeptu >= 10) {
    penafsiran =
        'Neptu $totalNeptu cukup. Weton $weton netral, dapat dilaksanakan '
        'dengan persiapan dan doa yang matang.';
  } else {
    penafsiran =
        'Neptu $totalNeptu tergolong rendah. Sebaiknya konsultasikan dengan '
        'sesepuh atau pilih hari alternatif yang lebih baik.';
  }

  return {
    'tanggal_input': tanggalStr,
    'hari': hari,
    'pasaran': pasaran,
    'neptu_hari': neptuH,
    'neptu_pasaran': neptuP,
    'neptu_total': totalNeptu,
    'weton': weton,
    'penafsiran_neptu': penafsiran,
  };
}
