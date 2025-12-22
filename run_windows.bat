@echo off
chcp 65001 >nul
echo ========================================================
echo [마음 이음] 윈도우 앱 실행 도구
echo ========================================================
echo.
echo 1. 빠른 실행 (Fast Run) [기본값]
echo    - 기존 빌드를 재사용하여 빠르게 실행합니다.
echo    - 코드 수정 후 바로 확인할 때 사용하세요.
echo.
echo 2. 전체 다시 빌드 (Clean & Build)
echo    - 빌드 오류가 발생하거나 깨끗하게 다시 시작하고 싶을 때 사용하세요.
echo    - 시간이 오래 걸립니다.
echo.
echo 3. 코드 생성 후 실행 (Build Runner & Run)
echo    - DB 스키마나 API 변경 등 코드 생성이 필요할 때 사용하세요.
echo.

set /p CHOICE="선택해주세요 (1-3) [Enter = 1]: "

if "%CHOICE%"=="" set CHOICE=1

if "%CHOICE%"=="1" goto FastRun
if "%CHOICE%"=="2" goto CleanBuild
if "%CHOICE%"=="3" goto GenRun

:FastRun
echo.
echo [빠른 실행] 시작...
call flutter run -d windows
goto End

:CleanBuild
echo.
echo [프로젝트 정리] 시작...
call flutter clean
echo.
echo [패키지 설치] 시작...
call flutter pub get
echo.
echo [코드 생성] 시작...
call dart run build_runner build --delete-conflicting-outputs
echo.
echo [윈도우 앱 실행] 시작...
call flutter run -d windows
goto End

:GenRun
echo.
echo [코드 생성] 시작...
call dart run build_runner build --delete-conflicting-outputs
echo.
echo [윈도우 앱 실행] 시작...
call flutter run -d windows
goto End

:End
pause
