import 'package:projek_akhir/services/agents/agent_orchestrator.dart';

/// ChatService — thin wrapper untuk backward compatibility.
///
/// Sebelumnya memanggil Gemini langsung (single agent).
/// Sekarang mendelegasikan ke [HagatiAgentOrchestrator] yang
/// mengelola dua agen: WetonAdvisorAgent & CustomsSpecialistAgent.
///
/// Dipakai oleh HomePage._generateAISummary() untuk ringkasan harian.
class ChatService {
  final _orchestrator = HagatiAgentOrchestrator();

  /// Kirim pesan dan kembalikan teks respons saja (tanpa metadata agen).
  /// Untuk kebutuhan yang butuh metadata agen lengkap, gunakan orchestrator langsung.
  Future<String> sendMessage(String message) async {
    final response = await _orchestrator.route(message);
    return response.text;
  }
}