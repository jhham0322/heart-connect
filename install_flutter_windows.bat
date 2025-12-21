@echo off
chcp 65001 >nul
echo ========================================================
echo [마음 이음] Flutter 자동 설치 및 환경 설정 스크립트
echo ========================================================
echo.
echo 1. 설치 위치 확인 (C:\src\flutter)
if not exist "C:\src" mkdir "C:\src"
cd /d C:\src

echo.
echo 2. Flutter SDK 다운로드 (Git Clone)...
echo 인터넷 속도에 따라 3~10분 정도 소요될 수 있습니다. 창을 닫지 마세요.
if exist "flutter" (
    echo 이미 Flutter 폴더가 존재합니다. 최신 버전으로 업데이트합니다.
    cd flutter
    git pull
) else (
    git clone https://github.com/flutter/flutter.git -b stable
)

echo.
echo 3. 환경 변수(PATH) 영구 등록...
:: PowerShell을 이용해 User PATH에 안전하게 추가
powershell -Command "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'User'); if ($oldPath -notlike '*C:\src\flutter\bin*') { [Environment]::SetEnvironmentVariable('Path', $oldPath + ';C:\src\flutter\bin', 'User'); Write-Host '환경 변수 추가 완료.' } else { Write-Host '이미 환경 변수가 등록되어 있습니다.' }"

echo.
echo ========================================================
echo 설치가 완료되었습니다!
echo.
echo ** 중요 **: 
echo 1. 이 창을 닫고, 실행 중인 모든 탐색기와 VS Code를 완전히 종료하세요.
echo 2. 다시 VS Code를 열면 'flutter' 명령어가 인식됩니다.
echo 3. 그 후 'run_windows.bat'를 실행하여 앱을 구동하세요.
echo ========================================================
pause
