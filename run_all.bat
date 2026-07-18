@echo off
title AI Poster Prompt Studio Launcher
echo ===================================================
echo   AI POSTER PROMPT STUDIO - FULL STACK LAUNCHER
echo ===================================================
echo.
echo Default Admin Credentials:
echo Email:    admin@promptstudio.com
echo Password: admin123
echo ===================================================
echo.

:: 1. Start backend server in a new window
echo [1/2] Menyalakan Backend Server di port 3000...
start "Backend Server" cmd /k "cd backend && node app.js"
echo Backend Server berhasil dijalankan di jendela baru.
echo.

:: 2. Start Flutter web app on Chrome in this window
echo [2/2] Menyalakan Flutter Web di Chrome...
echo (Anda dapat menggunakan tombol 'r' untuk reload atau 'R' untuk restart di jendela ini)
echo.
flutter run -d chrome
