import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hpp_history.dart';
import '../models/hpp_template.dart';

class StorageService {
  static const String _historyKey = 'hpp_history';
  static const String _templateKey = 'hpp_template';

  // Menyimpan riwayat perhitungan
  Future<bool> saveHistory(List<HppHistory> histories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = histories.map((h) => jsonEncode(h.toJson())).toList();
      return await prefs.setStringList(_historyKey, jsonData);
    } catch (e) {
      print('Error saving history: $e');
      return false;
    }
  }

  // Mengambil riwayat perhitungan
  Future<List<HppHistory>> getHistories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getStringList(_historyKey) ?? [];
      return jsonData
          .map((data) => HppHistory.fromJson(jsonDecode(data)))
          .toList();
    } catch (e) {
      print('Error getting histories: $e');
      return [];
    }
  }

  // Menambahkan riwayat baru
  Future<bool> addHistory(HppHistory history) async {
    try {
      final histories = await getHistories();
      histories.insert(0, history); // Tambahkan di awal list
      
      // Batasi jumlah riwayat yang disimpan (opsional)
      if (histories.length > 10) {
        histories.removeLast();
      }
      
      return await saveHistory(histories);
    } catch (e) {
      print('Error adding history: $e');
      return false;
    }
  }

  // Menghapus riwayat
  Future<bool> deleteHistory(String id) async {
    try {
      final histories = await getHistories();
      histories.removeWhere((h) => h.id == id);
      return await saveHistory(histories);
    } catch (e) {
      print('Error deleting history: $e');
      return false;
    }
  }

  // Menghapus semua riwayat
  Future<bool> clearAllHistories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing histories: $e');
      return false;
    }
  }
  
  // Template methods
  Future<List<HppTemplate>> getTemplateList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templateJson = prefs.getStringList(_templateKey) ?? [];
      return templateJson
          .map((item) => HppTemplate.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      print('Error getting templates: $e');
      return [];
    }
  }
  
  Future<bool> addTemplate(HppTemplate template) async {
    try {
      final templates = await getTemplateList();
      templates.add(template);
      return await saveTemplates(templates);
    } catch (e) {
      print('Error adding template: $e');
      return false;
    }
  }
  
  Future<bool> saveTemplates(List<HppTemplate> templates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = templates.map((t) => jsonEncode(t.toJson())).toList();
      return await prefs.setStringList(_templateKey, jsonData);
    } catch (e) {
      print('Error saving templates: $e');
      return false;
    }
  }
  
  Future<bool> deleteTemplate(String id) async {
    try {
      final templates = await getTemplateList();
      templates.removeWhere((t) => t.id == id);
      return await saveTemplates(templates);
    } catch (e) {
      print('Error deleting template: $e');
      return false;
    }
  }
}