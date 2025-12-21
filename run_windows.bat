@echo off
chcp 65001
echo ========================================================
echo [마음 이음] 윈도우 데스크탑 앱 실행 스크립트
echo ========================================================

echo 1. 프로젝트 정리 (Clean)
call flutter clean

echo 2. 패키지 설치 (Pub Get)
call flutter pub get

echo 3. 코드 생성 (Build Runner) - DB 및 Riverpod 파일 생성
call dart run build_runner build --delete-conflicting-outputs

echo 4. 윈도우 앱 실행 (Run)
call flutter run -d windows

pause
