@echo off
chcp 65001 >nul
echo ========================================================
echo [마음 이음] 윈도우 데스크탑 앱 실행 스크립트
echo ========================================================

:: Flutter 명령어가 있는지 확인
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [오류] 'flutter' 명령어를 찾을 수 없습니다.
    echo 시스템 환경 변수(PATH)에 Flutter가 등록되어 있지 않은 것 같습니다.
    echo.
    echo Flutter SDK의 'bin' 폴더 경로를 입력해주세요.
    echo (예: C:\src\flutter\bin 또는 E:\flutter\bin)
    echo.
    set /p FLUTTER_BIN_PATH="경로 입력: "
    
    :: 입력받은 경로를 현재 세션 PATH에 추가
    set "PATH=%PATH%;%FLUTTER_BIN_PATH%"
    
    :: 다시 확인
    where flutter >nul 2>nul
    if %errorlevel% neq 0 (
        echo.
        echo [치명적 오류] 입력하신 경로에서도 flutter를 찾을 수 없습니다.
        echo 경로를 다시 확인해 주세요: %FLUTTER_BIN_PATH%
        pause
        exit /b
    )
    echo.
    echo [성공] Flutter 경로를 임시로 설정했습니다.
)

echo.
echo 1. 프로젝트 정리 (Clean)
call flutter clean

echo.
echo 2. 패키지 설치 (Pub Get)
call flutter pub get

echo.
echo 3. 코드 생성 (Build Runner) - DB 및 Riverpod 파일 생성
call dart run build_runner build --delete-conflicting-outputs

echo.
echo 4. 윈도우 앱 실행 (Run)
call flutter run -d windows

pause
