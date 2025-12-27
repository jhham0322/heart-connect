# Git 리비전을 app_version.dart에 업데이트하는 PowerShell 스크립트
# 빌드 전에 실행: .\scripts\update_version.ps1

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$versionFile = Join-Path $projectRoot "lib\src\utils\app_version.dart"

# Git 리비전 가져오기
try {
    $gitRevision = git rev-parse --short HEAD
    if (-not $gitRevision) { $gitRevision = "dev" }
} catch {
    $gitRevision = "dev"
}

# 빌드 날짜
$buildDate = Get-Date -Format "yyyy-MM-dd"

# app_version.dart 파일 생성
$content = @"
// 이 파일은 빌드 스크립트에 의해 자동 생성됩니다.
// 수동으로 수정하지 마세요.
// 생성: $buildDate

class AppVersion {
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  
  // Git/SVN 리비전 정보 (빌드 시 자동 업데이트)
  static const String revision = '$gitRevision';
  
  // 빌드 날짜
  static const String buildDate = '$buildDate';
  
  // 전체 버전 문자열
  static String get fullVersion => '`$version+`$buildNumber (`$revision)';
  
  // 짧은 버전 문자열
  static String get shortVersion => 'v`$version (`$revision)';
}
"@

Set-Content -Path $versionFile -Value $content -Encoding UTF8

Write-Host "✓ 버전 정보 업데이트됨: v1.0.0 ($gitRevision)" -ForegroundColor Green
