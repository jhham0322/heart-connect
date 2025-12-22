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
    _serverModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    
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
  Future<String?> refineMessage(String input) async {
    if (input.trim().isEmpty) return null;

    // Try on-device Gemini Nano first (if available)
    if (defaultTargetPlatform == TargetPlatform.android && _isAiCoreAvailable == true) {
      final result = await _refineWithNano(input);
      if (result != null) return result;
      // Fallback to server if Nano fails
    }
    
    // Use server API (Gemini 1.5 Flash)
    return await _refineWithServer(input);
  }

  /// Refine message using on-device Gemini Nano via AICore
  Future<String?> _refineWithNano(String input) async {
    try {
      final String? result = await _platform.invokeMethod('refineMessageWithNano', {
        'message': input,
      });
      debugPrint('[AiService] Nano result: $result');
      return result;
    } catch (e) {
      debugPrint('[AiService] Nano failed, falling back to server: $e');
      return null;
    }
  }

  /// Refine message using Gemini 1.5 Flash server API
  Future<String?> _refineWithServer(String input) async {
    final prompt = '''
      You are a poetic assistant. Rewrite the following greeting card message to be more warm, emotional, and touching. 
      Keep the meaning same but improve the expression. 
      Autodetect the language of the input and output in the SAME language.
      Do not add explanations, just return the rewritten message.
      
      Input Message: "$input"
    ''';
    
    try {
      final content = [Content.text(prompt)];
      final response = await _serverModel.generateContent(content);
      return response.text?.trim();
    } catch (e) {
      debugPrint('[AiService] Server API failed: $e');
      return null;
    }
  }
}
