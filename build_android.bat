@echo off
chcp 65001 >nul
echo ========================================================
echo [마음 이음] 안드로이드 설치파일(APK) 빌드 스크립트
echo ========================================================

:: Flutter 명령어가 있는지 확인
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [오류] 'flutter' 명령어를 찾을 수 없습니다.
    echo.
    echo Flutter SDK의 'bin' 폴더 경로를 입력해주세요.
    echo (예: C:\src\flutter\bin 또는 E:\flutter\bin)
    echo.
    set /p FLUTTER_BIN_PATH="경로 입력: "
    set "PATH=%PATH%;%FLUTTER_BIN_PATH%"
    
    where flutter >nul 2>nul
    if %errorlevel% neq 0 (
        echo.
        echo [치명적 오류] 입력하신 경로에서도 flutter를 찾을 수 없습니다.
        pause
        exit /b
    )
)

echo.
echo 1. 프로젝트 정리 (Clean)
call flutter clean

echo.
echo 2. 패키지 설치 (Pub Get)
call flutter pub get

echo.
echo 3. 코드 생성 (Build Runner)
call dart run build_runner build --delete-conflicting-outputs

echo.
echo 4. APK 빌드 시작 (Release Mode)
call flutter build apk --release

echo ========================================================
echo 빌드 완료! 파일 위치: build\app\outputs\flutter-apk\app-release.apk
echo ========================================================

pause
