@echo off
chcp 65001
echo ========================================================
echo [마음 이음] 안드로이드 설치파일(APK) 빌드 스크립트
echo ========================================================

echo 1. 프로젝트 정리 (Clean)
call flutter clean

echo 2. 패키지 설치 (Pub Get)
call flutter pub get

echo 3. 코드 생성 (Build Runner)
call dart run build_runner build --delete-conflicting-outputs

echo 4. APK 빌드 시작 (Release Mode)
call flutter build apk --release

echo ========================================================
echo 빌드 완료! 파일 위치: build\app\outputs\flutter-apk\app-release.apk
echo ========================================================

pause
