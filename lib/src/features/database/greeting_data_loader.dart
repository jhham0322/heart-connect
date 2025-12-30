import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:heart_connect/src/features/database/app_database.dart';
import 'package:drift/drift.dart';

/// 인사말 샘플 파일 파싱 및 DB 삽입 유틸리티
class GreetingDataLoader {
  final AppDatabase db;
  
  GreetingDataLoader(this.db);
  
  /// 감성 매핑: 한글 -> 영문
  static const Map<String, String> sentimentMapping = {
    '정중': 'polite',
    '위트': 'witty',
    '친근': 'friendly',
    '감동': 'poetic',
  };
  
  /// 에셋에서 인사말 샘플 파일 로드 후 DB에 삽입
  Future<void> loadGreetingSamplesFromAsset(String assetPath) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      await parseAndInsertGreetings(content);
    } catch (e) {
      // Error loading greetings - silent fail
    }
  }
  
  /// 문자열 내용 파싱 후 DB에 삽입
  Future<void> parseAndInsertGreetings(String content) async {
    final lines = content.split('\n');
    final Set<String> topics = {};
    final List<GreetingTemplatesCompanion> greetings = [];
    
    // 정규표현식: [주제:감성]{문구들}
    final regex = RegExp(r'\[([^:]+):([^\]]+)\]\{([^}]+)\}');
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      final match = regex.firstMatch(trimmedLine);
      if (match != null) {
        final topic = match.group(1)!.trim();
        final sentimentKr = match.group(2)!.trim();
        final messagesStr = match.group(3)!;
        
        // 감성 한글 -> 영문 변환
        final sentiment = sentimentMapping[sentimentKr] ?? sentimentKr.toLowerCase();
        
        // 주제 수집
        topics.add(topic);
        
        // 문구들 파싱 (쉼표로 구분된 따옴표 문자열)
        final messages = _parseMessages(messagesStr);
        
        for (final message in messages) {
          if (message.isNotEmpty) {
            greetings.add(GreetingTemplatesCompanion.insert(
              topic: topic,
              sentiment: sentiment,
              message: message,
            ));
          }
        }
      }
    }
    
    // 주제 삽입
    await db.insertGreetingTopicsIfEmpty(topics.toList());
    
    // 인사말 삽입 (기존 데이터가 없을 때만)
    final existingGreetings = await db.getAllGreetingTemplates();
    if (existingGreetings.isEmpty && greetings.isNotEmpty) {
      await db.insertGreetings(greetings);
    }
  }
  
  /// 문구 문자열 파싱: "문구1", "문구2", ... -> List<String>
  List<String> _parseMessages(String messagesStr) {
    final List<String> result = [];
    final regex = RegExp(r'"([^"]*)"');
    final matches = regex.allMatches(messagesStr);
    
    for (final match in matches) {
      final message = match.group(1)?.trim();
      if (message != null && message.isNotEmpty) {
        result.add(message);
      }
    }
    
    return result;
  }
  
  /// DB에 주제 목록이 있는지 확인
  Future<bool> hasGreetingData() async {
    final topics = await db.getAllGreetingTopics();
    return topics.isNotEmpty;
  }
  
  /// 통계 정보 출력
  Future<Map<String, int>> getStatistics() async {
    final topics = await db.getAllGreetingTopics();
    final greetings = await db.getAllGreetingTemplates();
    
    return {
      'topics': topics.length,
      'greetings': greetings.length,
    };
  }
}
