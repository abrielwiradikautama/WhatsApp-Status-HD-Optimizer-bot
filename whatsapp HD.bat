@echo off
setlocal enabledelayedexpansion
color 0b
title WhatsApp Status HD Optimizer (System-Wide Search) - by abriel wiradika utama

:: ==========================================
:: 1. PROTOKOL SMART CHECK FFMPEG (4 LAPIS)
:: ==========================================
set "ffmpeg_path=%~dp0ffmpeg.exe"
if exist "!ffmpeg_path!" goto start

ffmpeg -version >nul 2>&1
if !errorlevel! equ 0 (
    set "ffmpeg_path=ffmpeg"
    goto start
)

set "my_pc=D:\Download\ffmpeg-2026-03-22-git-9c63742425-essentials_build\bin\ffmpeg.exe"
if exist "%my_pc%" (
    set "ffmpeg_path=%my_pc%"
    goto start
)

echo  [i] Mencari FFmpeg di folder Download...
for /f "delims=" %%i in ('dir /s /b "D:\Download\ffmpeg.exe" 2^>nul') do (
    set "ffmpeg_path=%%i"
    if exist "!ffmpeg_path!" (
        echo  [v] Ditemukan di: %%i
        timeout /t 1 >nul
        goto start
    )
)

:: Auto-Download if missing
cls
echo ==========================================================
echo   [!] FFMPEG TIDAK DITEMUKAN DI SISTEM
echo ==========================================================
set /p dl=" [?] Unduh otomatis FFmpeg dari GitHub sekarang? (y/n): "
if /i "!dl!" neq "y" exit

echo.
echo  [i] Mengunduh arsip FFmpeg...
powershell -Command "$ProgressPreference = 'Continue'; Invoke-WebRequest -Uri 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile 'ffmpeg.zip'"

echo  [i] Mengekstrak file ZIP...
powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'ffmpeg_ext' -Force"

for /f "delims=" %%d in ('dir /b "ffmpeg_ext\ffmpeg-master*"') do set "extracted_folder=%%d"
copy "ffmpeg_ext\!extracted_folder!\bin\ffmpeg.exe" "%~dp0ffmpeg.exe" >nul

rmdir /s /q "ffmpeg_ext"
del "ffmpeg.zip"
set "ffmpeg_path=%~dp0ffmpeg.exe"

:: ==========================================
:: 2. PROGRAM UTAMA: PENCARIAN SISTEM (DEEP SCAN)
:: ==========================================
:start
cls
echo ==========================================================
echo         WHATSAPP STATUS HD OPTIMIZER (ALL MEDIA)
echo              by : abriel wiradika utama
echo ==========================================================
echo   Support: MP4, MKV, MOV, JPG, PNG, HEIC
echo   Lokasi Scan: C:\image, D:\image, C:\video, D:\video,
echo                Downloads Windows, D:\Download, ^& Current Dir
echo ==========================================================
echo.

set /p keyword=" [?] Masukkan Nama File / Kata Kunci: "

echo  [i] Melakukan Deep Scan... Mohon tunggu sebentar...
set count=0
set "locations= C:\Users\%USERNAME%\image D:\image C:\Users\%USERNAME%\video D:\video C:\Users\%USERNAME%\Downloads D:\Download %~dp0"

for %%L in (%locations%) do (
    if exist "%%L" (
        for /f "delims=" %%f in ('dir /s /b "%%L\*!keyword!*.*" 2^>nul') do (
            set "ext=%%~xf"
            set "is_valid="
            
            if /i "!ext!"==".mp4" set "is_valid=video"
            if /i "!ext!"==".mkv" set "is_valid=video"
            if /i "!ext!"==".mov" set "is_valid=video"
            if /i "!ext!"==".jpg" set "is_valid=image"
            if /i "!ext!"==".jpeg" set "is_valid=image"
            if /i "!ext!"==".png" set "is_valid=image"
            if /i "!ext!"==".heic" set "is_valid=image"
            
            if defined is_valid (
                if /i not "%%~nxf"=="ffmpeg.exe" (
                    set /a count+=1
                    set "file_!count!=%%f"
                    set "type_!count!=!is_valid!"
                    echo  [!count!] [!is_valid!] %%f
                )
            )
        )
    )
)

if %count% equ 0 (
    echo.
    echo  [x] GAGAL: File tidak ditemukan di folder-folder target.
    pause
    goto start
)

echo.
if %count% gtr 1 (
    set /p choice=" [?] Pilih nomor (1-%count%): "
) else (
    set choice=1
)

set "final_path=!file_%choice%!"
set "final_type=!type_%choice%!"

if "!final_path!"=="" (
    echo  [x] Pilihan tidak valid!
    pause
    goto start
)

:: ==========================================
:: 3. PROSES EKSEKUSI HD
:: ==========================================
cls
echo ==========================================================
echo  PENGOLAHAN !final_type! SEDANG BERJALAN...
echo  Source: !final_path!
echo ==========================================================
echo.

set "out_dir=%~dp0Optimized_Status"
if not exist "!out_dir!" mkdir "!out_dir!"

if "!final_type!"=="video" (
    "!ffmpeg_path!" -i "!final_path!" ^
        -c:v libx264 -profile:v high -level 4.1 ^
        -crf 18 -maxrate 4M -bufsize 8M ^
        -vf "scale=w=1080:h=1920:force_original_aspect_ratio=increase,crop=1080:1920" ^
        -c:a aac -b:a 160k -movflags +faststart ^
        -y "!out_dir!\HD_VIDEO_%%~nA.mp4"
) else (
    "!ffmpeg_path!" -i "!final_path!" ^
        -vf "scale='if(gt(iw,ih),2560,-1)':'if(gt(iw,ih),-1,2560)'" ^
        -q:v 2 ^
        -y "!out_dir!\HD_IMAGE_%%~nA.jpg"
)

echo.
echo ----------------------------------------------------------
if %errorlevel% equ 0 (
    echo  [v] BERHASIL! File disimpan di: !out_dir!
) else (
    echo  [x] Terjadi kesalahan teknis.
)
echo ----------------------------------------------------------

echo.
set /p lagi=" [?] Cari file lain? (y/n): "
if /i "%lagi%"=="y" goto start
exit