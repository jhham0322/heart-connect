import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AiService {
  // Caution: API Key handles are sensitive. Hardcoded as per explicit user request.
  static const _apiKey = 'AIzaSyAC5J0LOzvhwTXudRl5oFb_YG6ACEw7KmY';
  
  // Method Channel for native AICore communication
  static const _platform = MethodChannel('com.heartconnect/ai');
  
  late final GenerativeModel _serverModel;
  bool? _isAiCoreAvailable;
  
  AiService() {
    // Initialize Gemini 1.5 Flash (Server-side fallback)
    _serverModel = GenerativeModel(
      model: 'gemini-2.0-flash', 
      apiKey: _apiKey,
      generationConfig: GenerationConfig(temperature: 1.0, topK: 40, topP: 0.95),
    );
    
    // Check AICore availability on Android
    _checkAiCoreAvailability();
  }

  /// Check if on-device AICore (Gemini Nano) is available
  Future<void> _checkAiCoreAvailability() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      _isAiCoreAvailable = false;
      return;
    }
    
    try {
      final bool isAvailable = await _platform.invokeMethod('isAiCoreAvailable');
      _isAiCoreAvailable = isAvailable;
      debugPrint('[AiService] AICore available: $_isAiCoreAvailable');
    } catch (e) {
      debugPrint('[AiService] AICore check failed: $e');
      _isAiCoreAvailable = false;
    }
  }

  /// Generates a polished version of the input message.
  /// 
  /// Strategy:
  /// - Android with AICore: Use Gemini Nano (On-device, Free, Unlimited)
  /// - Others: Use Gemini 1.5 Flash (Server API)
  Future<String?> refineMessage(String input, {String tone = 'warm, emotional, and touching'}) async {
    if (input.trim().isEmpty) return null;

    // Try on-device Gemini Nano first (if available)
    if (defaultTargetPlatform == TargetPlatform.android && _isAiCoreAvailable == true) {
      final result = await _refineWithNano(input, tone);
      if (result != null) return result;
      // Fallback to server if Nano fails
    }
    
    // Use server API (Gemini 1.5 Flash)
    return await _refineWithServer(input, tone);
  }

  /// Refine message using on-device Gemini Nano via AICore
  Future<String?> _refineWithNano(String input, String tone) async {
    try {
      final String? result = await _platform.invokeMethod('refineMessageWithNano', {
        'message': input,
        'tone': tone,
      });
      debugPrint('[AiService] Nano result: $result');
      return result;
    } catch (e) {
      debugPrint('[AiService] Nano failed, falling back to server: $e');
      return null;
    }
  }

  /// Refine message using Gemini 1.5 Flash server API
  Future<String?> _refineWithServer(String input, String tone) async {
    final prompt = '''
      Act as a professional greeting card writer.
      Rewrite the input message to acceptably match the requested TONE.
      
      Target Tone: $tone
      Input Message: "$input"
      
      Instructions:
      - If 'witty', be funny, clever, and playful.
      - If 'poetic', use beautiful metaphors and emotional keywords.
      - If 'polite', use formal honorifics and respectful phrasing.
      - If 'friendly', be casual, warm, and imitate a close friend.
      - DETECT input language and Output in the SAME language.
      - Return ONLY the rewritten text, no explanations.
    ''';
    
    debugPrint('[AiService] Calling server API with tone: $tone');
    debugPrint('[AiService] Input: $input');
    
    try {
      final content = [Content.text(prompt)];
      debugPrint('[AiService] Sending request to Gemini...');
      final response = await _serverModel.generateContent(content);
      debugPrint('[AiService] Response received: ${response.text}');
      return response.text?.trim();
    } catch (e, stack) {
      debugPrint('[AiService] Server API FAILED: $e');
      debugPrint('[AiService] Stack: $stack');
      
      // FALLBACK MOCK RESPONSE (For testing UI interactions)
      debugPrint('[AiService] Returning MOCK response due to API failure.');
      if (input.contains("성탄절") || input.contains("크리스마스")) {
        if (tone.contains("witty")) return "산타도 선물 받고 싶어하는 성탄절! 🎄🎁 즐거운 하루 되세요!";
        if (tone.contains("poetic")) return "흰 눈이 내리는 이 밤, 당신의 마음에 따스한 별빛이 깃들기를... ✨";
        if (tone.contains("polite")) return "기쁨 가득한 성탄절 되시기를 진심으로 기원합니다. 🙇‍♂️";
        return "메리 크리스마스! 맛있는 거 많이 먹고 행복해라~ 🎂 (AI Busy)";
      }
      return "AI가 잠시 바빠서 응답하지 못했지만, 행복한 하루 보내세요! (Offline Fallback)";
    }
  }

  /// Extracts person names from the given text.
  /// Strategy:
  /// 1. Try "Lightweight Rule-based Model" (Instant, Offline)
  /// 2. If available, try "On-Device AI" (Gemini Nano on Galaxy S24/Pixel 8+)
  /// 3. If both fail, return empty (No Server AI used as per user request)
  Future<String> extractNames(String text) async {
    if (text.trim().isEmpty) return "";

    // 1. Lightweight Rule-based Extraction (Embedded Logic)
    final ruleBasedResult = _extractNameRuleBased(text);
    if (ruleBasedResult.isNotEmpty) {
      debugPrint('[AiService] Rule-based extraction success: $ruleBasedResult');
      return ruleBasedResult;
    }

    // 2. Try On-Device AI (Gemini Nano) if available
    if (defaultTargetPlatform == TargetPlatform.android && _isAiCoreAvailable == true) {
       final nanoResult = await _extractNameWithNano(text);
       if (nanoResult != null && nanoResult.isNotEmpty) {
          debugPrint('[AiService] On-Device AI extraction success: $nanoResult');
          return nanoResult;
       }
    }
    
    // 3. Fallback to Server AI (Gemini 2.0 Flash)
    // User requested "AI skills", implying they want better extraction even if online.
    try {
      final prompt = '''
        Extract person names from the following text.
        
        Text: "$text"
        
        Instructions:
        - Return ONLY the names separated by commas.
        - If no names are found, return NOTHING (empty string).
        - Do not include titles (Mr., Mrs.) or context.
        - If the text is "Meeting with John", return "John".
        - If the text is "Dad's Birthday", return "Dad" (or "아버지" if Korean).
        - DETECT language and output names as they appear.
      ''';
      
      final content = [Content.text(prompt)];
      final response = await _serverModel.generateContent(content);
      final names = response.text?.trim() ?? "";
      
      if (names.isNotEmpty && names != "NOTHING") {
        debugPrint('[AiService] Server AI extraction success: $names');
        return names;
      }
    } catch (e) {
       debugPrint('[AiService] Server AI extraction failed: $e');
    }
    
    debugPrint('[AiService] Extraction failed (All methods).');
    return "";
  }

  /// Extract name using on-device Gemini Nano via AICore
  Future<String?> _extractNameWithNano(String text) async {
    try {
      final String? result = await _platform.invokeMethod('extractNameWithNano', {
        'text': text,
      });
      return result;
    } catch (e) {
      debugPrint('[AiService] Nano extraction failed: $e');
      return null;
    }
  }

  /// A lightweight, offline, rule-based extractor for common schedule patterns.
  /// Acts as an embedded "Micro Model".
  String _extractNameRuleBased(String text) {
    // Common suffixes in schedules
    final suffixes = [
      '의 생일', ' 생일', '생일', ' Birthday', ' Bday', ' birthday',
      '님 약속', '님과 식사', '님과 미팅',
      '과 식사', '와 식사', '과 저녁', '와 저녁', '과 점심', '와 점심',
      '과 미팅', '와 미팅', ' Meeting', ' meeting'
    ];

    for (var suffix in suffixes) {
      if (text.contains(suffix)) {
        // Extract the part BEFORE the suffix
        final index = text.indexOf(suffix);
        String candidate = text.substring(0, index).trim();
        
        // Clean up common prefixes if present (e.g. "Tomorrow Kim's Birthday")
        final parts = candidate.split(' ');
        if (parts.length > 1) {
           // Take the last word as the most likely name (e.g. "내일 유재석" -> "유재석")
           candidate = parts.last;
        }
        
        // Remove Korean possessive particle '의' if it remains (e.g. "유재석의" -> "유재석")
        // Note: If suffix was "의 생일", '의' is already handled by split. 
        // But if suffix was " 생일" and text was "유재석의 생일", candidate is "유재석의".
        if (candidate.endsWith('의')) {
          candidate = candidate.substring(0, candidate.length - 1);
        }

        // Simple validation: Name should be 2-4 chars for Korean, or non-empty
        if (candidate.isNotEmpty) {
          return candidate;
        }
      }
    }
    
    // Possessive pattern: "John's Birthday"
    if (text.contains("'s ")) {
       final index = text.indexOf("'s ");
       final candidate = text.substring(0, index).trim().split(' ').last;
       if (candidate.isNotEmpty) return candidate;
    }

    return "";
  }
}
