@echo off
chcp 65001 >nul
echo ========================================================
echo [마음 이음] 프로젝트 초기 설정 및 코드 생성기
echo ========================================================

:: Flutter 명령어가 있는지 확인
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [오류] 경고: 'flutter'가 시스템 경로에서 감지되지 않았습니다.
    echo.
    echo Flutter SDK의 'bin' 폴더 경로를 입력해주세요.
    echo ^(예: C:\src\flutter\bin^)
    echo.
    set /p FLUTTER_BIN_PATH="경로 입력: "
    set "PATH=%PATH%;%FLUTTER_BIN_PATH%"
)

echo.
echo 1. Flutter 패키지 가져오기...
call flutter pub get

echo.
echo 2. Dart Build Runner 실행 (DB, Provider 코드 생성)...
call dart run build_runner build --delete-conflicting-outputs

echo.
echo 설정이 완료되었습니다. 이제 run_windows.bat를 실행하세요.
pause
