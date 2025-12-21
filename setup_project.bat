@echo off
chcp 65001
echo ========================================================
echo [마음 이음] 프로젝트 초기 설정 및 코드 생성기
echo ========================================================

echo 1. Flutter 패키지 가져오기...
call flutter pub get

echo 2. Dart Build Runner 실행 (DB, Provider 코드 생성)...
call dart run build_runner build --delete-conflicting-outputs

echo 설정이 완료되었습니다. 이제 run_windows.bat를 실행하세요.
pause
