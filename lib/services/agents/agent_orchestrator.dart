import 'weton_advisor_agent.dart';
import 'customs_specialist_agent.dart';

/// Enum untuk mengidentifikasi agen mana yang aktif merespons.
enum ActiveAgent { wetonAdvisor, customsSpecialist }

/// Hasil routing dari orchestrator, berisi respons teks dan label agen aktif.
class AgentResponse {
  final String text;
  final ActiveAgent agent;
  final bool toolWasUsed;

  const AgentResponse({
    required this.text,
    required this.agent,
    this.toolWasUsed = false,
  });

  /// Label pendek untuk ditampilkan di UI chat bubble.
  String get agentLabel {
    switch (agent) {
      case ActiveAgent.wetonAdvisor:
        return toolWasUsed
            ? '🔮 Weton Advisor  •  🔧 Tool Active'
            : '🔮 Weton Advisor';
      case ActiveAgent.customsSpecialist:
        return '🎭 Customs Specialist';
    }
  }
}

/// HAGATI Agent Orchestrator
///
/// [Konsep 1 – Multi-Agent System]
/// Class ini adalah komponen sentral dari sistem multi-agen HAGATI.
/// Fungsinya: menerima pesan dari user, mendeteksi topiknya, lalu
/// mendelegasikan ke agen yang paling tepat.
///
///   ┌──────────────────────────────┐
///   │    HagatiAgentOrchestrator   │  ← Entry point tunggal
///   └──────────────┬───────────────┘
///                  │  Route by topic keyword detection
///        ┌─────────┴──────────┐
///        ▼                    ▼
///  WetonAdvisorAgent    CustomsSpecialistAgent
///  (kalender, weton,    (prosesi adat, ritual,
///   neptu, hari baik)    busana, sesaji, budget)
///
/// Routing Strategy:
/// - Deteksi keyword weton/kalender/tanggal → WetonAdvisorAgent
/// - Semua topik lain → CustomsSpecialistAgent
class HagatiAgentOrchestrator {
  final WetonAdvisorAgent _wetonAgent = WetonAdvisorAgent();
  final CustomsSpecialistAgent _customsAgent = CustomsSpecialistAgent();

  // ── Keyword set untuk routing ke WetonAdvisorAgent ────────────────────
  static const Set<String> _wetonKeywords = {
    // Kata kunci kalender & weton
    'weton', 'pasaran', 'neptu', 'primbon',
    'legi', 'pahing', 'pon', 'wage', 'kliwon',
    'wuku', 'pranata mangsa',
    // Kata kunci hari baik
    'hari baik', 'tanggal baik', 'hari bagus', 'hari pernikahan',
    'kapan nikah', 'kapan menikah', 'pilih tanggal', 'cari tanggal',
    // Prefix khusus dari date picker
    '[weton_date:',
    // Kata kunci tanggal
    'tanggal nikah', 'tanggal akad', 'tanggal resepsi',
    'bulan depan', 'tahun depan',
  };

  /// Routing utama: deteksi topik dan delegasikan ke agen yang tepat.
  /// Return [AgentResponse] berisi teks + metadata agen yang dipakai.
  Future<AgentResponse> route(String message) async {
    final normalized = message.toLowerCase();

    // ── Bypass untuk ringkasan harian (Bli-AI Insight) dari HomePage ──────
    // Prompt ringkasan memuat weton hari ini sehingga sering salah ter-routing
    // ke WetonAdvisorAgent yang mencoba memanggil Tool (dan memicu error).
    if (normalized.contains('[insight_summary]')) {
      final text = await _customsAgent.sendMessage(message);
      return AgentResponse(
        text: text,
        agent: ActiveAgent.customsSpecialist,
      );
    }

    // ── Cek apakah pesan mengandung keyword weton ─────────────────────
    bool isWetonTopic = _wetonKeywords.any(
      (kw) => normalized.contains(kw),
    );

    // ── Deteksi format date dari date picker [WETON_DATE:YYYY-MM-DD] ──
    // Format ini dikirim oleh ChatPage saat user memakai date picker.
    if (normalized.contains('[weton_date:')) {
      isWetonTopic = true;
    }

    if (isWetonTopic) {
      // Delegasi ke Weton Advisor Agent
      final text = await _wetonAgent.sendMessage(message);
      return AgentResponse(
        text: text,
        agent: ActiveAgent.wetonAdvisor,
        toolWasUsed: _wetonAgent.lastCallUsedTool,
      );
    } else {
      // Delegasi ke Customs Specialist Agent
      final text = await _customsAgent.sendMessage(message);
      return AgentResponse(
        text: text,
        agent: ActiveAgent.customsSpecialist,
      );
    }
  }
}
