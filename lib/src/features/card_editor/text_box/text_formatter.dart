import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 텍스트 포맷터
/// 
/// 텍스트박스의 폰트와 너비를 기반으로 자연스러운 줄 바꿈을 처리합니다.
/// 한국어의 자연스러운 띄어쓰기와 문장 구조를 고려합니다.
class TextFormatter {
  /// 텍스트 너비 측정
  static double measureTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  /// 한 글자의 평균 너비 측정 (한글 기준)
  static double measureCharWidth(TextStyle style) {
    // 한글 대표 글자로 측정
    const sampleChars = '가나다라마바사아자차카타파하';
    final totalWidth = measureTextWidth(sampleChars, style);
    return totalWidth / sampleChars.length;
  }

  /// 텍스트 스타일 생성
  static TextStyle createTextStyle({
    required String fontFamily,
    required double fontSize,
    Color? textColor,
    bool isBold = false,
    bool isItalic = false,
  }) {
    TextStyle style;
    try {
      style = GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        color: textColor ?? Colors.black,
        height: 1.4,
      );
    } catch (e) {
      style = TextStyle(
        fontSize: fontSize,
        color: textColor ?? Colors.black,
        height: 1.4,
      );
    }

    return style.copyWith(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
    );
  }

  /// 텍스트박스 너비와 폰트 설정에 맞게 줄 바꿈 적용
  /// 
  /// [text]: 원본 텍스트
  /// [boxWidth]: 텍스트박스 너비
  /// [style]: 텍스트 스타일
  /// [padding]: 좌우 패딩 (기본 48 = 24 * 2)
  /// 
  /// 반환: 줄 바꿈이 적용된 텍스트
  static String formatTextForBox({
    required String text,
    required double boxWidth,
    required TextStyle style,
    double padding = 48.0,
  }) {
    if (text.isEmpty) return text;
    
    // 실제 사용 가능한 너비
    final availableWidth = boxWidth - padding;
    if (availableWidth <= 0) return text;
    
    // 이미 줄바꿈이 있는 경우 각 줄을 별도로 처리
    final existingLines = text.split('\n');
    final formattedLines = <String>[];
    
    for (final line in existingLines) {
      final wrappedLines = _wrapLine(line.trim(), availableWidth, style);
      formattedLines.addAll(wrappedLines);
    }
    
    return formattedLines.join('\n');
  }

  /// 단일 줄을 너비에 맞게 줄 바꿈
  static List<String> _wrapLine(String line, double maxWidth, TextStyle style) {
    if (line.isEmpty) return [''];
    
    // 해당 줄이 이미 너비 내에 들어가면 그대로 반환
    if (measureTextWidth(line, style) <= maxWidth) {
      return [line];
    }
    
    final result = <String>[];
    
    // 먼저 자연스러운 끊기 지점 (구두점, 쉼표, 조사 등)으로 분리 시도
    final segments = _splitByNaturalBreaks(line);
    
    String currentLine = '';
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final testLine = currentLine.isEmpty ? segment : '$currentLine$segment';
      
      if (measureTextWidth(testLine, style) <= maxWidth) {
        currentLine = testLine;
      } else {
        // 현재 줄이 너무 길면 저장하고 새 줄 시작
        if (currentLine.isNotEmpty) {
          result.add(currentLine.trim());
        }
        
        // 단일 세그먼트도 너무 길면 글자 단위로 분할
        if (measureTextWidth(segment, style) > maxWidth) {
          final subLines = _wrapByCharacter(segment, maxWidth, style);
          if (subLines.isNotEmpty) {
            result.addAll(subLines.sublist(0, subLines.length - 1));
            currentLine = subLines.last;
          } else {
            currentLine = segment;
          }
        } else {
          currentLine = segment;
        }
      }
    }
    
    // 마지막 줄 추가
    if (currentLine.isNotEmpty) {
      result.add(currentLine.trim());
    }
    
    return result.isEmpty ? [line] : result;
  }

  /// 자연스러운 끊기 지점으로 텍스트 분할
  /// 한국어 문장 구조를 고려: 쉼표, 마침표, 조사 뒤 등
  static List<String> _splitByNaturalBreaks(String text) {
    final segments = <String>[];
    final buffer = StringBuffer();
    
    // 줄 바꿈 우선순위 (높은 순):
    // 1. 쉼표 뒤 (',')
    // 2. 마침표, 물음표, 느낌표 뒤
    // 3. 띄어쓰기
    // 4. 조사 뒤 (은/는/이/가/을/를/에/의/와/과 등)
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      buffer.write(char);
      
      // 쉼표, 마침표 등 구두점 뒤에서 분할
      if (char == ',' || char == '.' || char == '!' || char == '?') {
        // 다음 문자가 공백이면 공백도 포함
        if (i + 1 < text.length && text[i + 1] == ' ') {
          buffer.write(text[i + 1]);
          i++;
        }
        segments.add(buffer.toString());
        buffer.clear();
        continue;
      }
      
      // 띄어쓰기에서 분할
      if (char == ' ') {
        segments.add(buffer.toString());
        buffer.clear();
        continue;
      }
    }
    
    // 남은 텍스트
    if (buffer.isNotEmpty) {
      segments.add(buffer.toString());
    }
    
    return segments;
  }

  /// 글자 단위로 줄 바꿈 (세그먼트가 너무 긴 경우)
  static List<String> _wrapByCharacter(String text, double maxWidth, TextStyle style) {
    final result = <String>[];
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final testText = buffer.toString() + char;
      
      if (measureTextWidth(testText, style) <= maxWidth) {
        buffer.write(char);
      } else {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        }
        buffer.write(char);
      }
    }
    
    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }
    
    return result;
  }

  /// 한 줄에 들어갈 수 있는 대략적인 글자 수 계산
  static int calculateCharsPerLine({
    required double boxWidth,
    required TextStyle style,
    double padding = 48.0,
  }) {
    final availableWidth = boxWidth - padding;
    if (availableWidth <= 0) return 10;
    
    final charWidth = measureCharWidth(style);
    if (charWidth <= 0) return 10;
    
    return (availableWidth / charWidth).floor().clamp(5, 50);
  }

  /// 인사말 문장을 보기 좋게 포맷팅
  /// 
  /// 도입-전개-결말 구조를 유지하면서 자연스러운 줄 바꿈 적용
  static String formatGreeting({
    required String greeting,
    required double boxWidth,
    required TextStyle style,
    double padding = 48.0,
  }) {
    if (greeting.isEmpty) return greeting;
    
    // 먼저 기존 줄바꿈 정규화
    String normalized = greeting.replaceAll(RegExp(r'\n+'), ' ').trim();
    
    // 문장 구조 분석 및 자연스러운 줄 바꿈 삽입
    normalized = _insertNaturalLineBreaks(normalized);
    
    // 최종적으로 박스 너비에 맞게 포맷팅
    return formatTextForBox(
      text: normalized,
      boxWidth: boxWidth,
      style: style,
      padding: padding,
    );
  }

  /// 문장 구조에 따른 자연스러운 줄 바꿈 삽입
  /// 
  /// 도입부, 전개부, 결말부를 분리하여 각각 다른 줄에 배치
  static String _insertNaturalLineBreaks(String text) {
    // 쉼표로 구분된 절이 있으면 쉼표 뒤에서 줄 바꿈
    // 단, 너무 짧은 절은 분리하지 않음 (최소 10자 이상)
    
    final parts = <String>[];
    final buffer = StringBuffer();
    int lastBreakIndex = 0;
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      buffer.write(char);
      
      // 쉼표 뒤 또는 특정 종결어미 뒤에서 줄 바꿈 고려
      bool shouldBreak = false;
      
      if (char == ',') {
        // 현재까지의 길이가 충분하면 줄 바꿈
        if (buffer.length >= 12) {
          shouldBreak = true;
        }
      }
      
      // 종결어미 패턴 확인: ~하여, ~하며, ~하고, ~바라며 등
      if (i >= 1) {
        final twoChars = text.substring(i - 1, i + 1);
        if (_isNaturalBreakPoint(twoChars) && buffer.length >= 10) {
          // 다음 문자가 공백이면 좋은 줄 바꿈 위치
          if (i + 1 < text.length && text[i + 1] == ' ') {
            shouldBreak = true;
          }
        }
      }
      
      if (shouldBreak) {
        // 쉼표 뒤 공백 처리
        if (i + 1 < text.length && text[i + 1] == ' ') {
          buffer.write(' ');
          i++;
        }
        parts.add(buffer.toString().trim());
        buffer.clear();
        lastBreakIndex = i + 1;
      }
    }
    
    // 남은 텍스트
    if (buffer.isNotEmpty) {
      parts.add(buffer.toString().trim());
    }
    
    // 너무 많은 줄로 분리되지 않도록 조정 (최대 5줄)
    if (parts.length > 5) {
      return _mergeTooManyParts(parts, 5);
    }
    
    return parts.join('\n');
  }

  /// 자연스러운 줄 바꿈 지점인지 확인
  static bool _isNaturalBreakPoint(String twoChars) {
    const breakPoints = [
      '하여', '하며', '하고', '으며', '으로', 
      '라며', '으니', '는데', '지만', '해서',
      '니다', '습니', '세요', '해요', '어요',
    ];
    return breakPoints.contains(twoChars);
  }

  /// 너무 많은 파트를 적절히 병합
  static String _mergeTooManyParts(List<String> parts, int maxParts) {
    if (parts.length <= maxParts) return parts.join('\n');
    
    final result = <String>[];
    final partsPerLine = (parts.length / maxParts).ceil();
    
    for (int i = 0; i < parts.length; i += partsPerLine) {
      final end = (i + partsPerLine).clamp(0, parts.length);
      final merged = parts.sublist(i, end).join(' ');
      result.add(merged);
    }
    
    return result.join('\n');
  }

  /// 인사말 생성 후 자동 포맷팅 적용
  /// 
  /// [opener]: 도입부
  /// [middle]: 전개부  
  /// [ender]: 결말부
  /// [boxWidth]: 텍스트박스 너비
  /// [style]: 텍스트 스타일
  static String formatGeneratedGreeting({
    required String opener,
    required String middle,
    required String ender,
    required double boxWidth,
    required TextStyle style,
    double padding = 48.0,
  }) {
    // 각 부분을 개별 줄로 처리
    final parts = <String>[];
    
    // 도입부 처리
    String formattedOpener = opener.trim();
    if (!formattedOpener.endsWith(',') && 
        !formattedOpener.endsWith('!') && 
        !formattedOpener.endsWith('.')) {
      formattedOpener = '$formattedOpener,';
    }
    parts.add(formattedOpener);
    
    // 전개부 처리
    parts.add(middle.trim());
    
    // 결말부 처리
    parts.add(ender.trim());
    
    // 각 부분이 박스 너비를 초과하면 추가 줄 바꿈
    final formattedParts = <String>[];
    for (final part in parts) {
      final wrapped = formatTextForBox(
        text: part,
        boxWidth: boxWidth,
        style: style,
        padding: padding,
      );
      formattedParts.add(wrapped);
    }
    
    return formattedParts.join('\n');
  }
}
